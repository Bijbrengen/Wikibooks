-- Local runner for the mirrored nl.wikibooks Module:Layout tests.
-- It provides a small MediaWiki/Scribunto stub so library-style tests can run
-- outside MediaWiki. Full template expansion still belongs in MediaWiki itself.

local unpack = unpack or table.unpack
_G.unpack = _G.unpack or unpack

local sep = package.config:sub(1, 1)

local function normalize_path(path)
    return (path:gsub("[/\\]", sep))
end

local source = debug.getinfo(1, "S").source
if source:sub(1, 1) == "@" then
    source = source:sub(2)
end
source = normalize_path(source)

local tests_dir = source:match("^(.*[/\\])") or ("." .. sep)
local layout_root = tests_dir .. ".." .. sep
local fixture_root = tests_dir .. "fixtures" .. sep

local function read_file(path)
    local handle = io.open(path, "rb")
    if not handle then
        return nil
    end
    local content = handle:read("*a")
    handle:close()
    return content
end

local function file_exists(path)
    local handle = io.open(path, "rb")
    if handle then
        handle:close()
        return true
    end
    return false
end

local function module_to_file(module_name)
    if module_name == "Module:Layout" then
        return layout_root .. "_module.lua"
    end

    local prefix = "Module:Layout/"
    if module_name:sub(1, #prefix) ~= prefix then
        return nil
    end

    local relative = module_name:sub(#prefix + 1):gsub("/", sep)
    return layout_root .. relative .. ".lua"
end

package.preload["strict"] = function()
    return true
end

package.preload["Module:Layout/Configuration"] = function()
    return require("Module:Layout/Production/Configuration")
end

package.preload["Module:Layout/Production/Library/Test"] = function()
    return require("Module:Layout/Production/Library/Unittest")
end

local loaders = package.searchers or package.loaders
table.insert(loaders, 1, function(module_name)
    local path = module_to_file(module_name)
    if not path then
        return "\n\tno local Layout mapping for " .. module_name
    end
    if not file_exists(path) then
        return "\n\tlocal Layout file not found: " .. path
    end

    local chunk, err = loadfile(path)
    if not chunk then
        return "\n\tfailed to load " .. path .. ": " .. tostring(err)
    end
    return chunk
end)

local function dump(value, seen)
    if type(value) ~= "table" then
        return tostring(value)
    end
    seen = seen or {}
    if seen[value] then
        return "<cycle>"
    end
    seen[value] = true

    local keys = {}
    for key in pairs(value) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)

    local parts = {"{"}
    for _, key in ipairs(keys) do
        table.insert(parts, tostring(key) .. "=" .. dump(value[key], seen) .. ",")
    end
    table.insert(parts, "}")
    return table.concat(parts)
end

local function trim(value)
    if value == nil then
        return ""
    end
    value = tostring(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split(value, separator)
    local result = {}
    value = tostring(value or "")
    separator = separator or "%s+"
    for part in value:gmatch("[^" .. separator .. "]+") do
        table.insert(result, part)
    end
    return result
end

local function template_to_file(title)
    if title == "Sjabloon:Opmaak" or title == "Template:Opmaak" then
        return fixture_root .. "Sjabloon_Opmaak.raw.wiki"
    end
    return nil
end

local function title_object(title)
    local module_path = module_to_file(title)
    local template_path = template_to_file(title)
    local path = module_path or template_path
    local exists = path ~= nil and file_exists(path)

    local text = title:gsub("^.-:", "")
    local root_text = text:gsub("/.*$", "")
    local subpage_text = text:match("/([^/]+)$") or text

    return {
        prefixedText = title,
        fullText = title,
        text = text,
        rootText = root_text,
        subpageText = subpage_text,
        nsText = title:match("^(.-):") or "",
        namespace = title:match("^Module:") and 828 or 0,
        exists = exists,
        isSubpage = text:find("/", 1, true) ~= nil,
        getContent = function()
            if not path then
                return nil
            end
            return read_file(path)
        end,
    }
end

local function new_frame(args, title, parent)
    local frame = {
        args = args or {},
        _title = title or "Sjabloon:Opmaak",
        _parent = parent,
    }

    function frame:newChild(options)
        options = options or {}
        return new_frame(options.args or {}, options.title or "Child frame", self)
    end

    function frame:getParent()
        return self._parent or new_frame({}, "Parent frame", nil)
    end

    function frame:getTitle()
        return self._title
    end

    function frame:preprocess(text)
        return tostring(text or "")
    end

    function frame:expandTemplate(options)
        options = options or {}
        local title = options.title or ""
        local path = template_to_file(title)
        return path and (read_file(path) or "") or ""
    end

    return frame
end

mw = {
    text = {
        trim = trim,
        split = split,
        nowiki = function(value) return tostring(value or "") end,
    },
    ustring = {
        format = string.format,
        find = string.find,
        sub = string.sub,
        gsub = string.gsub,
        gmatch = string.gmatch,
        match = string.match,
        len = string.len,
        lower = string.lower,
        upper = string.upper,
    },
    title = {
        new = title_object,
        getCurrentTitle = function()
            return title_object("Sjabloon:Opmaak/Test")
        end,
    },
    getCurrentFrame = function()
        return new_frame({ displayMode = "short" }, "Sjabloon:Opmaak/Test", nil)
    end,
    log = function(...)
        local values = {}
        for index = 1, select("#", ...) do
            values[index] = tostring(select(index, ...))
        end
        print(table.concat(values, "\t"))
    end,
    dumpObject = dump,
    message = {
        newRawMessage = function(format, ...)
            local values = {...}
            return {
                plain = function()
                    local result = tostring(format or "")
                    for index, value in ipairs(values) do
                        result = result:gsub("%$" .. index, tostring(value))
                    end
                    return result
                end,
            }
        end,
    },
    html = {
        create = function(tag_name)
            local node = { tag_name = tag_name, children = {}, attributes = {}, styles = {}, classes = {} }
            local node_methods = {}
            node_methods.__index = node_methods

            function node_methods:addClass(class_name)
                table.insert(self.classes, class_name)
                return self
            end

            function node_methods:css(name, value)
                self.styles[name] = value
                return self
            end

            function node_methods:attr(name, value)
                self.attributes[name] = value
                return self
            end

            function node_methods:wikitext(value)
                table.insert(self.children, tostring(value or ""))
                return self
            end

            function node_methods:tag(child_tag_name)
                local child = mw.html.create(child_tag_name)
                child.parent = self
                table.insert(self.children, child)
                return child
            end

            function node_methods:done()
                return self.parent or self
            end

            function node_methods:__tostring()
                local child_text = {}
                for _, child in ipairs(self.children) do
                    table.insert(child_text, tostring(child))
                end
                return "<" .. tostring(self.tag_name) .. ">" .. table.concat(child_text) .. "</" .. tostring(self.tag_name) .. ">"
            end

            return setmetatable(node, node_methods)
        end,
    },
}

local default_suites = { "Array", "Call", "Color", "Pattern", "Text", "Timestamp" }
local all_suites = {
    "Array",
    "Box",
    "Call",
    "Chess",
    "Color",
    "Convert",
    "Extract",
    "Include",
    "Interface",
    "Logo",
    "Luggage",
    "Mediawiki",
    "Pattern",
    "Security",
    "Text",
    "Timestamp",
    "Validation",
}
local suites = {}

for index = 1, #arg do
    if arg[index] == "all" or arg[index] == "--all" then
        suites = all_suites
        break
    elseif arg[index] ~= "default" then
        table.insert(suites, arg[index])
    end
end
if #suites == 0 then
    suites = default_suites
end

local total_success, total_failure, total_skipped = 0, 0, 0

for _, suite_name in ipairs(suites) do
    local ok, suite = pcall(require, "Module:Layout/Production/Test/" .. suite_name)
    if not ok then
        io.stderr:write("FAILED loading " .. suite_name .. ": " .. tostring(suite) .. "\n")
        total_failure = total_failure + 1
    else
        local frame = new_frame({ displayMode = "short" }, "Sjabloon:Opmaak/Test/" .. suite_name, nil)
        local output, data = suite.main(frame)
        data = data or { successCount = 0, failureCount = 1, skipCount = 0, results = {} }

        total_success = total_success + (data.successCount or 0)
        total_failure = total_failure + (data.failureCount or 0)
        total_skipped = total_skipped + (data.skipCount or 0)

        print(string.format(
            "%s: %s passed, %s failed, %s skipped",
            suite_name,
            tostring(data.successCount or 0),
            tostring(data.failureCount or 0),
            tostring(data.skipCount or 0)
        ))
        if output and output ~= "" then
            print("  " .. tostring(output))
        end
        for _, result in ipairs(data.results or {}) do
            if result.error then
                print("  - " .. tostring(result.name) .. ": " .. tostring(result.message))
            end
        end
    end
end

print(string.format(
    "Total: %d passed, %d failed, %d skipped",
    total_success,
    total_failure,
    total_skipped
))

if total_failure > 0 then
    os.exit(1)
end
