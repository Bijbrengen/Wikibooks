local test = {}

local CFG        = require( "Module:Layout/Production/Configuration" );
local security   = CFG.INCLUDE( "production", "security" );
local unittest   = CFG.INCLUDE( "production", "unittest" );
local call       = CFG.INCLUDE( "production", "call" );
local private = {};

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_security_authentication()
	call.message = {
            DEBUG = {
                INVOKER = "INVOKER",
                NO_INTERFACE_TEMPLATE = "NO_INTERFACE_TEMPLATE"
            },
            MISTAKE = {
                NO_INTERFACE_TEMPLATE = "NO_INTERFACE_TEMPLATE"
            }
        };
    call.mistake  = {};
    call.template = "Template:Layout";
    call.invoker  = "Template:Layout";

    local result1 = security.authentication( call );
    test:assertEquals( "Template:Layout", result1.invoker,  "Invoker should be 'Template:Layout'" );
    test:assertEquals( "Template:Layout", result1.template, "Template should be 'Template:Layout'" );
    test:assertDeepEquals(            {}, result1.mistake,  "There should be no mistakes for call1" );

    call.mistake  = {};
    call.template = "Template:Layout";
    call.invoker  = "Template:Wrong";
    local result2 = security.authentication( call );

    test:assertEquals(               "Template:Wrong", result2.invoker,    "Invoker should be 'Template:Wrong'" );
    test:assertEquals(              "Template:Layout", result2.template,   "Template should be 'Template:Layout'" );
    test:assertDeepEquals( {"NO_INTERFACE_TEMPLATE",}, result2.mistake,    "Mistakes should be a table for call2" );
    test:assertEquals(                              1, #result2.mistake,   "There should be 1 mistake for call2" );
    test:assertEquals(        "NO_INTERFACE_TEMPLATE", result2.mistake[1], "The mistake for call2 should be 'NO_INTERFACE_TEMPLATE'" );
end

function test:test_security_declaration()
	call.init( CFG, "production" );
    -- Reset call object to a safe state before testing
    call.message = {
        MISTAKE = {
            WRONG = {
                INVOKE_PARAMETER = "Wrong invocation parameter '%s': '%s' with value '%s'"
            }
        }
    };
    call.hook = {
        PARAMETER = {"valid_param1", "valid_param2"}
    };
    call.named = {
        valid_param1 = "value1",
        valid_param2 = "value2",
        invalid_param = "value3"
    };
    call.mistake = {};

    -- Test when there's an invalid parameter
    local result = security.declaration( call );
    test:assertEquals( 1, #result.mistake, "There should be 1 mistake" );
    test:assertEquals(
        string.format( call.message.MISTAKE.WRONG.INVOKE_PARAMETER, "invalid_param", "invalid_param", "value3" ),
        result.mistake[1],
        "The mistake should report the invalid parameter"
    );

    -- Reset call object and test when all parameters are valid
    call.named = {
        valid_param1 = "value1",
        valid_param2 = "value2"
    };
    call.mistake = {};

    local result_valid = security.declaration( call );
    test:assertEquals( 0, #result_valid.mistake, "There should be no mistakes for valid parameters" );
end

function test:test_security_frisk()
    call.hook = { PARAMETER = { "color", "format" } };
    call.named = {};
    call.named.format = "";
    call.message = {};
    call.message.HOOK = { FORMAT = { "Tekst", "HTML", "Koptekst", "Voettekst" }  };
    call.message.MISTAKE = {};
    call.message.MISTAKE.WRONG = {};
    call.message.MISTAKE.WRONG.COLOR = "Wrong color %s, %s, %s, %s, %s";
    call.message.MISTAKE.WRONG.FORMAT = "Wrong format %s, %s, %s";
    call.debugging = {};
    call.debugging[1] = "Init.";
    call.style = {};
    call.style.BLUE = "blue";
    call.style.ORANGE = "orange";
    call.style.PURPLE = "purple";    
    call.mistake = {};
    call.message.DEBUG = {
        VALUES_OK = "VALUES_OK",
        VALUE_MISTAKE = "VALUE_MISTAKE",
        VALUE_MISTAKES = "VALUE_MISTAKES"
    };
    call.color  = "#FFFFFF";
    call.format = "HTML";

    local result = security.frisk( call );

    test:assertDeepEquals( {}, result.mistake, "There should be no mistakes for valid parameters" );
    test:assertEquals( "Init.<br><br>VALUES_OK", result.debugging[1], "Debug message should be initialized for valid parameters" );

    call.color  = "fgxg";
    call.format = "HTML";
    call.named.format = "HTML";
    call.mistake = {};
    call.debugging = {};
    call.debugging[1] = "Init.";
    result = security.frisk( call );

    test:assertEquals( 1, #result.mistake, "There should be 1 mistake for invalid parameter1" );
    test:assertEquals( "Wrong color fgxg, fgxg, blue, orange, purple<br><br>VALUE_MISTAKE", result.mistake[1], "The mistake should be 'INVALID_PARAMETER1'" );

    call.color  = "#FFFFFF";
    call.format = false;
    call.named.format = "HTML5";
    call.mistake = {};
    call.debugging = {};
    call.debugging[1] = "Init.";
    result = security.frisk( call );

    test:assertEquals( 1, #result.mistake, "There should be 1 mistake for invalid parameter2" );
    test:assertEquals( "Wrong format Html5, HTML5, Tekst, HTML, Koptekst, Voettekst<br><br>VALUE_MISTAKE", result.mistake[1], "The mistake should be 'INVALID_PARAMETER2'" );

    call.color  = "fgxg";
    call.format = false;
    call.named.format = "html";
    call.mistake = {};
    call.debugging = {};
    call.debugging[1] = "Init.";
    result = security.frisk( call );

    test:assertEquals( 2, #result.mistake, "There should be 2 mistakes for both invalid parameters" );
    test:assertEquals( "Wrong color fgxg, fgxg, blue, orange, purple", result.mistake[1], "The first mistake should be 'INVALID_PARAMETER1'" );
    test:assertEquals( "Wrong format Html, html, Tekst, HTML, Koptekst, Voettekst<br><br>VALUE_MISTAKES", result.mistake[2], "The second mistake should be 'INVALID_PARAMETER2'" );
end;

function test:test_security_scan()
    call.init( CFG, "production" );
    call.hook = { PARAMETER = { "valid_param" } };
    call.message = {};

    call.color  = nil;
    call.format = nil;
     -- Reset call properties for the test
    call.named = {
        valid_param = "Some value",
        invalid_param = "Invalid value"
    };
    call.message.TEMPLATENAME = "TestTemplate";
    call.message.HOOK = {
        PARAMETER = { "valid_param" }
    };
    call.message.DEBUG = { CALLER = "", PARAMETER_MISTAKE = "Wrong parameter %s", PARAMETER_MISTAKES = "Wrong parameter %s" };
    call.message.MISTAKE = {
            WRONG = {
                TEMPLATE_PARAMETER = "Wrong parameter '%s': '%s' with value '%s' should be %s";
            }
    };
    call.named.format = nil;
    call.mistake = {};
    call.debugging = {};
    call.debugging[1] = "Init.";
    call.caller = {};
	local content = "{{TestTemplate|valid_param=Some value|invalid_param_scan=Invalid value}}"
    function call.caller:getContent()
	    -- Define the content to be returned by the getContent() function
	    return content
    end

    -- Run the security.scan function
    local result1 = security.scan( call );

    -- Check if the security scan correctly detected the invalid parameter
    test:assertEquals( "Wrong parameter 'invalid_param_scan': 'invalid_param_scan' with value 'Invalid value' should be valid_param", result1.mistake[1], "The security scan should detect the invalid parameter" );

    -- Test case 2
    call.named = {
        valid_param = "Some value",
    };
    call.mistake = {};

    content = "{{TestTemplate|valid_param=Some value}}";
    -- Run the security.scan function and check the result
    local result2 = security.scan( call );
    test:assertEquals(nil, result2.mistake[1], "The security scan should detect the invalid parameter for Test Case 2" );

    -- Test case 2
    call.named = {
        valid_param = "Some value",
        invalid_param2 = "Invalid value2"
    };
    call.mistake = {}; -- Reset call.mistake
    function call.caller:getContent()
        return "{{TestTemplate|valid_param=Some value|invalid_param_scan1=Invalid value1|invalid_param_scan2=Invalid value2}}"
    end

    -- Run the security.scan function and check the result
    local result2 = security.scan( call );
    test:assertEquals( "Wrong parameter 'invalid_param_scan1': 'invalid_param_scan1' with value 'Invalid value1' should be valid_param", result2.mistake[1], "The security scan should detect the invalid parameter for Test Case 2" );

end


return test;
