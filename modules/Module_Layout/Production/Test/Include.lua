local test = {};
local private = {};

local CFG      = require( "Module:Layout/Production/Configuration" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_hook()
    local try1 = CFG.INCLUDE("production", "hook");
    local test1 = private.require_to_string(try1);
    local result1 = ("{FORMAT=table,OBJECT=table,ORIENTATION=table,PARAMETER=table,SUPPORT=table,}"):gsub("%s+", "");
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
end

function test:test_development()
    local try1 = CFG.INCLUDE("development", "Language/NL");
    local test1 = private.require_to_string(try1);
    local result1 = "{TEMPLATENAME=Opmaak,}";
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
end

function test:test_interface()
    local test1 = private.require_to_string(CFG.INCLUDE("production", "interface"));
    local result1 = "{main=function:function,}";
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
end

function test:test_language()
    local try1 = CFG.INCLUDE("production", "Language/NL");
    local test1 = private.require_to_string(try1);
    local result1 = ("{BUTTON=table,DEBUG=table,HELP=table,HOOK=table,MISTAKE=table,PREPOSITION=table,TEMPLATENAME=Opmaak,}"):gsub("%s+", "");
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
    self:assertEquals("Fouten geconstateerd", try1.MISTAKE.HEADER);
end

function test:test_production()
    local try1 = CFG.INCLUDE("development", "hook");
    local test1 = private.require_to_string(try1);
    local result1 = ("{FORMAT=table,OBJECT=table,ORIENTATION=table,PARAMETER=table,SUPPORT=table,}"):gsub("%s+", "");
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
end

function test:test_progress()
    local try1 = CFG.INCLUDE("production", "Language/NL/progress");
    local test1 = private.require_to_string(try1);
    local result1 = ("{DEVELOPMENT=,GO=[[Afbeelding:75 percent.svg|%spx|link=|Goed ontwikkeld. Revisiedatum: Volgens infobox]],IO=[[Afbeelding:25 percent.svg|%spx|link=|In ontwikkeling. Revisiedatum: Volgens infobox]],NAME=Voortgang,NOTHING=[[Afbeelding:00 percent.svg|%spx|link=|Nog vrijwel niets. Revisiedatum: Volgens infobox]],RO=[[Afbeelding:50 percent.svg|%spx|link=|Redelijk ontwikkeld. Revisiedatum: Volgens infobox]],ZO=[[Afbeelding:100 percent.svg|%spx|link=|Zeer goed ontwikkeld. Revisiedatum: Volgens infobox]],}"):gsub("%s+", "");
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
    self:assertEquals("Voortgang", try1.NAME);
end

function private.require_to_string(t)
    if type(t) ~= "table" then return ""; end
    local str = "{\n"
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, k in ipairs(keys) do
        local v = t[k]
        if type(v) == "function" then
            str = str .. "  " .. tostring(k) .. " = function: " .. tostring(v) .. ",\n"
        elseif type(v) == "table" then
            str = str .. "  " .. tostring(k) .. " = table,\n"
        else
            str = str .. "  " .. tostring(k) .. " = " .. tostring(v) .. ",\n"
        end
    end
    str = str .. "}"
    return str
end

function test:test_include_multiple()
    local text, array = CFG.INCLUDE("production", "text", "array");
    self:assertEquals("table", type(text), "First module should be returned as table");
    self:assertEquals("table", type(array), "Second module should be returned as table");
    self:assertEquals("function", type(text.trim), "First module should contain its functions");
    self:assertEquals("function", type(array.search), "Second module should contain its functions");
end

function test:test_include_optional()
    local try_missing = CFG.INCLUDE_OPTIONAL("production", "this_file_does_not_exist");
    self:assertEquals("nil", type(try_missing), "Optional include should return nil for missing modules");
    
    local try_exists = CFG.INCLUDE_OPTIONAL("production", "hook");
    self:assertEquals("table", type(try_exists), "Optional include should return the table if it exists");
end

function test:test_include_error()
    local success, err = pcall(function() 
        CFG.INCLUDE("production", "this_file_does_not_exist_either") 
    end)
    self:assertEquals(false, success, "Required include should throw an error when missing");
    self:assertEquals("string", type(err), "Error should be a string message");
    self:assertStringContains("Module:Layout include not found", err, true, "Error message should contain standard text");
end

function test:test_include_cache()
    local instance1 = CFG.INCLUDE("production", "hook");
    local instance2 = CFG.INCLUDE("production", "hook");
    -- Since it hits the cache, it should return the exact same table reference
    self:assertEquals(tostring(instance1), tostring(instance2), "Subsequent includes should return the cached instance");
end

function test:test_include_unknown_env()
    -- Unknown environments like 'typo' should safely fallback to 'production' (the last environment in the list)
    local try1 = CFG.INCLUDE("typo_environment", "hook");
    local test1 = private.require_to_string(try1);
    local result1 = ("{FORMAT=table,OBJECT=table,ORIENTATION=table,PARAMETER=table,SUPPORT=table,}"):gsub("%s+", "");
    
    self:assertEquals(result1, test1:gsub("%s+", ""), "Unknown environment should fallback to production");
end

function test:test_include_empty()
    local no_args = { CFG.INCLUDE("production") }
    self:assertEquals(0, #no_args, "Calling INCLUDE without modules should safely return an empty result");
end

function test:test_include_non_string()
    local success, err = pcall(function() 
        CFG.INCLUDE("production", 123) 
    end)
    self:assertEquals(false, success, "INCLUDE should throw an error if module name is not a string");
    self:assertStringContains("Module:Layout INCLUDE expects string arguments", err, true, "Error should explain that strings are expected");
end

return test;