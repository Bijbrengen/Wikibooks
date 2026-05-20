local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local call     = CFG.INCLUDE( "production", "call" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
    return test.run( frame );
end

function test:test_add_new_debug()
    local my_call = call.init( CFG, "production" );
    my_call.add_new_debug( "New debug message" );
    local debug_messages = my_call.debugging;
    self:assertEquals( "New debug message", debug_messages[ #debug_messages ], "Adding a new debug message" );
end

function test:test_add_debug()
    local my_call = call.init( CFG, "production" );
    my_call.add_new_debug( "First debug message" );
    my_call.add_debug( "Second debug message" );
    local debug_messages = my_call.debugging;
    self:assertEquals( "First debug message<br><br>Second debug message", debug_messages[ #debug_messages ], "Appending a debug message" );
end

function test:test_add_new_mistake()
    local my_call = call.init( CFG, "production" );
    my_call.add_new_mistake( "New mistake message" );
    local mistake_messages = my_call.mistake;
    self:assertEquals( "New mistake message", mistake_messages[ #mistake_messages ], "Adding a new mistake message" );
end

function test:test_add_mistake()
    local my_call = call.init( CFG, "production" );
    my_call.add_new_mistake( "First mistake message" );
    my_call.add_mistake( "Second mistake message" );
    local mistake_messages = my_call.mistake;
    self:assertEquals( "First mistake message<br><br>Second mistake message", mistake_messages[ #mistake_messages ], "Appending a mistake message" );
end

function test:test_init()
    local environment = "test";
    local my_call = call.init( CFG, environment );
    self:assertEquals( environment, my_call.environment, "Setting environment" );
    self:assertFunction( my_call.include, "Setting include function" );
end

function test:test_init_state()
    local my_call = call.init( CFG, "production" );

    self:assertDeepEquals( {}, my_call.named, "Named parameters reset" );
    self:assertDeepEquals( {}, my_call.unnamed, "Unnamed parameters reset" );
    self:assertDeepEquals( {}, my_call.mistake, "Mistakes reset" );
    self:assertEquals( "The Call object has been initialized", my_call.debugging[1], "Debugging reset" );
    self:assertEquals( 1, #my_call.debugging, "Debugging length reset" );
    self:assertEquals( nil, my_call.object, "Dynamic fields reset" );
    self:assertTrue( my_call.pass, "Pass flag reset" );
    self:assertFunction( my_call.include, "Include function rebound" );
end

return test;