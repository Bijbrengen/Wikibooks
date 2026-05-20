local test = {};

local CFG                = require("Module:Layout/Configuration");
local extract            = CFG.INCLUDE( "extract" );
local unittest           = CFG.LOAD.LIBRARY_TEST();
local testpath           = "Module:Layout/Test/Testcases/";

local testpage = {
	empty               = require( testpath .. "Empty_Page" ),                            -- Page has no content.
	corrupted_headings  = require( testpath .. "Corrupted_Headings" ),                    -- Page has only headings with text before or after the ==.
	four                = require( testpath .. "Four" ),                                  -- Page has four templates and headings
	one                 = require( testpath .. "One" ),                                   -- Page has only one two level header and one template.
	only_text           = require( testpath .. "Only_Text" ),                             -- Page has only text into it. No headings, templates or whatsoever.
	other               = require( testpath .. "Other" ),                                 -- Page has only other type of templates or headings.
	ten                 = require( testpath .. "Ten" ),                                   -- Page has ten headings and templates.
	two_hits            = require( testpath .. "Extract_Parameter_Two_Hits" ),            -- Page has a template with the testparameter.
	present             = require( testpath .. "Extract_Parameter_Present" ),             -- Page has the same template name multiple times.
	multiple_parameters = require( testpath .. "Extract_Parameter_Multiple_Parameters" ), -- Page has a template where the same parameter occurs multiple times.
	not_exist_path      = testpath .. "Does_Not_Exist",                                   -- Page is not existing.
	empty_path          = testpath .. "Empty",                                            -- Page has no content.
	only_text_path      = testpath .. "Empty Page"                                        -- Page has only text into it. No headings, templates or whatsoever.
}

test = unittest:new();

function test:test_Library_Extract_content()
	local only_text = [[return "";]];
	self:assertEquals( nil       , extract.content(                                ), "No titlename" );
	self:assertEquals( nil       , extract.content( ""                             ), "Empty titlename" );
	self:assertEquals( nil       , extract.content( testpath.not_exist_path        ), "Does not exist" );
	self:assertEquals( nil       , extract.content( testpath .. "{{wrongname}}"    ), "Wrong syntax titlename" );
	self:assertEquals( ""        , extract.content( testpage.empty_path            ), "Empty" );
	self:assertEquals( only_text , extract.content( testpage.only_text_path        ), "Some text" );
end

function test:test_Library_Extract_heading()
	local empty = {};
	local result1 = { "This one" };
	local result2 = { "One", "Two", "Three", "Four" };
	local result3 = { "1", "2", "3", "4", "5", "6", "7", "8", "9|", "10" };
    self:assertDeepEquals(  empty  , extract.heading( testpage.empty              ), "Empty page" );
    self:assertDeepEquals(  empty  , extract.heading( testpage.only_text          ), "No headings at all" );
    self:assertDeepEquals(  empty  , extract.heading( testpage.other              ), "Only other headings" );
    self:assertDeepEquals(  empty  , extract.heading( testpage.corrupted_headings ), "Corrupted headings" );
    self:assertDeepEquals(  result1, extract.heading( testpage.one                ), "One heading" );
    self:assertDeepEquals(  result2, extract.heading( testpage.four               ), "Four headings" );
    self:assertDeepEquals(  result3, extract.heading( testpage.ten                ), "Ten headings" );
end

function test:test_Library_Extract_parameter()
	local empty = {};
	local result1 = { '{{ xhajbcjh | {{ nakdssnk }} [[ | ]] }}' };
	local result2 = { "Ervoor", "Erna" };

	self:assertDeepEquals( empty  , extract.parameter( ""                           , "Test", "Testparameter" ), "Empty titlename" );
	self:assertDeepEquals( empty  , extract.parameter( "        "                   , "Test", "Testparameter" ), "Spaces titlename" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.two_hits            , nil   , "Testparameter" ), "No templatename" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.two_hits            , ""    , "Testparameter" ), "Empty templatename" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.two_hits            , "    ", "Testparameter" ), "Spaces templatename" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.present             , "    "                  ), "No parameter" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.present             , "    ", ""              ), "Empty parameter" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.present             , "    ", "    "          ), "Spaces parameter" );
	self:assertDeepEquals( empty  , extract.parameter( testpage.present             , "No"  , "Testparameter" ), "No parameter found" );
	self:assertDeepEquals( result1, extract.parameter( testpage.multiple_parameters , "Test", "Testparameter" ), "Meerdere templates. Eerste heeft geen parameters" );
	self:assertDeepEquals( result1, extract.parameter( testpage.present             , "Test", "Testparameter" ), "Parameter found" );
    self:assertDeepEquals( result2, extract.parameter( testpage.present             , "Test"                  ), "Parameter not specified" );
end

function test:test_Library_Extract_template()
	local input1  = [[{{Opmaak

| Object = Boek
| Bron = Humanature logo.jpg
| Beschrijving = Dit is een test voor het opmaken van een boek
| Voortgang = 5
| Collectie = Sjabloon:Opmaak
| Onderdeel = Sjabloon:Opmaak/Test/Logo
| Foutafhandeling = Debug
}}]];
	local result1 = { { "Before", "After", Testparameter = "{{ xhajbcjh | {{ nakdssnk }} [[ | ]] }}" } };
	local result2 = { { "Before", "After", Testparameter = "{{ xhajbcjh | {{ nakdssnk }} [[ | ]] }}" }, {"This"}, {"Before"}, { Testparameter  = "f{{Here}}f"} };
	local result3 = { {"1"}, {"2"}, {"3"}, {"4"}, {"5"}, {"6"}, {"7"}, {"8"}, {"9"}, {"10"} };
	local result4 = { { 
		Beschrijving = "Dit is een test voor het opmaken van een boek", 
		Bron = "Humanature logo.jpg", 
		Collectie = "Sjabloon:Opmaak",
        Foutafhandeling = "Debug",
        Object = "Boek",
        Onderdeel = "Sjabloon:Opmaak/Test/Logo",
        Voortgang = "5"
    },
}
    local no_template = {};

    self:assertDeepEquals({ {"One", t= "Two"} }             , extract.template( "{{Test|One|t = Two}}"           , "Test" )    , "{{Test|One|t = Two}}" );
    self:assertDeepEquals({ {"One", t= "{{Two}}"} }         , extract.template( "{{Test|One|t = {{Two}}}}"       , "Test" )    , "{{Test|One|t = {{Two}}}}" );
    self:assertDeepEquals({ {"One", t= "Two"} }             , extract.template( ",anc,a{{Test|One|t = Two}}cbshd", "Test" )    , ",anc,a{{Test|One|t = Two}}cbshd" );
    self:assertDeepEquals({ {"One", t= "Two"}, { "Three" } }, extract.template( ",anc,a{{Test|One|t = Two}}cbshd{{Test|Three}}", "Test" ), ",anc,a{{Test|One|t = Two}}cbshd{{Test|Three}}" );

    self:assertDeepEquals(  no_template, extract.template( testpage.empty              , "Test"   ), "Empty page" );
    self:assertDeepEquals(  no_template, extract.template( testpage.only_text          , "Test"   ), "No headings at all" );
    self:assertDeepEquals(  no_template, extract.template( testpage.other              , "Test"   ), "Only other headings" );
    self:assertDeepEquals(  no_template, extract.template( testpage.corrupted_headings , "Test"   ), "Corrupted headings" );
    self:assertDeepEquals(      result1, extract.template( testpage.one                , "Test"   ), "One template" );
    self:assertDeepEquals(      result2, extract.template( testpage.four               , "Test"   ), "Four templates" );
	self:assertDeepEquals(      result3, extract.template( testpage.ten                , "Test"   ), "Ten templates" );
	self:assertDeepEquals(      result4, extract.template( input1                      , "Opmaak" ), "Ten templates" );
end

return test;
