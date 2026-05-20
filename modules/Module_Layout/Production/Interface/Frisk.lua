-- This submodule checks all the values in the parameters of the call to the module Layout. 
-- It will warn the user if any mistakes are made.
local frisk = {};

-- Private variables
local protocol = {};

function frisk.collection ( call )
	return protocol.pagelist( call, "collection" );
end

-- This function checks the color parameter
function frisk.color( call )
	-- The functions from other modules that are used in this function
	local text, color = call.include( "text", "color" );

    local colors = text.split( call.color );
    if #colors > 3 or not color.valid( colors ) then 
	    return call.message.MISTAKE.WRONG.COLOR, tostring( call.color ), tostring( call.color ), call.style.BLUE, call.style.ORANGE, call.style.PURPLE;
	end

    return false; 
end

function frisk.definition( call )
    return protocol.html( call, "definition" );
end

function frisk.description( call )
    return protocol.html( call, "description" );
end

-- format is a reseverd function only for string so we can use it safely
function frisk.format( call )
	return protocol.enum( call, "format" );
end

function frisk.object( call )
	return protocol.enum( call, "object" );
end

function frisk.orientation( call )
	return protocol.enum( call, "orientation" );
end

function frisk.part ( call )
	return protocol.pagelist( call, "part" );
end

-- Convert if the progress is correct into an integer or to 0 if an mistake occured.
function frisk.progress( call )
	if call.progress == false then return false; end
	-- The functions from other modules that are used in this function
	local text = call.include( "text" );

	local progress = text.trim( tostring( call.progress ) );
	if string.sub( progress, -1) == "%" then
        progress = string.sub( progress, 1, -2)
    end
    progress = tonumber( progress );
    if progress == nil or progress < 0 or progress > 100 then 
    	return call.message.MISTAKE.WRONG.PROGRESS, call.progress, call.progress;
    end
	return false;
end

function frisk.reference( call )
    return false;
end

function frisk.source( call )
    return false;
end

function frisk.support( call )
	return protocol.enum( call, "support" );
end

function frisk.title( call )
    return protocol.html( call, "title" );
end

-- This function checks parameters that are restricted by "enumeration" ( "enum" )
-- and only are allowed to take one of the predefined values.
function protocol.enum( call, parameter )
	-- The functions from other modules that are used in this function
	local text, array  = call.include( "text", "array" );
	
	-- If the parameter is defaulted then no frisk is needed.
	if not call.named[ parameter ] or call.named[ parameter ] == "" then return false; end

	if not call[ parameter ] and call.message.HOOK[ string.upper( parameter ) ] ~= nil then
	    return call.message.MISTAKE.WRONG[ string.upper( parameter ) ], text.capitalize_first( call.named[ parameter ] ), call.named[ parameter ], table.concat( call.message.HOOK[ string.upper( parameter ) ], ", ");
	end
	
    return false;
end

-- This function checks if a string contains unbalanced HTML tags
function protocol.html( call, parameter )
	-- The functions from other modules that are used in this function
	local text = call.include( "text" );
	
	-- If the parameter is defaulted then no frisk is needed.
	if not call.named[ parameter ] or call.named[ parameter ] == "" then return false; end
	local text_val = tostring( call[ parameter ] );
	
	local tags_to_check = {"sup", "sub", "span", "div", "b", "i", "u", "p", "strong", "em", "center"};
	for _, tag in ipairs( tags_to_check ) do
		local open_count = select(2, string.gsub( string.lower(text_val), "<" .. tag .. "[%s>]", ""));
		local close_count = select(2, string.gsub( string.lower(text_val), "</" .. tag .. "%s*>", ""));
		
		if close_count ~= open_count then
			return call.message.MISTAKE.WRONG.HTML, text.capitalize_first( parameter ), tag;
		end
	end
	
	return false;
end

-- This function checks if a string containing a list of wikipages is correct
function protocol.pagelist( call, parameter )
	-- The functions from other modules that are used in this function
	local text, valid  = call.include( "text", "validation" );

    local split = text.split( call[ parameter ] );
    for _, value in ipairs( split ) do
    local no_hyphen_pagename = value:gsub("&shy;", "")
        if not valid.title( no_hyphen_pagename ) then 
	    	return call.message.MISTAKE.WRONG.PAGENAMELIST, value, text.capitalize_first( parameter ), value;
        end
    end
    return false;
end

return frisk;