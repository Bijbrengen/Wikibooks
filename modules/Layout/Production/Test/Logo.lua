local test = {};

local CFG      = require( "Module:Layout/Production/Configuration" );
local logo     = CFG.INCLUDE( "production", "logo" );
local unittest = CFG.INCLUDE( "production", "unittest" );
test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_Logo()
	local call = {};
	call.source = "Huma.JPG";
	local result1 = '<div>[[File:Huma.JPG|300px|Logo|center]]</div>';
    self:assertEquals( result1, logo.main( call )   , "Valid Huma.JPG" );
end

return test;
