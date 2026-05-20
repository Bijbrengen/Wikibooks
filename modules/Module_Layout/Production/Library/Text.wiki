local text = {};

function text.capitalize_first( str )
	if not text.valid( str ) then return ""; end
    str = str:lower();
    return (str:gsub("^%l", string.upper))
end
	
function text.split( str, trim )
	if not text.valid( str ) then return {}; end
    local result = mw.text.split( str, "," );
    for i, substring in ipairs( result ) do
        if trim then
            result[i] = text.trim( substring );
        end
    end
    return result;
end

function text.trim( str )
	if not text.valid( str ) then return ""; end
    return mw.text.trim( str, "\t\r\n\f ");
end

function text.sanitize( str )
    if not text.valid( str ) then return ""; end
    -- Remove soft hyphens in various forms to prevent broken links
    str = str:gsub("&shy;", "");
    str = str:gsub("&#173;", "");
    str = str:gsub("&#x[aA][dD];", "");
    str = str:gsub("\194\173", ""); -- UTF-8
    str = str:gsub("\173", "");     -- Single-byte
    return str;
end

function text.valid( str )
    return ( str ~= nil and type( str ) == 'string' and str ~= "" and not str:match('^%s*$') );
end

return text;