local test = {}

local CFG        = require( "Module:Layout/Production/Configuration" );
local calculator = CFG.INCLUDE( "production", "calculator" );
local unittest   = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_calculator_clamp()
    self:assertEquals( 5, calculator.clamp( 5, 0, 10 ), "Value inside range" );
    self:assertEquals( 0, calculator.clamp( -5, 0, 10 ), "Value below minimum" );
    self:assertEquals( 10, calculator.clamp( 15, 0, 10 ), "Value above maximum" );
    self:assertEquals( 5, calculator.clamp( 5, 5, 5 ), "Min, max and value are equal" );
end

function test:test_calculator_lerp()
    self:assertEquals( 5, calculator.lerp( 0, 10, 0.5 ), "Midpoint" );
    self:assertEquals( 0, calculator.lerp( 0, 10, 0 ), "Start point" );
    self:assertEquals( 10, calculator.lerp( 0, 10, 1 ), "End point" );
    self:assertEquals( 20, calculator.lerp( 10, 30, 0.5 ), "Lerp with offset" );
    self:assertEquals( 12.5, calculator.lerp( 10, 20, 0.25 ), "Quarter point" );
end

return test;
