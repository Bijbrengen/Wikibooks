local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local call     = CFG.INCLUDE( "production", "call" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
    return test.run( frame );
end

function test:test_add_new_debug()
    call.add_new_debug( "New debug message" );
    local debug_messages = call.debugging;
    self:assertEquals( "New debug message", debug_messages[ #debug_messages ], "Adding a new debug message" );
end

function test:test_add_debug()
    call.add_new_debug( "First debug message" );
    call.add_debug( "Second debug message" );
    local debug_messages = call.debugging;
    self:assertEquals( "First debug message<br><br>Second debug message", debug_messages[ #debug_messages ], "Appending a debug message" );
end

function test:test_add_new_mistake()
    call.add_new_mistake( "New mistake message" );
    local mistake_messages = call.mistake;
    self:assertEquals( "New mistake message", mistake_messages[ #mistake_messages ], "Adding a new mistake message" );
end

function test:test_add_mistake()
    call.add_new_mistake( "First mistake message" );
    call.add_mistake( "Second mistake message" );
    local mistake_messages = call.mistake;
    self:assertEquals( "First mistake message<br><br>Second mistake message", mistake_messages[ #mistake_messages ], "Appending a mistake message" );
end

function test:test_init()
    local environment = "test";
    call.init( CFG, environment );
    self:assertEquals( environment, call.environment, "Setting environment" );
    self:assertFunction( call.include, "Setting include function" );
end

function test:test_init_resets_state()
    call.named     = { object = "book" };
    call.unnamed   = { "old argument" };
    call.mistake   = { "old mistake" };
    call.debugging = { "old debug" };
    call.object    = "book";
    call.pass      = false;

    call.init( CFG, "production" );

    self:assertDeepEquals( {}, call.named, "Named parameters reset" );
    self:assertDeepEquals( {}, call.unnamed, "Unnamed parameters reset" );
    self:assertDeepEquals( {}, call.mistake, "Mistakes reset" );
    self:assertEquals( "The Call object has been initialized", call.debugging[1], "Debugging reset" );
    self:assertEquals( 1, #call.debugging, "Debugging length reset" );
    self:assertEquals( nil, call.object, "Dynamic fields reset" );
    self:assertTrue( call.pass, "Pass flag reset" );
    self:assertFunction( call.include, "Include function rebound" );
end

return test;
