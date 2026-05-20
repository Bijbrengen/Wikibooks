local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local color    = CFG.INCLUDE( "production", "color" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

local test = {}

local CFG = require("Module:Layout/Production/Configuration");
local color = CFG.INCLUDE("production", "color");
local unittest = CFG.INCLUDE("production", "unittest");

test = unittest:new();

function test.main( frame )
    return test.run( frame );
end

function test:test_color_shades()
    local shades = color.shades( 0, 0, 255, 3 );
    self:assertEquals( "#00003F", shades[1], "First shade" );
    self:assertEquals( "#00007F", shades[2], "Second shade" );
    self:assertEquals( "#0000BF", shades[3], "Third shade" );
end

function test:test_color_tints()
    local tints = color.tints( 0, 0, 255, 3 );
    self:assertEquals( "#3F3FFF", tints[1], "First tint" );
    self:assertEquals( "#7F7FFF", tints[2], "Second tint" );
    self:assertEquals( "#BFBFFF", tints[3], "Third tint" );
end

function test:test_color_valid()
    self:assertEquals( true, color.valid( "#FFFFFF" ), "Valid hex code" );
    self:assertEquals( true, color.valid( "#000000" ), "Valid hex code" );
    self:assertEquals( true, color.valid( "#FF0000" ), "Valid hex code" );
    self:assertEquals( true, color.valid( "FFFFFF" ), "Valid hex code without #" );
    self:assertEquals( false, color.valid( "#GHIJKL" ), "Invalid hex code" );
    self:assertEquals( false, color.valid( "#12345" ), "Invalid hex code length" );
    self:assertEquals( false, color.valid( "12345" ), "Invalid hex code length without #" );
    self:assertEquals( false, color.valid( 123456 ), "Invalid data type" );
end

return test;
