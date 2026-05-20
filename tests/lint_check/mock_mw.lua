local mock_mw = {}

mock_mw.text = {
    trim = function(s) return s:match("^%s*(.-)%s*$") end
}

mock_mw.ustring = {
    format = string.format,
    sub = string.sub,
    len = string.len
}

mock_mw.title = {
    getCurrentTitle = function()
        return {
            text = "Test Page",
            subpageText = "Subpage",
            rootText = "Root"
        }
    end,
    new = function(t)
        return {
            exists = true,
            text = t
        }
    end
}

mock_mw.uri = {
    fullUrl = function(p, q)
        return "https://example.org/" .. p
    end
}

local html_mt = {}
html_mt.__index = html_mt

function html_mt:tag(t)
    local child = mock_mw.html.create(t)
    table.insert(self.nodes, child)
    return child
end

function html_mt:node(n)
    table.insert(self.nodes, n)
    return self
end

function html_mt:wikitext(t)
    table.insert(self.nodes, tostring(t))
    return self
end

function html_mt:addClass(c) return self end
function html_mt:css(k, v) return self end
function html_mt:attr(k, v) return self end
function html_mt:done() return self.parent or self end
function html_mt:allDone() return self end

function html_mt:__tostring()
    local res = "<" .. self.name
    -- Attributes/CSS not mocked for simplicity in string output
    res = res .. ">"
    for _, n in ipairs(self.nodes) do
        res = res .. tostring(n)
    end
    res = res .. "</" .. self.name .. ">"
    return res
end

mock_mw.html = {
    create = function(t)
        return setmetatable({
            name = t,
            nodes = {}
        }, html_mt)
    end
}

return mock_mw
