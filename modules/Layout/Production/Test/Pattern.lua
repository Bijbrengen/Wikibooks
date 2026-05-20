local test = {};

local CFG      = require( "Module:Layout/Production/Configuration" );
local pattern  = CFG.INCLUDE( "production", "pattern" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_pattern_content_after_starting_equal_sign()
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( ""          ), "empty" );
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( "a"         ), "a" );
    self:assertEquals(   "" , pattern.content_after_starting_equal_sign( "="         ), "=" );
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( "a="        ), "a=" );
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( "a=b"       ), "a=" );
    self:assertEquals(   "" , pattern.content_after_starting_equal_sign( " = "       ), "SPACE=SPACE" );
    self:assertEquals(   "b", pattern.content_after_starting_equal_sign( "= b"       ), "= b" );
    self:assertEquals(   "b", pattern.content_after_starting_equal_sign( " = b"      ), "SPACE= b" );
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( "==b"       ), "==b" );
    self:assertEquals(   nil, pattern.content_after_starting_equal_sign( "===b"      ), "===b" );
    self:assertEquals(  "=b", pattern.content_after_starting_equal_sign( "= =b"      ), "= =b" );
end

function test:test_pattern_last_segment_of_url()
    self:assertEquals( ""   , pattern.last_segment_of_url( ""           ), "empty" );
    self:assertEquals( ""   , pattern.last_segment_of_url( "/"          ), "/" );
    self:assertEquals( ""   , pattern.last_segment_of_url( "a/"         ), "a/" );
    self:assertEquals( ""   , pattern.last_segment_of_url( "a//"        ), "a//" );
    self:assertEquals( ""   , pattern.last_segment_of_url( "//"         ), "//" );
    self:assertEquals( ""   , pattern.last_segment_of_url( "b//"        ), "//" );
    self:assertEquals( "b"  , pattern.last_segment_of_url( "/b"         ), "/b" );
    self:assertEquals( "v"  , pattern.last_segment_of_url( "/v/"        ), "/v/" );
    self:assertEquals( "v"  , pattern.last_segment_of_url( "//v"        ), "//v" );
end

function test:test_pattern_paramname()
	self:assertEquals(    nil, pattern.paramname( ""       ), "empty" );
	self:assertEquals(    nil, pattern.paramname( "=b"     ), "=b" );
	self:assertEquals(    nil, pattern.paramname( " =b"    ), "SPACE=b" );
	self:assertEquals(    nil, pattern.paramname( "= b"    ), "=SPACEb" );
	self:assertEquals(    nil, pattern.paramname( "a"      ), "a" );
	self:assertEquals(    nil, pattern.paramname( "a "     ), "aSPACE" );
	self:assertEquals(    "a", pattern.paramname( "a ="    ), "aSPACE=" );
	self:assertEquals(    "a", pattern.paramname( "a="     ), "a=" );
	self:assertEquals(    "a", pattern.paramname( "a=b"    ), "a=b" );
	self:assertEquals(    nil, pattern.paramname( "a==b"   ), "a==b" );
	self:assertEquals(    "a", pattern.paramname( "a= ==b" ), "a= ==b" );
	self:assertEquals(    nil, pattern.paramname( "==b"    ), "==b" );
	self:assertEquals(    "a", pattern.paramname( "a={{b}}"), "a={{b}}" );
end

function test:test_pattern_paramname_and_paramvalue()
	self:assertDeepEquals(    {nil,  ""}, pattern.paramname_and_paramvalue( ""       ), "empty" );
	self:assertDeepEquals(    {nil, "b"}, pattern.paramname_and_paramvalue( "=b"     ), "=b" );
	self:assertDeepEquals(    {nil, "b"}, pattern.paramname_and_paramvalue( " =b"    ), "SPACE=b" );
	self:assertDeepEquals(    {nil, "b"}, pattern.paramname_and_paramvalue( "= b"    ), "=SPACEb" );
	self:assertDeepEquals(    {nil, "a"}, pattern.paramname_and_paramvalue( "a"      ), "a" );
	self:assertDeepEquals(   {nil, "a "}, pattern.paramname_and_paramvalue( "a "     ), "aSPACE" );
	self:assertDeepEquals(    {"a",  ""}, pattern.paramname_and_paramvalue( "a ="    ), "aSPACE=" );
	self:assertDeepEquals(    {"a",  ""}, pattern.paramname_and_paramvalue( "a="     ), "a=" );
	self:assertDeepEquals(    {"a", "b"}, pattern.paramname_and_paramvalue( "a=b"    ), "a=b" );
	self:assertDeepEquals( {nil, "a==b"}, pattern.paramname_and_paramvalue( "a==b"   ), "a==b" );
	self:assertDeepEquals(  {"a", "==b"}, pattern.paramname_and_paramvalue( "a= ==b" ), "a= ==b" );
	self:assertDeepEquals(  {nil, "==b"}, pattern.paramname_and_paramvalue( "==b"    ), "==b" );
	self:assertDeepEquals({"a", "{{b}}"}, pattern.paramname_and_paramvalue( "a={{b}}"    ), "a={{b}}" );
end

function test:test_pattern_paramvalue()
	self:assertEquals(      "", pattern.paramvalue( ""       ), "empty" );
	self:assertEquals(     "b", pattern.paramvalue( "=b"     ), "=b" );
	self:assertEquals(     "b", pattern.paramvalue( " =b"    ), "SPACE=b" );
	self:assertEquals(     "b", pattern.paramvalue( "= b"    ), "=SPACEb" );
	self:assertEquals(     "a", pattern.paramvalue( "a"      ), "a" );
	self:assertEquals(    "a ", pattern.paramvalue( "a "     ), "aSPACE" );
	self:assertEquals(      "", pattern.paramvalue( "a ="    ), "aSPACE=" );
	self:assertEquals(      "", pattern.paramvalue( "a="     ), "a=" );
	self:assertEquals(     "b", pattern.paramvalue( "a=b"    ), "a=b" );
	self:assertEquals(  "a==b", pattern.paramvalue( "a==b"   ), "a==b" );
	self:assertEquals(   "==b", pattern.paramvalue( "a= ==b" ), "a= ==b" );
	self:assertEquals(   "==b", pattern.paramvalue( "==b"    ), "==b" );
	self:assertEquals( "{{b}}", pattern.paramvalue( "a={{b}}"), "a={{b}}" );
end

function test:test_pattern_remove_last_segment_from_url()
	self:assertEquals( ""   , pattern.remove_last_segment_from_url( ""           ), "empty" );
	self:assertEquals( ""   , pattern.remove_last_segment_from_url( "/"          ), '/' );
	self:assertEquals( " "  , pattern.remove_last_segment_from_url( " "          ), "SPACE" );
	self:assertEquals( " "  , pattern.remove_last_segment_from_url( " /"         ), "SPACE/" );
	self:assertEquals( "q"  , pattern.remove_last_segment_from_url( "q/"         ), 'q/' );
	self:assertEquals( "/"  , pattern.remove_last_segment_from_url( "//"         ), "//" );
	self:assertEquals( "/a" , pattern.remove_last_segment_from_url( "/a/"        ), "/a/" );
	self:assertEquals( "b"  , pattern.remove_last_segment_from_url( "b/c"        ), "b/c" );
end

function test:test_pattern_remove_template_definition()
	self:assertEquals( nil          , pattern.remove_template_definition( "Test", "" ),                    "empty template" );
	self:assertEquals( nil          , pattern.remove_template_definition( "", "Test" ),                    "empty text" );
	self:assertEquals( nil          , pattern.remove_template_definition( " ", "Test" ),                   "space text" );
	self:assertEquals( nil          , pattern.remove_template_definition( "Test", "Test" ),                "templatename" );
	self:assertEquals( nil          , pattern.remove_template_definition( "{{Test", "Test" ),              "template not closed" );
	self:assertEquals( nil          , pattern.remove_template_definition( "{{ Test}}", "Test" ),           "SPACE BEFORE DEFINITION" );
	self:assertEquals( ""           , pattern.remove_template_definition( "{{Test}}", "Test" ),            "no contents" );
	self:assertEquals( "|"          , pattern.remove_template_definition( "{{Test|}}", "Test" ),           "EMPTY UNNAMED PARAMETER" );
	self:assertEquals( "| "         , pattern.remove_template_definition( "{{Test| }}", "Test" ),          "EMPTY UNNAMED PARAMETER SPACE" );
	self:assertEquals( " | |"       , pattern.remove_template_definition( "{{Test | |}}", "Test" ),        "SPACE EMPTY UNNAMED PARAMETER" );
	self:assertEquals( " |ajkkjan\n", pattern.remove_template_definition( "{{Test |ajkkjan\n}}", "Test" ), "SPACE EMPTY UNNAMED PARAMETER" );
	self:assertEquals( "\n"         , pattern.remove_template_definition( "{{Test\n}}", "Test" ),          "SPACE EMPTY UNNAMED PARAMETER" );
	self:assertEquals( "\t"         , pattern.remove_template_definition( "{{Test\t}}", "Test" ),          "SPACE EMPTY UNNAMED PARAMETER" );
	self:assertEquals( nil          , pattern.remove_template_definition( "{{Test|{{Me}}", "Test" ),       "{{Test|{{Me}}" );
	self:assertEquals( "|{{Me}}"    , pattern.remove_template_definition( "{{Test|{{Me}}}}", "Test" ),     "{{Test|{{Me}}}}" );
	self:assertEquals( "|{{Test}}"  , pattern.remove_template_definition( "{{Test|{{Test}}}}", "Test" ),   "{{Test|{{Test}}}}" );
end

function test:test_pattern_replace_in_lines_that_start_with_a_character( text, start, search, replace )
    self:assertEquals( ""                     , pattern.replace_in_lines_that_start_with_a_character( ""         , "*", "|", "¦" ), "EMPTY TEXT" );
    self:assertEquals( "* 1 ¦"                , pattern.replace_in_lines_that_start_with_a_character( "* 1 |"    , "*", "|", "¦" ), "* 1 |" );
    self:assertEquals( "* 1 ¦\n|"             , pattern.replace_in_lines_that_start_with_a_character(  "* 1 |\n|", "*", "|", "¦" ), "* 1 |NEWLINE|" );
    self:assertEquals( "# 1 | 2"              , pattern.replace_in_lines_that_start_with_a_character( "# 1 | 2"  , "*", "|", "¦" ), "# 1 | 2" );
    self:assertEquals( "# 1 ¦ 2"              , pattern.replace_in_lines_that_start_with_a_character( "# 1 | 2"  , "#", "|", "¦" ), "# 1 | 2" );
    self:assertEquals( ": 1 ¦ 2 *"            , pattern.replace_in_lines_that_start_with_a_character( ": 1 | 2 *", ":", "|", "¦" ), ": 1 | 2 *" );
    self:assertEquals( " : 1 |"               , pattern.replace_in_lines_that_start_with_a_character( " : 1 |"   , ":", "|", "¦" ), " : 1 |" );
end

function test:test_pattern_replace_inner_pipes()
    self:assertEquals( "{{Test¦{{Test}}}}"    , pattern.replace_inner_pipes( "{{Test|{{Test}}}}", "Test" )   , "{{Test|{{Test}}}}" );
    self:assertEquals( "{{Test¦{{Test¦}}}}"   , pattern.replace_inner_pipes( "{{Test|{{Test|}}}}", "Test" )  , "{{Test|{{Test|}}}}" );
    self:assertEquals( "|{{Test¦{{Test}}}}"   , pattern.replace_inner_pipes( "|{{Test|{{Test}}}}", "Test" )  , "{{|Test|{{Test}}}}" );
    self:assertEquals( "{{¦}}"                , pattern.replace_inner_pipes( "{{|}}", "Test" )               , "{{|}}" );
    self:assertEquals( "|{¦{{Test}}¦}"        , pattern.replace_inner_pipes( "|{|{{Test}}|}", "Test" )       , "|{|{{Test}}|}" );
    self:assertEquals( "|{¦{{Test}}¦}"        , pattern.replace_inner_pipes( "|{|{{Test}}|}", "Test" )       , "|{|{{Test}}|}" );
    self:assertEquals( "|[[Test}}¦]]"         , pattern.replace_inner_pipes( "|[[Test}}|]]", "Test" )        , "|[[Test}}|]]" );
    self:assertEquals( "<nowiki>¦</nowiki>"   , pattern.replace_inner_pipes( "<nowiki>|</nowiki>", "Test" )  , "<nowiki>|</nowiki>" );
    self:assertEquals( "<nowiki¦>|</nowiki|"  , pattern.replace_inner_pipes( "<nowiki|>|</nowiki|", "Test" ) , "<nowiki|>|</nowiki|" );
    self:assertEquals( "<nowiki¦>¦</nowiki¦>" , pattern.replace_inner_pipes( "<nowiki|>|</nowiki|>", "Test" ), "<nowiki|>|</nowiki|>" );
    self:assertEquals( "* 1 ¦"                , pattern.replace_inner_pipes( "* 1 |", "Test" )               , "* 1 |" );
    self:assertEquals( "* 1 ¦\n|"             , pattern.replace_inner_pipes( "* 1 |\n|", "Test" )         , "* 1 |NEWLINE|" );
    self:assertEquals( "# 1 ¦ 2"              , pattern.replace_inner_pipes( "# 1 | 2", "Test" )             , "# 1 | 2" );
    self:assertEquals( ": 1 ¦ 2 *"            , pattern.replace_inner_pipes( ": 1 | 2 *", "Test" )           , ": 1 | 2 *" );
    self:assertEquals( " : 1 |"               , pattern.replace_inner_pipes( " : 1 |", "Test" )              , " : 1 |" );
    self:assertEquals( "|(Test¦}}¦)"          , pattern.replace_inner_pipes( "|(Test|}}|)", "Test" )         , "|(Test|}}|)" );
end

function test:test_pattern_split_paramname_from_the_rest()
	self:assertFalse( pattern.split_paramname_from_the_rest( ""        ), "empty" );
	self:assertFalse( pattern.split_paramname_from_the_rest( "_p rest" ), "_p rest" );
	self:assertFalse( pattern.split_paramname_from_the_rest( "_p rest" ), " p rest" );
	self:assertEquals( "para_m" , pattern.split_paramname_from_the_rest( "para_m"), "para_m" );
	local param, rest = pattern.split_paramname_from_the_rest( "p_ r");
	self:assertEquals( "p_", param, "param:p_ r" );
	self:assertEquals( " r", rest , "rest:p_ r" );
	param, rest = pattern.split_paramname_from_the_rest( "p/nr");
	self:assertEquals( "p"  , param, "param:p/nr" );
	self:assertEquals( "/nr", rest , "rest:p/nr" );
	param, rest = pattern.split_paramname_from_the_rest( "p	r");
	self:assertEquals( "p"    , param, "param:p/tr" );
	self:assertEquals( "	r", rest , "rest:p/tr" );
	param, rest = pattern.split_paramname_from_the_rest( "p r r2");
	self:assertEquals( "p"    , param, "param:p r r2" );
	self:assertEquals( " r r2", rest , "rest:p r r2" );
	param, rest = pattern.split_paramname_from_the_rest( "p2 r&r|2");
	self:assertEquals( "p2"    , param, "param:p2 r&r|2" );
	self:assertEquals( " r&r|2", rest , "rest:p2 r&r|2" );
end

function test:test_pattern_template_definition_at_start_and_end()
	self:assertFalse( pattern.template_definition_at_start_and_end( ""                      , "Test"), "empty" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "|"                     , "Test"), "|" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{"                    , "Test"), "{{" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "}}"                    , "Test"), "}}" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{|"                   , "Test"), "{{|" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Test"                , "Test"), "{{Test" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Test|"               , "Test"), "{{Test|" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Test   |"            , "Test"), "{{Test   |" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Testing}}"           , "Test"), "{{Testing}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test}}"              , "Test"), "{{Test}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test }}"             , "Test"), "{{Test }}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test|}}"             , "Test"), "{{Test|}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test | One}}"        , "Test"), "{{Test | One}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test|One}}"          , "Test"), "{{Test|One}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test|p=One}}"        , "Test"), "{{Test|p=One}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test	}}"             , "Test"), "{{Test	}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test\t|p=One}}"      , "Test"), "{{Test\t|p=One}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test\n|p=One}}"      , "Test"), "{{Test\n|p=One}}" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Test\n|p={{One}}"    , "Test"), "{{Test\n|p={{One}}" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{Test\n|p=One}}}}"    , "Test"), "{{Test\n|p=One}}}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test\n|p={{One}}}}"  , "Test"), "{{Test\n|p={{One}}}}" );
	self:assertFalse( pattern.template_definition_at_start_and_end( "{{One\n|p={{Test}}}}"  , "Test"), "{{One\n|p={{Test}}}}" );
	self:assertTrue(  pattern.template_definition_at_start_and_end( "{{Test\n|p={{Test}}}}" , "Test"), "{{Test\n|p={{Test}}}}" );
end

return test;
