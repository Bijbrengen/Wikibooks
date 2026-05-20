local test = {};

local CFG       = require("Module:Layout/Production/Configuration");
local call      = CFG.INCLUDE( "production", "call" );
local convert   = CFG.INCLUDE( "production", "convert" );
local unittest  = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
    return test.run( frame );
end

function test:test_convert_date_to_age()
    local my_call = call.init( CFG, "production" );
    my_call.unnamed = {};
    self:assertEquals( ""     , convert.date_to_age( my_call                    ), "Empty input" );
    my_call.unnamed = { "32-01-2001" };
    self:assertEquals( ""     , convert.date_to_age( my_call                    ), "32-01-2001" );
    my_call.unnamed = { "01-01-3001" };
    self:assertEquals( "0"    , convert.date_to_age( my_call                    ), "01-01-3001" );
    my_call.unnamed = { "01-01-2001" };
    self:assertEquals( "25"   , convert.date_to_age( my_call                    ), "01-01-2001" );
    my_call.unnamed = { "01-01-2001", "01-01-2001" };
    self:assertEquals( "0"    , convert.date_to_age( my_call ), "01-01-2001, 01-01-2001" );
    my_call.unnamed = { "02-01-2001", "01-01-2001" };
    self:assertEquals( "0"    , convert.date_to_age( my_call ), "02-01-2001, 01-01-2001" );
    my_call.unnamed = { "02-01-2001", "01-01-2002" };
    self:assertEquals( "0"    , convert.date_to_age( my_call ), "02-01-2001, 01-01-2002" );
    my_call.unnamed = { "31-12-2001", "01-01-2002" };
    self:assertEquals( "0"    , convert.date_to_age( my_call ), "31-12-2001, 01-01-2002" );
    my_call.unnamed = { "31-12-2001", "31-12-2002" };
    self:assertEquals( "1"    , convert.date_to_age( my_call ), "31-12-2001, 31-12-2002" );
    my_call.unnamed = { "01-01-2001", "01-01-2002" };
    self:assertEquals( "1"    , convert.date_to_age( my_call ), "01-01-2001, 01-01-2002" );
end

function test:test_convert_template_to_table()
    local my_call = call.init( CFG, "production" );
    self:assertDeepEquals( {}                , convert.template_to_table( "{{Test|One|Two", "Test", my_call ), "Two but forgot }}" );
    self:assertDeepEquals( {}                , convert.template_to_table( "{{Test|One|t = Two", "Test", my_call ), "t = Two but forgot }}" );
    self:assertDeepEquals( { "One" }         , convert.template_to_table( "{{Test|One}}", "Test", my_call ), "One" );
    self:assertDeepEquals( { "One", "Two" }  , convert.template_to_table( "{{Test|One|Two}}", "Test", my_call ), "Two" );
    self:assertDeepEquals( {"One" , t="Two" }, convert.template_to_table( "{{Test|One|t = Two}}", "Test", my_call ), "t = Two" );
end

return test;