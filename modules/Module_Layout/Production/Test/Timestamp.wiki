local test = {}

local CFG        = require( "Module:Layout/Production/Configuration" );
local timestamp  = CFG.INCLUDE( "production", "timestamp" );
local unittest   = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_valid_timestamp()
    -- Test leap years
    self:assertTrue(  timestamp.valid( 29, 2, 2000 ) ); -- Leap year, divisible by 4, 100, and 400
    self:assertTrue(  timestamp.valid( 29, 2, 2020 ) ); -- Leap year, divisible by 4, not 100
    self:assertFalse( timestamp.valid( 29, 2, 1900 ) ); -- Not a leap year, divisible by 4 and 100, but not 400
    self:assertFalse( timestamp.valid( 29, 2, 2021 ) ); -- Not a leap year, not divisible by 4

    -- Test valid days for each month
    local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for month, days in ipairs(daysInMonth) do
        self:assertTrue( timestamp.valid(days, month, 2021) );
    end

    -- Test invalid days for each month
    for month, days in ipairs( daysInMonth ) do
        self:assertFalse( timestamp.valid( days + 1, month, 2021 ) );
    end
end

return test;