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
    local result1 = "{SUPPORT=table,OBJECT=table,PARAMETER=table,FORMAT=table,ORIENTATION=table,}";
    
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
    local result1 = "{HOOK=table,HELP=table,TEMPLATENAME=Opmaak,DEBUG=table,MISTAKE=table,}";
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
    self:assertEquals("Fouten geconstateerd", try1.MISTAKE.HEADER);
end

function test:test_production()
    local try1 = CFG.INCLUDE("development", "hook");
    local test1 = private.require_to_string(try1);
    local result1 = "{SUPPORT=table,OBJECT=table,PARAMETER=table,FORMAT=table,ORIENTATION=table,}";
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
end

function test:test_progress()
    local try1 = CFG.INCLUDE("production", "Language/NL/progress");
    local test1 = private.require_to_string(try1);
    local result1 = "{NAME=Voortgang,DEVELOPMENT=Ditboekisinontwikkeling.Volgdewijzingendoorbijelkhoofdstukopdesterteklikkenofgebruikdetoetscombinatie[alt+shift+w],}";
    
    self:assertEquals(result1, test1:gsub("%s+", ""));
    self:assertEquals("Voortgang", try1.NAME);
end

function private.require_to_string(t)
    if type(t) ~= "table" then return ""; end
    local str = "{\n"
    for k, v in pairs(t) do
        if type(v) == "function" then
            str = str .. "  " .. tostring(k) .. " = function: " .. tostring(v) .. ",\n"
        else
            str = str .. "  " .. tostring(k) .. " = " .. tostring(v) .. ",\n"
        end
    end
    str = str .. "}"
    return str
end

return test;
