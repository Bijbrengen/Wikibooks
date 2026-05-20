local test = {};
local CFG      = require( "Module:Layout/Production/Configuration" );
CFG.CONFIGURATION_TESTS = { "Include" };
CFG.INTERFACE_TESTS     = { "Flight", "Frisk", "Security" };
CFG.LIBRARY_TESTS       = { "Array", "Box", "Calculator", "Color", "Markup", "Pattern", "Text", "Timestamp", "Validation" };
CFG.MODEL_TESTS         = { "Call", "Convert" };
CFG.OBJECT_TESTS        = { "Logo" };
CFG.TESTED_BY           = "Tested by module [[Module:Layout/Production/Test/%s]].<br>\n";
CFG.TOTAL_OK            = "[[File:OOjs UI icon check-constructive.svg|20px|alt=Yes|link=]] There were no errors in the <b>%s</b> tests.\n";
CFG.TOTAL_FAILED        = "[[File:OOjs UI icon close-ltr-destructive.svg|20px|link=|alt=]] The total errors are <b>%s</b> in <b>%s</b> tests.\n";
CFG.TOTAL_TOTALS_OK     = "[[File:OOjs UI icon check-constructive.svg|20px|alt=Yes|link=]] All <b>%s</b> tests were succesfull!\n"
CFG.TOTAL_TOTALS_FAILED = "[[File:OOjs UI icon close-ltr-destructive.svg|20px|link=|alt=]] Of all <b>%s</b> tests <b>%s</b> have failed!\n"
local environment       = "Production";

function test.main( frame )
	local result = "";
	
    for index, value in ipairs( frame.args ) do
    	local testobject = CFG.INCLUDE( "production", "test/" .. value );
    	if testobject ~= nil and testobject.main( frame ) ~= nil then
            result = result .. testobject.main( frame );
        end
    end
    return result;
end

function test.collection( frame, collection )
	local result = {};
	local text = "";
	local total_fail = 0;
	local total_succes = 0;
    for index, value in ipairs( collection ) do
    	result[ value ] = {};
        local testobject = CFG.INCLUDE( "production", "test/" .. value );    
   	    if testobject ~= nil and testobject.main( frame ) ~= nil then
   	    	local wikitext, testdata  = testobject.main( frame );
   	    	text = text .. string.format( "==== %s ====\n", value );
		   	local title_path =  "Module:Layout/"   .. environment .. "/Test/" .. value;
		   	if mw.title.new( title_path ).exists then
                text = text .. string.format( CFG.TESTED_BY, value );
		   	end
   	    	text = text .. wikitext .. "\n";
   	    	total_fail = total_fail + testdata.failureCount;
   	    	total_succes = total_succes + testdata.successCount;
        end
    end
    
    local report = string.format( CFG.TOTAL_OK, tostring( total_fail + total_succes ) );
    if total_fail ~= 0 then
    	report = string.format( CFG.TOTAL_FAILED, tostring( total_fail ), tostring( total_fail + total_succes ) );
    end
    return report .. text, total_fail, total_succes;
end

function test.configuration( frame )
   return test.collection( frame, CFG.CONFIGURATION_TESTS );
end

function test.interface( frame )
   return test.collection( frame, CFG.INTERFACE_TESTS );
end

function test.library( frame )
   return test.collection( frame, CFG.LIBRARY_TESTS );
end

function test.model( frame )
   return test.collection( frame, CFG.MODEL_TESTS );
end

function test.object( frame )
   return test.collection( frame, CFG.OBJECT_TESTS );
end

function test.total (frame )
	local total_fail, total_succes, fail, succes = 0, 0, 0, 0;
	local wikitext, text = "", "";
	text = text .. "=== Configuration ===\n"
    wikitext, fail, succes = test.configuration( frame );
    total_fail = total_fail + fail;
    total_succes = total_succes + succes;
    text = text .. wikitext .. "\n";

	text = text .. "=== Interface ===\n"
    wikitext, fail, succes = test.interface( frame );
    total_fail = total_fail + fail;
    total_succes = total_succes + succes;
    text = text .. wikitext .. "\n";

    text = text .. "=== Library ===\n"
    wikitext, fail, succes = test.library( frame );
    total_fail = total_fail + fail;
    total_succes = total_succes + succes;
    text = text .. wikitext .. "\n";

    text = text .. "=== Model ===\n"
    wikitext, fail, succes = test.model( frame );
    total_fail = total_fail + fail;
    total_succes = total_succes + succes;
    text = text .. wikitext .. "\n";

    text = text .. "=== Object ===\n"
    wikitext, fail, succes = test.object( frame );
    total_fail = total_fail + fail;
    total_succes = total_succes + succes;
    text = text .. wikitext .. "\n";

    local report = string.format( CFG.TOTAL_TOTALS_OK, tostring( total_succes + total_fail ) );
    if total_fail ~= 0 then
    	report = string.format( CFG.TOTAL_TOTALS_FAILED, tostring( total_succes + total_fail ), tostring( total_fail ) );
    end

	return "== System ==\n" .. report .. text;
end

return test;
