local test = {};

local interface = require("Module:Layout/Production/Interface");
local unittest  = require("Module:Layout/Production/Library/Test");
local testframe     = {};
test = unittest:new();

function test.main( frame )
    testframe = frame;
    return test:run( frame );
end

function test:test_Include()
--	local frame = {};
	local CFG = require("Module:Layout/Production/Configuration");
	self:assertEquals( "", interface.main( testframe, CFG ), "empty" ); 
end

return test;
