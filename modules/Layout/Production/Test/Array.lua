local test = {}

local CFG      = require( "Module:Layout/Production/Configuration" );
local array  = CFG.INCLUDE( "production", "array" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_array_copy()
    local input_1 = { 1, 2, { 3, 4 }, 5 };

    -- Test 1: Check if the copied table is not a reference
    local output_1 = array.copy( input_1 );
    input_1[1] = 99;
    self:assertEquals( false, input_1[1] == output_1[1], "Check if the copied table is not a reference" );

    -- Test 2: Check if the nested table is not a reference
    local output_2 = array.copy( input_1 );
    input_1[3][1] = 88;
    self:assertEquals( false, input_1[3][1] == output_2[3][1], "Check if the nested table is not a reference" );
end

function test:test_array_search()
    local input_1 = { "apple", "banana", "cherry", "date" };

    -- Test 1: Search for existing value
    local expected_1 = 3;
    local search_value_1 = "cherry";
    local output_1 = array.search( input_1, search_value_1 );
    self:assertEquals( expected_1, output_1, "Search for cherry" );

    -- Test 2: Search for non-existent value
    local expected_2 = false;
    local search_value_2 = "orange";
    local output_2 = array.search( input_1, search_value_2 );
    self:assertEquals( expected_2, output_2, "Search for orange not found" );

    -- Test 3: Search in an empty array
    local expected_3 = false;
    local search_value_3 = "apple";
    local output_3 = array.search( {}, search_value_3 );
    self:assertEquals( expected_3, output_3, "Search in an empty array" );

    -- Test 4: Case-insentive search
    local expected_4 = 1;
    local search_value_4 = "aPple";
    local case_insentive = true;
    local output_4 = array.search( input_1, search_value_4, case_insentive );
    self:assertEquals( expected_4, output_4, "Case-insentive search" );
end

function test:test_array_slice()
    local input_1 = { 1, 2, 3, 4, 5 };

    -- Test 1: Slice with default parameters
    local expected_1 = input_1;
    local output_1 = array.slice( input_1 );
    self:assertDeepEquals( expected_1, output_1, "Slice with default parameters" );

    -- Test 2: Slice with start past end of array
    local expected_2 = {};
    local output_2 = array.slice( input_1, 6 );
    self:assertDeepEquals( expected_2, output_2, "Slice with start past end of array" );

    -- Test 3: Slice with negative start
    local expected_3 = { 3, 4, 5 };
    local output_3 = array.slice( input_1, -3 );
    self:assertDeepEquals( expected_3, output_3, "Slice with negative start" );

    -- Test 4: Slice with negative end
    local expected_4 = { 1, 2, 3 };
    local output_4 = array.slice( input_1, 1, -3 );
    self:assertDeepEquals( expected_4, output_4, "Slice with negative end" );
end

return test;
