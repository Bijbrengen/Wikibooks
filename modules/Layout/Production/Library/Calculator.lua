local calculator = {};

-- The arithmetic clamp function restricts a value to a certain range.
-- The function has a value to be clamped, a minimum value and a maximum value.
function calculator.clamp( value, minimum, maximum )
    if value < minimum then return minimum end;
    if value > maximum then return maximum end;
    return value;
end

-- This function does a linear interpolation.
-- It is a method of finding a value that lies between two given values a en b
-- by assuming a linear relationship between them.
-- The "position" of C between A and B is t, where t ranges from 0 to 1.
function calculator.lerp( a, b, t )
    return a + ( b - a ) * t;
end

return calculator;
