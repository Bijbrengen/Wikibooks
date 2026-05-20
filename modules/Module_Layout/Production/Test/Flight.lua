local test = {}

local CFG        = require( "Module:Layout/Production/Configuration" );
local flight     = CFG.INCLUDE( "production", "flight" );
local unittest   = CFG.INCLUDE( "production", "unittest" );
local call       = CFG.INCLUDE( "production", "call" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

-- Safely mock mw.addWarning if running in a non-MediaWiki environment (like local CLI testing)
if not mw then
    _G.mw = { addWarning = function(msg) end }
elseif not mw.addWarning then
    mw.addWarning = function(msg) end
end

function test:test_flight_feedback()
    local my_call = call.init( CFG, "production" );
    my_call.message = {
        MISTAKE = {
            HEADER = "Mistake Header",
            EXPLANATION = "Mistake Explanation"
        },
        DEBUG = {
            HEADER = "Debug Header",
            EXPLANATION = "Debug Explanation"
        },
        HELP = {
            HEADER = "Help Header",
            EXPLANATION = "Help Explanation"
        }
    };
    
    -- Test case 1: support = "ignore" should return empty string regardless of other things
    my_call.pass = true;
    my_call.support = "ignore";
    local result1 = flight.feedback( my_call );
    test:assertEquals( "", result1, "feedback should return an empty string when support is 'ignore'" );

    -- Test case 2: pass = false, which forces support = "help". Mistake > 0.
    my_call.pass = false;
    my_call.support = "ignore"; -- Should be overwritten by pass = false
    my_call.mistake = { "Mistake 1" };
    my_call.debugging = { "Debug 1" };
    my_call.help = { "Help 1" };
    local result2 = flight.feedback( my_call );
    
    local expected_mistake = "<br><pre>MISTAKE HEADER:\n\n* Mistake 1\n\nMistake Explanation</pre><br>";
    local expected_debug   = "<br><pre>DEBUG HEADER:\n\n# Debug 1\n\nDebug Explanation</pre><br>";
    local expected_help    = "<br><pre>HELP HEADER:\n\n# Help 1\n\nHelp Explanation</pre><br>";
    
    test:assertEquals( expected_mistake .. expected_debug .. expected_help, result2, "feedback should combine mistake, debug, and help blocks when pass is false" );
    test:assertEquals( "help", my_call.support, "feedback should force support to 'help' if pass is false" );

    -- Test case 3: pass = true, support = "debug". No mistakes.
    my_call.pass = true;
    my_call.support = "debug";
    my_call.mistake = {};
    local result3 = flight.feedback( my_call );
    
    test:assertEquals( expected_debug, result3, "feedback should only return debug block if support is 'debug' and there are no mistakes" );
end

function test:test_flight_landed()
    local my_call = call.init( CFG, "production" );
    local result = flight.landed( my_call );
    test:assertEquals( "", result, "landed should return an empty string" );
end

function test:test_flight_takeoff()
    local my_call = call.init( CFG, "production" );
    
    -- Test case 1: mistakes exist, should return empty string
    my_call.mistake = { "A mistake" };
    local result1 = flight.takeoff( my_call );
    test:assertEquals( "", result1, "takeoff should return empty string when mistakes exist" );

    -- Test case 2: No mistakes, valid script execution
    my_call.mistake = {};
    my_call.object = "dummy_object";
    
    -- Mock the include function to return our test script
    my_call.include = function( object )
        if object == "dummy_object" then
            return {
                main = function( c ) return "Takeoff Successful!" end
            }
        end
        return ""
    end

    local result2 = flight.takeoff( my_call );
    test:assertEquals( "Takeoff Successful!", result2, "takeoff should execute the object script and return its result" );

    -- Test case 3: Include returns empty string (object not found)
    my_call.object = "unknown_object";
    local result3 = flight.takeoff( my_call );
    test:assertEquals( "", result3, "takeoff should return empty string if the object script is not found" );
end

return test;
