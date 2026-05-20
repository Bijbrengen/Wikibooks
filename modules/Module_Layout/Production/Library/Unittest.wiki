-- This module creates a simple unit testing framework that allows you to define and run test functions, and then displays the results in a specified format.


-------------------------------------------------------------------------------
-- Unit tests for Scribunto.
-------------------------------------------------------------------------------
require('strict')

local DebugHelper = {}
local unittest = {}

-- The CFG table contains all localisable strings and configuration, to make it
-- easier to port this module to another wiki.
local CFG = {};

-- Categories --
CFG.CATEGORY = {};
CFG.CATEGORY.TEST_FAILURE = nil;

-- Indicators
CFG.TEST_FAILURE_SUMMARY  = "'''$1 {{PLURAL:$1|test|tests}} mislukt'''.";
CFG.TEST_SUCCESS_MULTIPLE = "All %s tests are ok.";
CFG.TEST_SUCCESS_SINGLE   = "The only test is ok.";

-- String formats
CFG.TEST_FORMAT_SHORT_RESULTS = "succesvol: %d, fout: %d, overgeslagen: %d";

-- Test
CFG.TEST_COLUMN_ACTUAL   = "Actual";
CFG.TEST_COLUMN_EXPECTED = "Expected";
CFG.TEST_COLUMN_NAME     = "Name";

CFG.FAILURE_INDICATOR           = '[[File:OOjs UI icon close-ltr-destructive.svg|20px|link=|alt=]]<span style="display:none">N</span>';
CFG.SUCCESS_INDICATOR           = '[[File:OOjs UI icon check-constructive.svg|20px|alt=Yes|link=]]';


-------------------------------------------------------------------------------
-- Concatenates keys and values, ideal for displaying a template argument table.
-- @param keySeparator glue between key and value (defaults to " = ")
-- @param separator glue between different key-value pairs (defaults to ", ")
-- @example concatWithKeys({a = 1, b = 2, c = 3}, ' => ', ', ') => "a => 1, b => 2, c => 3"
-- 
function DebugHelper.concatWithKeys(table, keySeparator, separator)
    keySeparator = keySeparator or ' = '
    separator = separator or ', '
    local concatted = ''
    local i = 1
    local first = true
    local unnamedArguments = true
    for k, v in pairs(table) do
        if first then
            first = false
        else
            concatted = concatted .. separator
        end
        if k == i and unnamedArguments then
            i = i + 1
            concatted = concatted .. tostring(v)
        else
            unnamedArguments = false
            concatted = concatted .. tostring(k) .. keySeparator .. tostring(v)
        end
    end
    return concatted
end

-------------------------------------------------------------------------------
-- Compares two tables recursively (non-table values are handled correctly as well).
-- @param ignoreMetatable if false, t1.__eq is used for the comparison
-- 
function DebugHelper.deepCompare(t1, t2, ignoreMetatable)
    local type1 = type(t1)
    local type2 = type(t2)

    if type1 ~= type2 then 
        return false 
    end
    if type1 ~= 'table' then 
        return t1 == t2 
    end

    local metatable = getmetatable(t1)
    if not ignoreMetatable and metatable and metatable.__eq then 
        return t1 == t2 
    end

    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not DebugHelper.deepCompare(v1, v2) then 
            return false 
        end
    end
    for k2, v2 in pairs(t2) do
        if t1[k2] == nil then 
            return false 
        end
    end

    return true
end

-------------------------------------------------------------------------------
-- Raises an error with stack information
-- @param details a table with error details
--        - should have a 'text' key which is the error message to display
--        - a 'trace' key will be added with the stack data
--        - and a 'source' key with file/line number
--        - a metatable will be added for error handling
-- 
function DebugHelper.raise(details, level)
    level = (level or 1) + 1
    details.trace = debug.traceback('', level)
    details.source = string.match(details.trace, '^%s*stack traceback:%s*(%S*: )')

--    setmetatable(details, {
--        __tostring: function() return details.text end
--    })

    error(details, level)
end

-------------------------------------------------------------------------------
-- when used in a test, that test gets ignored, and the skipped count increases by one.
-- 
function unittest:markTestSkipped()
    DebugHelper.raise({unittest = true, skipped = true}, 3)
end

-------------------------------------------------------------------------------
-- Checks that the input is true
-- @param message optional description of the test
-- 
function unittest:assertTrue(actual, message)
    if not actual then
        DebugHelper.raise({unittest = true, text = string.format("Failed to assert that %s is true", tostring(actual)), message = message}, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that the input is false
-- @param message optional description of the test
-- 
function unittest:assertFalse( actual, message )
    if actual then
        DebugHelper.raise({unittest = true, text = string.format("Failed to assert that %s is false", tostring(actual)), message = message}, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that the output is a function
-- @param message optional description of the test
-- 
function unittest:assertFunction( func, message )
    if type(func) ~= 'function' then
        DebugHelper.raise({
            unittest = true,
            text = string.format( "Failed to assert that %s is a function", tostring( func ) ),
            actual = func,
            expected = 'function',
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks an input string contains the expected string
-- @param message optional description of the test
-- @param plain search is made with a plain string instead of a ustring pattern
-- 
function unittest:assertStringContains(pattern, s, plain, message)
	if type(pattern) ~= 'string' then
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format("Pattern type error (expected string, got %s)", type(pattern)),
			message = message
		}, 2)
	end
	if type(s) ~= 'string' then
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format("String type error (expected string, got %s)", type(s)),
			message = message
		}, 2)
	end
	if not mw.ustring.find(s, pattern, nil, plain) then
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format('Failed to find %s "%s" in string "%s"', plain and "plain string" or "pattern", pattern, s),
			message = message
		}, 2)
	end
end

-------------------------------------------------------------------------------
-- Checks an input string doesn't contain the expected string
-- @param message optional description of the test
-- @param plain search is made with a plain string instead of a ustring pattern
-- 
function unittest:assertNotStringContains(pattern, s, plain, message)
	if type(pattern) ~= 'string' then
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format("Pattern type error (expected string, got %s)", type(pattern)),
			message = message
		}, 2)
	end
	if type(s) ~= 'string' then
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format("String type error (expected string, got %s)", type(s)),
			message = message
		}, 2)
	end
	local i, j = mw.ustring.find(s, pattern, nil, plain)
	if i then
		local match = mw.ustring.sub(s, i, j)
		DebugHelper.raise({
			unittest = true,
			text = mw.ustring.format('Found match "%s" for %s "%s"', match, plain and "plain string" or "pattern", pattern),
			message = message
		}, 2)
	end
end

-------------------------------------------------------------------------------
-- Checks that an input has the expected value.
-- @param message optional description of the test
-- @example assertEquals(4, add(2,2), "2+2 should be 4")
-- 
function unittest:assertEquals(expected, actual, message)

	if type(expected) == 'number' and type(actual) == 'number' then
        self:assertWithinDelta(expected, actual, 1e-8, message)

	elseif expected ~= actual then
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %s equals expected %s", tostring(actual), tostring(expected)), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end

end

-------------------------------------------------------------------------------
-- Checks that 'actual' is within 'delta' of 'expected'.
-- @param message optional description of the test
-- @example assertEquals(1/3, 9/3, "9/3 should be 1/3", 0.000001)
function unittest:assertWithinDelta(expected, actual, delta, message)
    if type(expected) ~= "number" then
        DebugHelper.raise({
            unittest = true,
            text = string.format("Expected value %s is not a number", tostring(expected)),
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
    if type(actual) ~= "number" then
        DebugHelper.raise({
            unittest = true,
            text = string.format("Actual value %s is not a number", tostring(actual)),
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
    local diff = expected - actual
    if diff < 0 then diff = - diff end  -- instead of importing math.abs
    if diff > delta then
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %f is within %f of expected %f", actual, delta, expected), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a table has the expected value (including sub-tables).
-- @param message optional description of the test
-- @example assertDeepEquals({{1,3}, {2,4}}, partition(odd, {1,2,3,4}))
function unittest:assertDeepEquals(expected, actual, message)
    if not DebugHelper.deepCompare(expected, actual) then
        if type(expected) == 'table' then
            expected = mw.dumpObject(expected)
        end
        if type(actual) == 'table' then
            actual = mw.dumpObject(actual)
        end
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %s equals expected %s", tostring(actual), tostring(expected)), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a wikitext gives the expected result after processing.
-- @param message optional description of the test
-- @example assertResultEquals("Hello world", "{{concat|Hello|world}}")
function unittest:assertResultEquals(expected, text, message)
    local frame = self.frame
    local actual = frame:preprocess(text)
    if expected ~= actual then
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %s equals expected %s after preprocessing", text, tostring(expected)), 
            actual = actual,
            actualRaw = text,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that two wikitexts give the same result after processing.
-- @param message optional description of the test
-- @example assertSameResult("{{concat|Hello|world}}", "{{deleteLastChar|Hello world!}}")
function unittest:assertSameResult(text1, text2, message)
    local frame = self.frame
    local processed1 = frame:preprocess(text1)
    local processed2 = frame:preprocess(text2)
    if processed1 ~= processed2 then
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %s equals expected %s after preprocessing", processed1, processed2), 
            actual = processed1,
            actualRaw = text1,
            expected = processed2,
            expectedRaw = text2,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a template gives the expected output.
-- @param message optional description of the test
-- @example assertTemplateEquals("Hello world", "concat", {"Hello", "world"})
function unittest:assertTemplateEquals(expected, template, args, message)
    local frame = self.frame
    local actual = frame:expandTemplate{ title = template, args = args}
    if expected ~= actual then
        DebugHelper.raise({
            unittest = true, 
            text = string.format("Failed to assert that %s with args %s equals expected %s after preprocessing", 
                                 DebugHelper.concatWithKeys(args), template, expected),
            actual = actual,
            actualRaw = template,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks whether a function throws an error
-- @param fn the function to test
-- @param expectedMessage optional the expected error message
-- @param message optional description of the test
function unittest:assertThrows(fn, expectedMessage, message)
    local succeeded, actualMessage = pcall(fn)
    if succeeded then
        DebugHelper.raise({
            unittest = true,
            text = 'Expected exception but none was thrown',
            message = message,
        }, 2)
    end
	-- For strings, strip the line number added to the error message
    actualMessage = type(actualMessage) == 'string' 
    	and string.match(actualMessage, 'Module:[^:]*:[0-9]*: (.*)')
    	or actualMessage
    local messagesMatch = DebugHelper.deepCompare(expectedMessage, actualMessage)
    if expectedMessage and not messagesMatch then
        DebugHelper.raise({
            unittest = true,
            expected = expectedMessage,
            actual = actualMessage,
            text = string.format('Expected exception with message %s, but got message %s', 
                tostring(expectedMessage), tostring(actualMessage)
            ),
            message = message
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks whether a function doesn't throw an error
-- @param fn the function to test
-- @param message optional description of the test
function unittest:assertDoesNotThrow(fn, message)
	local succeeded, actualMessage = pcall(fn)
	if succeeded then
	    return
	end
	-- For strings, strip the line number added to the error message
	actualMessage = type(actualMessage) == 'string' 
		and string.match(actualMessage, 'Module:[^:]*:[0-9]*: (.*)')
		or actualMessage
	DebugHelper.raise({
		unittest = true,
		actual = actualMessage,
		text = string.format('Expected no exception, but got exception with message %s',
			tostring(actualMessage)
		),
		message = message
	}, 2)
end

-------------------------------------------------------------------------------
-- Creates a new test suite.
-- The new function takes an optional table as an argument,
-- which can contain test functions, and sets the metatable of the new object to inherit from the unittest table. 
-- Metatables are special tables that can define and control the behavior of other tables through metamethods.
-- The __index metamethod is used to define the default behavior when attempting to access a key that does not exist in the table.
-- In this case, the __index metamethod is set to self, which refers to the unittest table, 
-- effectively making the unittest table a fallback for the test_functions.
-- The run function is added as a method to the new test suite object.
-- When we create a new test suite object with unittest:new(), 
-- the metatable is set up so that the new object inherits methods from the unittest table.
-- If a method is not found in the new object, Lua will search for it in the unittest table, 
-- allowing to call methods like test.run() even though the run() method is actually defined in the unittest table.
function unittest:new( test_functions )
    test_functions = test_functions or {};
    setmetatable( test_functions, { __index = self } );
    test_functions.run = function( frame ) return self:run( test_functions, frame ); end
    return test_functions;
end

-------------------------------------------------------------------------------
-- Resets global counters
-- 
function unittest:init(frame)
    self.frame = frame or mw.getCurrentFrame()
    self.successCount = 0
    self.failureCount = 0
    self.skipCount = 0
    self.results = {}
end

-------------------------------------------------------------------------------
-- Runs a single testcase
-- @param name test nume
-- @param test function containing assertions
-- 
function unittest:runTest(suite, name, test)
    local success, details = pcall(test, suite)
    
    if success then
        self.successCount = self.successCount + 1
        table.insert(self.results, {name = name, success = true})
    elseif type(details) ~= 'table' or not details.unittest then -- a real error, not a failed assertion
        self.failureCount = self.failureCount + 1
        table.insert(self.results, {name = name, error = true, message = 'Lua error -- ' .. tostring(details)})
    elseif details.skipped then
        self.skipCount = self.skipCount + 1
        table.insert(self.results, {name = name, skipped = true})
    else
        self.failureCount = self.failureCount + 1
        local message = details.source
        if details.message then
            message = message .. details.message .. "\n"
        end
        message = message .. details.text
        table.insert(self.results, {name = name, error = true, message = message, expected = details.expected, actual = details.actual, testname = details.message})
    end
end

-------------------------------------------------------------------------------
-- Runs all tests and displays the results.
-- 
function unittest:runSuite(suite, frame)
    self:init(frame)
	local names = {}
    for name in pairs(suite) do
        if name:find('^test') then
			table.insert(names, name)
        end
    end
	table.sort(names) -- Put tests in alphabetical order.
	for i, name in ipairs(names) do
		local func = suite[name]
		self:runTest(suite, name, func)
	end
    return {
        successCount = self.successCount,
        failureCount = self.failureCount,
        skipCount = self.skipCount,
        results = self.results,
    }
end

-------------------------------------------------------------------------------
-- #invoke entry point for running the tests.
-- Can be called without a frame, in which case it will use mw.log for output
-- @param displayMode see displayResults()
-- 
function unittest:run(suite, frame)
    local testData = self:runSuite(suite, frame)
    if frame and frame.args then
        return self:displayResults(testData, frame.args.displayMode or 'table'), testData
    else
        return self:displayResults(testData, 'log'), testData
    end
end

-------------------------------------------------------------------------------
-- Displays test results 
-- @param displayMode: 'table', 'log' or 'short'
-- 
function unittest:displayResults(testData, displayMode)
    if displayMode == 'table' then
        return self:displayResultsAsTable(testData)
    elseif displayMode == 'log' then
        return self:displayResultsAsLog(testData)
    elseif displayMode == 'short' then
        return self:displayResultsAsShort(testData)
    else
        error('unknown display mode')
    end
end

function unittest:displayResultsAsLog(testData)
    if testData.failureCount > 0 then
        mw.log('FAILURES!!!')
    elseif testData.skipCount > 0 then
        mw.log('Some tests could not be executed without a frame and have been skipped. Invoke this test suite as a template to run all tests.')
    end
    mw.log(string.format('Assertions: success: %d, error: %d, skipped: %d', testData.successCount, testData.failureCount, testData.skipCount))
    mw.log('-------------------------------------------------------------------------------')
    for _, result in ipairs(testData.results) do
        if result.error then
            mw.log(string.format('%s: %s', result.name, result.message))
        end
    end
end

function unittest:displayResultsAsShort(testData)
    local text = string.format( CFG.TEST_FORMAT_SHORT_RESULTS, testData.successCount, testData.failureCount, testData.skipCount)
    if testData.failureCount > 0 then
        text = '<span class="error">' .. text .. '</span>'
    end
    return text
end

function unittest:displayResultsAsTable( testData )
    local successIcon, failIcon = self.frame:preprocess( CFG.SUCCESS_INDICATOR ), self.frame:preprocess( CFG.FAILURE_INDICATOR );
    local testtable = mw.html.create( 'table' )
        :addClass( 'wikitable' )
        :css( 'width', '100%' )
        :css( 'max-width', '100%' )
        :css( 'background-color', '#E8E4EF' )
        :css( 'color', 'black' );

    -- Header row
    testtable:tag( 'tr' )
        :tag( 'th' ):css( 'background-color', '#BBAFD1' ):css( 'color', 'black' ):done()
        :tag( 'th' ):css( 'background-color', '#BBAFD1' ):css( 'color', 'black' ):wikitext( CFG.TEST_COLUMN_NAME ):done()
        :tag( 'th' ):css( 'background-color', '#BBAFD1' ):css( 'color', 'black' ):wikitext( CFG.TEST_COLUMN_EXPECTED ):done()
        :tag( 'th' ):css( 'background-color', '#BBAFD1' ):css( 'color', 'black' ):wikitext( CFG.TEST_COLUMN_ACTUAL ):done();

    for _, result in ipairs( testData.results ) do
        local row = testtable:tag( 'tr' );
        row:addClass( result.error and 'test-result-error' or 'test-result-success' );

        row:tag( 'td' ):addClass( 'test-status-icon' ):wikitext( result.error and failIcon or successIcon ):done()

        if result.error then
            row:tag( 'td' ):addClass( 'test-name' ):wikitext( result.name .. "/" .. tostring( result.testname ) ):done();
            if result.expected and result.actual then
                row:tag( 'td' )
                    :css( 'overflow-wrap', 'break-word' )
                    :css( 'word-break', 'break-all' )
                    :css( 'font-family', 'monospace, monospace' )
                    :css( 'white-space', 'pre-wrap' )
                    :wikitext( mw.text.nowiki( tostring( result.expected ) ) ):done();
                row:tag( 'td' )
                    :css('overflow-wrap', 'break-word')
                    :css('word-break', 'break-all')
                    :css( 'font-family', 'monospace, monospace' )
                    :css( 'white-space', 'pre-wrap' )
                    :wikitext( mw.text.nowiki( tostring( result.actual ) ) ):done();
            else
                row:tag( 'td' )
                    :css('overflow-wrap', 'break-word')
                    :css('word-break', 'break-all')
                    :attr( 'colspan', '2' ):wikitext( mw.text.nowiki( result.message ) ):done();
            end
        else
            row:tag( 'td' ):addClass( 'test-name' ):wikitext( result.name ):done();
            row:tag( 'td' ):done();
            row:tag( 'td' ):done();
        end
    end

    local header = ''
	if testData.failureCount > 0 then
		local msg = mw.message.newRawMessage( CFG.TEST_FAILURE_SUMMARY, testData.failureCount ):plain();
		msg = self.frame:preprocess( msg );
		if CFG.CATEGORY.TEST_FAILURE then
			msg = CFG.CATEGORY.TEST_FAILURE .. msg;
		end
		header = header .. failIcon .. ' ' .. msg .. '\n';
	else
		if testData.successCount == 1 then 
		    header = header .. successIcon .. ' ' .. CFG.TEST_SUCCESS_SINGLE .. '\n';
		else
		    header = header .. successIcon .. ' ' .. string.format( CFG.TEST_SUCCESS_MULTIPLE, testData.successCount ) .. '\n';
		end
	end
	
    return header .. tostring( testtable );
end

return unittest