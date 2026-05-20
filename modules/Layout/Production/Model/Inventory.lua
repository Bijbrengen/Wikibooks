-- This module checks, converts and adds an inventory to the parameters.
local inventory = {};

function inventory.collection ( call )
	local text  = call.include( "text" );

    return text.split( call.collection );
end

function inventory.color( call )
	-- The functions from other modules that are used in this function
    local convert, text, color  = call.include( "convert", "text", "color" );	
    
    -- If a user did not set any of all the three needed colors then we use the default ones
    local default_colors = { call.style.BLUE, call.style.ORANGE, call.style.PURPLE };
    local colors = {};
    if not call.color then colors = default_colors; else colors = text.split( call.color ); end

    -- Extend the call.color parameter from hex code with rgb code, shades and tints for each of the three colors
	local new_color = {};
    for index, value in ipairs( default_colors ) do
     	if colors[ index ] then
    	    colors[ index ] = text.trim( colors[ index ] );
    	    -- If the color is set we use it in stead of the default color
     		if colors[ index ] ~= "" then 
      		    if string.sub( colors[ index ], 1, 1 ) ~= "#" then value = "#" .. colors[ index ]; else value = colors[ index ]; end
      		end
        end
	    local r, g, b = convert.hex_to_rgb( value:sub(2) );
	    new_color[ index ] = {};
	    new_color[ index ].hex    = value;
	    new_color[ index ].rgb    = { r, g, b };
	    new_color[ index ].shades = color.shades( r, g, b, call.tones );
	    new_color[ index ].tints  = color.tints(  r, g, b, call.tones );
 	end
	return new_color;
end

function inventory.definition( call )
	local text = call.include( "text" );
	if not call.definition then return nil; end
    return text.trim( tostring( call.definition ) );
end

function inventory.description( call )
	local text = call.include( "text" );
	if not call.description then return nil; end
    return text.trim( tostring( call.description ) );
end

function inventory.format( call )
    if not call.format then call.format = "text"; end
    return call.format;
end

function inventory.object( call )
	-- The functions from other modules that are used in this function
	local array, text  = call.include( "array", "text" );

	-- If the object parameter is not set, check if it is the first unnamed parameter
	if ( not call.object ) and ( call.unnamed[1] ~= nil ) and array.search( call.message.HOOK.OBJECT, text.capitalize_first( call.unnamed[ 1 ] ) ) then
		-- Convert the value of the first unnamed parameter in the installed language to the internal versions and set caal.object with it
		call.object = call.hook.OBJECT[ array.search( call.message.HOOK.OBJECT, text.capitalize_first( call.unnamed[ 1 ] ) ) ];
		-- Because the first unnamed parameter is in fact the object parameter, it should be removed from the unnamed parameter array.
		table.remove( call.unnamed, 1 );
	end

	if not call.object then
	    local title = mw.title.getCurrentTitle()
	    if title.nsText == "Wikibooks" and title.baseText == "Infobox" then
	        call.object = "infobox"
	    elseif title.nsText == "Module" then
	        call.object = "module"
	    elseif title.nsText == "Sjabloon" then
	        call.object = "template"
	    elseif title.isContentPage and title.isSubpage then
	        call.object = "chapter"
	    else
	        call.object = "book"
	    end
	end
    return call.object;
end

function inventory.orientation( call )
	if call.object == "chess" and not call.orientation then
 	    local rank = nil;
        for i, v in ipairs( call.unnamed ) do
            local ranknumber = tonumber( v );
            if rank == nil and ranknumber ~= nil and ranknumber >= 1 and ranknumber <= 8 then rank = ranknumber; end
        end
        if rank == 1 then 
        	call.orientation = "black"; 
        else
        	call.orientation = "white";
        end
	end
    return call.orientation;
end

function inventory.part ( call )
	local text  = call.include( "text" );

    return text.split( call.part );
end

-- Convert the progress into an integer.
function inventory.progress( call )
	-- The functions from other modules that are used in this function
	local text = call.include( "text" );

	call.progress = text.trim( tostring( call.progress ) );
	if string.sub( call.progress, -1) == "%" then
        call.progress = string.sub( call.progress, 1, -2)
    end
    return tonumber( call.progress );
end

function inventory.reference( call )
	local text = call.include( "text" );
	
    return text.split( call.reference, true );
end

function inventory.source( call )
	local text = call.include( "text" );
	if not call.source then return nil; end
    return text.trim( tostring( call.source ) );
end

function inventory.support( call )
    if not call.support then call.support = "ignore"; end
    return call.support;
end

function inventory.title( call )
	local text = call.include( "text" );
	if not call.title then return nil; end
    return text.trim( tostring( call.title ) );
end
	
return inventory;
