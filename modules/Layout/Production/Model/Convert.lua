local convert = {};

-- This function converts a hexadecimal code to r, g, b
function convert.hex_to_rgb( hex )
    local r = tonumber( hex:sub(1, 2), 16 );
    local g = tonumber( hex:sub(3, 4), 16 );
    local b = tonumber( hex:sub(5, 6), 16 );
    return r, g, b;
end

-- This function converts a date into a age.
function convert.date_to_age( call )
	local timestamp = call.include( "timestamp" );

	local startdate = call.unnamed[1];
	local enddate   = call.unnamed[2];

	if not type( startdate ) == "string" or #startdate < 8 then return ""; end
    local startday, startmonth, startyear = string.gmatch( startdate, "(%d+)-(%d+)-(%d+)")();

	if not type( enddate ) == "string" or #enddate < 8 then enddate = mw.language.getContentLanguage():formatDate("d-m-Y"); end
    local endday, endmonth, endyear   = string.gmatch( enddate, "(%d+)-(%d+)-(%d+)")();

    -- Make sure day, month and year are numbers
    startday   = tonumber( startday );
    startmonth = tonumber( startmonth );
    startyear  = tonumber( startyear );
    endday     = tonumber( endday );
    endmonth   = tonumber( endmonth );
    endyear    = tonumber( endyear );

    -- Check if the dates are valid
    if not timestamp.valid( startday, startmonth, startyear ) or not timestamp.valid( endday, endmonth, endyear ) then return ""; end

    -- Calculate age based on day and month comparison
    local age = endyear - startyear;
    if endmonth < startmonth or ( endmonth == startmonth and endday < startday) then
        age = age - 1;
    end

    if age < 0 then
        age = 0;
    end
    
    return tostring( age );
end

-- This function converts a text into a table if the text containts the template template_name.
-- All parameters are stored as elements of the table.
-- Unnamed parameters become indexed where the index represents the position in the template.
-- Named parameters are stored associative.
function convert.template_to_table( inputtext, template_name, call ) -- :table
	local pattern, text = call.include( "pattern", "text" );
	
	-- Check if the text starts and ends with the definition of the template_name and if so remove it.
	inputtext = pattern.remove_template_definition( inputtext, template_name )
    if not inputtext then return {}; end

    -- Replace the | characters inside lists, templates, tables, links, headings and tags with a special character so it will not join the split
    -- Because we removed the template definition, the | in the template itself will not be changed.
    inputtext = pattern.replace_inner_pipes( inputtext );
	
	-- Split the template at the | character. We now for sure that inner wikitext elements do not join the split anymore.
    local parts = mw.text.split( inputtext, '|' );

   -- Create a new table to store the template parameters and values
    local t = {};
    local j = 1;  -- start index for unnamed parameters
    for _, part in ipairs( parts ) do
        -- Trim leading and trailing whitespace from the part
        part = mw.text.trim( part );
        
        -- Check if the first characters form the name of a parameter.
        -- If the result is empty that means we're dealing with the first part that still belongs to the template definition just skip.
        if not ( part == "" )
        then
        	-- Let's divide the part into a parametername and a parametervalue
            local param_name = pattern.paramname( part );
            local param_value = pattern.paramvalue( part );

            -- Put the | back. The param_name should not contain the | character
            if text.valid( param_value ) then param_value = param_value:gsub('¦', '|'); else param_value = ""; end
            
            if param_name
            then
            	-- We do have a parametername. So store it as the value of the key for the value of the parameter
                t[ param_name ] = mw.text.trim( param_value, "\t\r\n\f " );
            else
                -- We do not have a parametername. The key is the position of the unnamed parameter.
                t[j] = mw.text.trim( param_value, "\t\r\n\f " );
                j = j + 1;
            end
        end
    end
    return t;
end

return convert;
