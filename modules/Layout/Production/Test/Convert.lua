local test = {};

local CFG       = require("Module:Layout/Production/Configuration");
local convert   = CFG.INCLUDE( "production", "convert" );
local unittest  = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
    return test.run( frame );
end

function test:test_convert_date_to_age()
    self:assertEquals( ""     , convert.date_to_age(                            ), "Empty input" ); 
    self:assertEquals( ""     , convert.date_to_age( "32-01-2001"               ), "32-01-2001" ); 
    self:assertEquals( "0"    , convert.date_to_age( "01-01-3001"               ), "01-01-3001" ); 
    self:assertEquals( "22"   , convert.date_to_age( "01-01-2001"               ), "01-01-2001" ); 
    self:assertEquals( "0"    , convert.date_to_age( "01-01-2001", "01-01-2001" ), "01-01-2001, 01-01-2001" ); 
    self:assertEquals( "0"    , convert.date_to_age( "02-01-2001", "01-01-2001" ), "02-01-2001, 01-01-2001" ); 
    self:assertEquals( "0"    , convert.date_to_age( "02-01-2001", "01-01-2002" ), "02-01-2001, 01-01-2002" ); 
    self:assertEquals( "0"    , convert.date_to_age( "31-12-2001", "01-01-2002" ), "31-12-2001, 01-01-2002" ); 
    self:assertEquals( "1"    , convert.date_to_age( "31-12-2001", "31-12-2002" ), "31-12-2001, 31-12-2002" ); 
    self:assertEquals( "1"    , convert.date_to_age( "01-01-2001", "01-01-2002" ), "01-01-2001, 01-01-2002" ); 
end

function test:test_convert_template_to_table()
    self:assertDeepEquals( {}                , convert.template_to_table( "{{Test|One|Two", "Test" ), "Two but forgot }}" ); 
    self:assertDeepEquals( {}                , convert.template_to_table( "{{Test|One|t = Two", "Test" ), "t = Two but forgot }}" );
    self:assertDeepEquals( { "One" }         , convert.template_to_table( "{{Test|One}}", "Test" ), "One" );
    self:assertDeepEquals( { "One", "Two" }  , convert.template_to_table( "{{Test|One|Two}}", "Test" ), "Two" );
    self:assertDeepEquals( {"One" , t="Two" }, convert.template_to_table( "{{Test|One|t = Two}}", "Test" ), "t = Two" );
end

return test;
