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
    local my_call = call.init( CFG, "production" );
    my_call.message = {
            DEBUG = {
                INVOKER = "INVOKER<br><br>%s<br><br>%s",
                NO_INTERFACE_TEMPLATE = "NO_INTERFACE_TEMPLATE"
            },
            MISTAKE = {
                NO_INTERFACE_TEMPLATE = "NO_INTERFACE_TEMPLATE"
            }
        };
    my_call.mistake  = {};
    my_call.debugging = {};
    my_call.template = "Template:Layout";
    my_call.invoker  = "Template:Layout";
    my_call.named = { key1 = "val1" };
    my_call.unnamed = { "val2" };

    local result1 = security.authentication( my_call );
    test:assertEquals( "Template:Layout", result1.invoker,  "Invoker should be 'Template:Layout'" );
    test:assertEquals( "Template:Layout", result1.template, "Template should be 'Template:Layout'" );
    test:assertDeepEquals(            {}, result1.mistake,  "There should be no mistakes for call1" );
    test:assertEquals( 1, #result1.debugging, "There should be 1 debug message for call1" );
    -- The debug message includes the output of report.debugging(call)
    test:assertEquals( "INVOKER<br><br>Template:Layout<br><br>{{#invoke:Layout|main|key1=val1|val2}}", result1.debugging[1], "Debug message should contain the reconstructed invoke string" );

    my_call.mistake  = {};
    my_call.debugging = {};
    my_call.template = "Template:Layout";
    my_call.invoker  = "Template:Wrong";
    my_call.named = nil;
    my_call.unnamed = nil;
    local result2 = security.authentication( my_call );

    test:assertEquals(               "Template:Wrong", result2.invoker,    "Invoker should be 'Template:Wrong'" );
    test:assertEquals(              "Template:Layout", result2.template,   "Template should be 'Template:Layout'" );
    test:assertDeepEquals( {"NO_INTERFACE_TEMPLATE",}, result2.mistake,    "Mistakes should be a table for call2" );
    test:assertEquals(                              1, #result2.mistake,   "There should be 1 mistake for call2" );
    test:assertEquals(        "NO_INTERFACE_TEMPLATE", result2.mistake[1], "The mistake for call2 should be 'NO_INTERFACE_TEMPLATE'" );
    test:assertEquals( 1, #result2.debugging, "There should be 1 debug message for call2" );
    test:assertEquals( "INVOKER<br><br>Template:Wrong<br><br>{{#invoke:Layout|main}}<br><br>NO_INTERFACE_TEMPLATE", result2.debugging[1], "Debug message should contain both the reconstructed invoke string and NO_INTERFACE_TEMPLATE" );
end

function test:test_security_invalid_call()
    -- security functions should return the input unchanged if call is invalid
    test:assertEquals( nil, security.authentication( nil ), "authentication should return nil for nil" );
    test:assertEquals( "string", security.declaration( "string" ), "declaration should return string for string" );
    test:assertDeepEquals( {}, security.frisk( {} ), "frisk should return empty table for empty table without include" );
    test:assertEquals( 123, security.scan( 123 ), "scan should return 123 for 123" );
end

function test:test_security_declaration()
    local my_call = call.init( CFG, "production" );
    -- Reset call object to a safe state before testing
    my_call.message = {
        MISTAKE = {
            WRONG = {
                INVOKE_PARAMETER = "Wrong invocation parameter '%s': '%s' with value '%s'"
            }
        }
    };
    my_call.hook = {
        PARAMETER = {"valid_param1", "valid_param2"}
    };
    my_call.named = {
        valid_param1 = "value1",
        valid_param2 = "value2",
        invalid_param = "value3"
    };
    my_call.mistake = {};

    -- Test when there's an invalid parameter
    local result = security.declaration( my_call );
    test:assertEquals( 1, #result.mistake, "There should be 1 mistake" );
    test:assertEquals(
        string.format( my_call.message.MISTAKE.WRONG.INVOKE_PARAMETER, "invalid_param", "invalid_param", "value3" ),
        result.mistake[1],
        "The mistake should report the invalid parameter"
    );

    -- Reset call object and test when all parameters are valid
    my_call.named = {
        valid_param1 = "value1",
        valid_param2 = "value2"
    };
    my_call.mistake = {};

    local result_valid = security.declaration( my_call );
    test:assertEquals( 0, #result_valid.mistake, "There should be no mistakes for valid parameters" );
end

function test:test_security_frisk()
    local my_call = call.init( CFG, "production" );
    my_call.hook = { PARAMETER = { "color", "format" } };
    my_call.named = {};
    my_call.named.format = "";
    my_call.message = {};
    my_call.message.HOOK = { FORMAT = { "Tekst", "HTML", "Koptekst", "Voettekst" }  };
    my_call.message.MISTAKE = {};
    my_call.message.MISTAKE.WRONG = {};
    my_call.message.MISTAKE.WRONG.COLOR = "Wrong color %s, %s, %s, %s, %s";
    my_call.message.MISTAKE.WRONG.FORMAT = "Wrong format %s, %s, %s";
    my_call.debugging = {};
    my_call.debugging[1] = "Init.";
    my_call.style = {};
    my_call.style.BLUE = "blue";
    my_call.style.ORANGE = "orange";
    my_call.style.PURPLE = "purple";    
    my_call.mistake = {};
    my_call.message.DEBUG = {
        VALUES_OK = "VALUES_OK",
        VALUE_MISTAKE = "VALUE_MISTAKE",
        VALUE_MISTAKES = "VALUE_MISTAKES"
    };
    my_call.color  = "#FFFFFF";
    my_call.format = "HTML";

    local result = security.frisk( my_call );

    test:assertDeepEquals( {}, result.mistake, "There should be no mistakes for valid parameters" );
    test:assertEquals( "Init.<br><br>VALUES_OK", result.debugging[1], "Debug message should be initialized for valid parameters" );

    my_call.color  = "fgxg";
    my_call.format = "HTML";
    my_call.named.format = "HTML";
    my_call.mistake = {};
    my_call.debugging = {};
    my_call.debugging[1] = "Init.";
    result = security.frisk( my_call );

    test:assertEquals( 1, #result.mistake, "There should be 1 mistake for invalid parameter1" );
    test:assertEquals( "Wrong color fgxg, fgxg, blue, orange, purple<br><br>VALUE_MISTAKE", result.mistake[1], "The mistake should be 'INVALID_PARAMETER1'" );

    my_call.color  = "#FFFFFF";
    my_call.format = false;
    my_call.named.format = "HTML5";
    my_call.mistake = {};
    my_call.debugging = {};
    my_call.debugging[1] = "Init.";
    result = security.frisk( my_call );

    test:assertEquals( 1, #result.mistake, "There should be 1 mistake for invalid parameter2" );
    test:assertEquals( "Wrong format Html5, HTML5, Tekst, HTML, Koptekst, Voettekst<br><br>VALUE_MISTAKE", result.mistake[1], "The mistake should be 'INVALID_PARAMETER2'" );

    my_call.color  = "fgxg";
    my_call.format = false;
    my_call.named.format = "html";
    my_call.mistake = {};
    my_call.debugging = {};
    my_call.debugging[1] = "Init.";
    result = security.frisk( my_call );

    test:assertEquals( 2, #result.mistake, "There should be 2 mistakes for both invalid parameters" );
    test:assertEquals( "Wrong color fgxg, fgxg, blue, orange, purple", result.mistake[1], "The first mistake should be 'INVALID_PARAMETER1'" );
    test:assertEquals( "Wrong format Html, html, Tekst, HTML, Koptekst, Voettekst<br><br>VALUE_MISTAKES", result.mistake[2], "The second mistake should be 'INVALID_PARAMETER2'" );
end;

function test:test_security_scan()
    local my_call = call.init( CFG, "production" );
    -- Because security.scan checks for environment == "production" to skip, we need to mock it
    my_call.environment = "test"
    my_call.hook = { PARAMETER = { "valid_param" } };
    my_call.message = {};

    my_call.color  = nil;
    my_call.format = nil;
     -- Reset call properties for the test
    my_call.named = {
        valid_param = "Some value",
        invalid_param = "Invalid value"
    };
    my_call.message.TEMPLATENAME = "TestTemplate";
    my_call.message.HOOK = {
        PARAMETER = { "valid_param" }
    };
    my_call.message.DEBUG = { CALLER = "", PARAMETER_MISTAKE = "Wrong parameter %s", PARAMETER_MISTAKES = "Wrong parameter %s", PARAMETERS_OK = "PARAMETERS_OK" };
    my_call.message.MISTAKE = {
            WRONG = {
                TEMPLATE_PARAMETER = "Wrong parameter '%s': '%s' with value '%s' should be %s";
            }
    };
    my_call.named.format = nil;
    my_call.mistake = {};
    my_call.debugging = {};
    my_call.debugging[1] = "Init.";
    my_call.caller = {};
    my_call.invoker = "Template:Test";
	local content = "{{TestTemplate|valid_param=Some value|invalid_param_scan=Invalid value}}"
    function my_call.caller:getContent()
	    -- Define the content to be returned by the getContent() function
	    return content
    end

    -- Run the security.scan function
    local result1 = security.scan( my_call );

    -- Check if the security scan correctly detected the invalid parameter
    test:assertEquals( "Wrong parameter 'invalid_param_scan': 'invalid_param_scan' with value 'Invalid value' should be valid_param", result1.mistake[1], "The security scan should detect the invalid parameter" );

    -- Test case 2
    my_call.named = {
        valid_param = "Some value",
    };
    my_call.mistake = {};

    content = "{{TestTemplate|valid_param=Some value}}";
    -- Run the security.scan function and check the result
    local result2 = security.scan( my_call );
    test:assertEquals(nil, result2.mistake[1], "The security scan should detect the invalid parameter for Test Case 2" );

    -- Test case 3
    my_call.named = {
        valid_param = "Some value",
        invalid_param2 = "Invalid value2"
    };
    my_call.mistake = {}; -- Reset my_call.mistake
    function my_call.caller:getContent()
        return "{{TestTemplate|valid_param=Some value|invalid_param_scan1=Invalid value1|invalid_param_scan2=Invalid value2}}"
    end

    -- Run the security.scan function and check the result
    local result3 = security.scan( my_call );
    test:assertEquals( "Wrong parameter 'invalid_param_scan1': 'invalid_param_scan1' with value 'Invalid value1' should be valid_param", result3.mistake[1], "The security scan should detect the invalid parameter for Test Case 3" );

    -- Test case 4: Unnamed parameters should be ignored
    my_call.named = {};
    my_call.mistake = {};
    function my_call.caller:getContent()
        return "{{TestTemplate|valid_param=Some value|UnnamedValue|1=AnotherValue}}"
    end
    local result4 = security.scan( my_call );
    test:assertEquals( nil, result4.mistake[1], "The security scan should ignore unnamed parameters (numeric keys)" );

    -- Test case 5: Production environment should bypass scanning
    my_call.environment = "production";
    my_call.mistake = {};
    function my_call.caller:getContent()
        return "{{TestTemplate|invalid_param_prod=Should be ignored}}"
    end
    local result5 = security.scan( my_call );
    test:assertEquals( nil, result5.mistake[1], "The security scan should be bypassed in production environment" );

end


return test;