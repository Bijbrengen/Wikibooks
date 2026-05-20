local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local text  = CFG.INCLUDE( "production", "text" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_text_capitalize_first()
    self:assertEquals( "", text.capitalize_first( "" ), "Empty string" );
    self:assertEquals( "Hello", text.capitalize_first( "hello" ), "Lowercase word" );
    self:assertEquals( "Hello", text.capitalize_first( "Hello" ), "Capitalized word" );
    self:assertEquals( "Hello", text.capitalize_first( "HELLO" ), "Uppercase word" );
    self:assertEquals( "  hello", text.capitalize_first( "  hello" ), "Leading spaces" );
    self:assertEquals( "1hello", text.capitalize_first( "1hello" ), "Starting with digit" );
end

function test:test_text_split()
    self:assertDeepEquals( {}, text.split( "", false ), "Empty string" );
    self:assertDeepEquals( { " a" }, text.split( " a", false ), "No , no trim" );
    self:assertDeepEquals( { "a" }, text.split( " a ", true ), "No , with trim" );
    self:assertDeepEquals( { "a", "b", "c" }, text.split( "a,b,c", false ), "No trim" );
    self:assertDeepEquals( { "a", "b", "c" }, text.split( "a , b , c", true ), "With trim" );
    self:assertDeepEquals( { "", "a", "b", "c" }, text.split( ",a,b,c", false ), "Starting with comma" );
    self:assertDeepEquals( { "a", "b", "c", "" }, text.split( "a,b,c,", false ), "Ending with comma" );
    self:assertDeepEquals( { "", "a", "b", "c", "" }, text.split( ",a,b,c,", false ), "Both starting and ending with comma" );
end

function test:test_text_trim()
    self:assertEquals( "", text.trim( "" ), "Empty string" );
    self:assertEquals( "hello", text.trim( "  hello  " ), "Leading and trailing spaces" );
    self:assertEquals( "hello", text.trim( "  hello" ), "Leading spaces" );
    self:assertEquals( "hello", text.trim( "hello  " ), "Trailing spaces" );
    self:assertEquals( "hello", text.trim( "hello" ), "No spaces" );
end

function test:test_text_valid()
    self:assertFalse( text.valid( "" ), "Empty string" );
    self:assertFalse( text.valid( "  " ), "Whitespace string" );
    self:assertTrue( text.valid( "hello" ), "Valid string" );
    self:assertFalse( text.valid( nil ), "nil value" );
end

return test;