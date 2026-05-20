local color = {}

-- This function returns an array of shades based on the r, g, b color and the number of tones.
function color.shades( r, g, b, tones ) -- : array
	local shades = {};
	local step = 1 / ( tones + 1 );
    for i = 1, tones do
        local factor = i * step;
        shades[ i ] =  string.format( "#%02X%02X%02X", r * factor,  g * factor,  b * factor );
    end
    return shades;
end

-- This function returns an array of tints based on the r, g, b color and the number of tones.
function color.tints( r, g, b, tones ) -- : array
	local tints = {};
	local step = 1 / ( tones + 1 );
    for i = 1, tones do
        local factor = i * step;
        tints[ i ] =  string.format( "#%02X%02X%02X", r + ( 255 - r ) * factor,  g + ( 255 - g ) * factor,  b + ( 255 - b ) * factor );
    end
    return tints;
end

-- Only allow 6-digit hexadecimal color codes
function color.valid( hexacode ) -- : boolean
	-- Allow a single code as well as an array of codes
	local codes = {};
	if type( hexacode ) ~= "table" and type( hexacode ) ~= "string" then return false; end
	if type( hexacode ) == "table" then codes = hexacode; else codes = { hexacode }; end

	-- All codes must be correct
	for index, value in ipairs( codes ) do
		--The code should be a string
	    if not type( value ) == "string" then return false; end
	    value = mw.text.trim( value );
	    -- Skip empty values
	    if value ~= "" then
	    	-- Allow codes without the # prefix
	        if string.sub( value, 1, 1 ) ~= "#" then value = "#" .. value; end
        	-- The string.match( hexcode, "^#(%x%x%x)$" ) check is also correct for colorcodes but not in this module
	        if not string.match( value, "^#(%x%x%x%x%x%x)$" ) then return false; end
	    end
	end
	return true;
end

return color;
