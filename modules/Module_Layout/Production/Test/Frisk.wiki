local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local frisk    = CFG.INCLUDE( "production", "frisk" );
local unittest = CFG.INCLUDE( "production", "unittest" );
local call     = CFG.INCLUDE( "production", "call" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

-- Helper to quickly initialize a standard call object for Frisk tests
local function setup_call()
    local my_call = call.init( CFG, "production" );
    my_call.named = {};
    my_call.style = {
        BLUE = "blue",
        ORANGE = "orange",
        PURPLE = "purple"
    };
    my_call.message = {
        MISTAKE = {
            WRONG = {
                COLOR = "Wrong color %s %s %s %s %s",
                PROGRESS = "Wrong progress",
                HTML = "Wrong HTML %s %s",
                PAGENAMELIST = "Wrong pagelist %s %s",
                FORMAT = "Wrong enum format %s %s %s",
                OBJECT = "Wrong enum object %s %s %s"
            }
        },
        HOOK = {
            FORMAT = { "Html", "Tekst" },
            OBJECT = { "Boek", "Module" }
        }
    };
    return my_call;
end

function test:test_frisk_color()
    local my_call = setup_call();
    
    -- Valid colors
    my_call.color = "#FFFFFF";
    test:assertEquals( false, frisk.color( my_call ), "1 valid color should return false" );
    
    my_call.color = "#FFFFFF, #000000";
    test:assertEquals( false, frisk.color( my_call ), "2 valid colors should return false" );

    my_call.color = "#FFFFFF, #000000, #FF0000";
    test:assertEquals( false, frisk.color( my_call ), "3 valid colors should return false" );

    -- Invalid colors (more than 3)
    my_call.color = "#FFFFFF, #000000, #FF0000, #00FF00";
    local mistake1 = frisk.color( my_call );
    test:assertEquals( "string", type(mistake1), "More than 3 colors should return a mistake string" );

    -- Invalid colors (malformed)
    my_call.color = "not_a_hex_color";
    local mistake2 = frisk.color( my_call );
    test:assertEquals( "string", type(mistake2), "Invalid hex format should return a mistake string" );
end

function test:test_frisk_progress()
    local my_call = setup_call();
    
    -- Ignore boolean false
    my_call.progress = false;
    test:assertEquals( false, frisk.progress( my_call ), "false progress should return false" );

    -- Valid progress
    my_call.progress = "0";
    test:assertEquals( false, frisk.progress( my_call ), "0 should be valid" );
    my_call.progress = "50";
    test:assertEquals( false, frisk.progress( my_call ), "50 should be valid" );
    my_call.progress = "100";
    test:assertEquals( false, frisk.progress( my_call ), "100 should be valid" );
    my_call.progress = "75%";
    test:assertEquals( false, frisk.progress( my_call ), "75% should be valid" );

    -- Invalid progress
    my_call.progress = "-1";
    local mistake1 = frisk.progress( my_call );
    test:assertEquals( "string", type(mistake1), "Negative numbers should be invalid" );
    
    my_call.progress = "101";
    local mistake2 = frisk.progress( my_call );
    test:assertEquals( "string", type(mistake2), ">100 should be invalid" );

    my_call.progress = "abc";
    local mistake3 = frisk.progress( my_call );
    test:assertEquals( "string", type(mistake3), "Non-numbers should be invalid" );
end

function test:test_frisk_enum()
    local my_call = setup_call();
    
    -- When parameter is empty or nil in my_call.named, it shouldn't frisk
    my_call.named.format = nil;
    test:assertEquals( false, frisk.format( my_call ), "Missing format in named should return false" );
    
    my_call.named.format = "";
    test:assertEquals( false, frisk.format( my_call ), "Empty format should return false" );

    -- Valid enum matches (when call.format is populated)
    my_call.named.format = "html";
    my_call.format = "Html"; -- Simulated normalization
    test:assertEquals( false, frisk.format( my_call ), "Valid enum should return false" );

    -- Invalid enum (when call.format is NOT populated but named is present)
    my_call.named.format = "invalid_enum";
    my_call.format = false; -- Simulated failed normalization
    local mistake = frisk.format( my_call );
    test:assertEquals( "string", type(mistake), "Invalid enum should return a mistake string" );
    
    -- Also test object as another enum
    my_call.named.object = "invalid_object";
    my_call.object = false;
    local mistake_obj = frisk.object( my_call );
    test:assertEquals( "string", type(mistake_obj), "Invalid object enum should return a mistake string" );
end

function test:test_frisk_html()
    local my_call = setup_call();

    my_call.named.definition = nil;
    test:assertEquals( false, frisk.definition( my_call ), "Empty HTML field should return false" );

    my_call.named.definition = "some text";
    my_call.definition = "<div><b>Valid HTML</b></div>";
    test:assertEquals( false, frisk.definition( my_call ), "Balanced HTML should return false" );

    my_call.definition = "<div><b>Unbalanced HTML</div>";
    local mistake1 = frisk.definition( my_call );
    test:assertEquals( "string", type(mistake1), "Missing closing tag should return a mistake string" );

    my_call.definition = "Unbalanced HTML</b>";
    local mistake2 = frisk.definition( my_call );
    test:assertEquals( "string", type(mistake2), "Missing opening tag should return a mistake string" );
end

function test:test_frisk_pagelist()
    local my_call = setup_call();

    my_call.collection = "Pagina Een, Pagina Twee";
    test:assertEquals( false, frisk.collection( my_call ), "Valid pagelist should return false" );

    my_call.collection = "Pagina [Een], Pagina Twee";
    local mistake1 = frisk.collection( my_call );
    test:assertEquals( "string", type(mistake1), "Invalid pagelist with brackets should return a mistake string" );
end

function test:test_frisk_dummy()
    local my_call = setup_call();
    test:assertEquals( false, frisk.reference( my_call ), "reference should always return false" );
    test:assertEquals( false, frisk.source( my_call ), "source should always return false" );
end

return test;
