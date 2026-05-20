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

local NAMES = {
    orange = "#FFA500",
    blue = "#0000FF",
    red = "#FF0000",
    green = "#008000",
    yellow = "#FFFF00",
    purple = "#800080",
    black = "#000000",
    white = "#FFFFFF",
    gray = "#808080",
    grey = "#808080",
}

-- Map a color name to a hex code if possible
function color.map( name )
    if not name then return nil end
    name = mw.text.trim( name:lower() )
    if string.sub( name, 1, 1 ) == "#" then return name end
    if NAMES[ name ] then return NAMES[ name ] end
    
    -- If it's a 6-digit hex without #, add it
    if string.match( name, "^%x%x%x%x%x%x$" ) then return "#" .. name end
    
    return name
end

-- Check if the color code or name is valid
function color.valid( hexacode ) -- : boolean
	-- Allow a single code as well as an array of codes
	local codes = {};
	if type( hexacode ) ~= "table" and type( hexacode ) ~= "string" then return false; end
	if type( hexacode ) == "table" then codes = hexacode; else codes = { hexacode }; end

	-- All codes must be correct
	for index, value in ipairs( codes ) do
		--The code should be a string
	    if type( value ) ~= "string" then return false; end
	    value = mw.text.trim( value:lower() );
	    
	    -- Skip empty values
	    if value ~= "" then
	        -- Check if it's a known name
	        if NAMES[ value ] then
                -- Valid
            else
	    	    -- Check if it's a valid hex code (with or without #)
	    	    if string.sub( value, 1, 1 ) ~= "#" then value = "#" .. value; end
	            if not string.match( value, "^#%x%x%x%x%x%x$" ) then return false; end
	        end
	    end
	end
	return true;
end

return color;