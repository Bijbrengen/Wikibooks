local pattern = {};

-- This function will return everything after the first equal sign with nothing then spacetype characters in front of it.
-- If the first = sign is part of == or === or ... then nil is returned because there is no defining single = sign.
function pattern.content_after_starting_equal_sign( text ) -- :string or nil
	-- The pattern '^%s*=%s*(.*)' is used to match a string of the form '=value', 
	-- where value is any sequence of characters. 
	-- The ^ symbol indicates the beginning of the string, and the $ symbol indicates the end of the string. 
	-- The %s* pattern matches any number of whitespace characters (including spaces, tabs, and newlines). 
	-- The = character is a literal character that must be present in the string. 
	-- The (.*) pattern is a capture group that matches any sequence of characters (including none).
    -- When this pattern is applied to a string using string.match, it will extract the value portion of the string 
    -- (i.e., everything after the = character) and return it as a separate string. 
    text = text:match( '^%s*=(.*)' );
    -- If a = is found then in the case of a == of more the string starts with a =
    -- The pattern "^=" matches the start of the string followed by "=". 
    -- If the string starts with "=", string.find will return the starting position of the pattern (i.e., 1), and the if statement will evaluate to true. 
    -- If the string does not start with "=", string.find will return nil, and the if statement will evaluate to false.
    if not text or string.find( text, "^=") then return nil; end
    return mw.text.trim( text );
end

-- This function will returns a string with the last segment from the url.
function pattern.last_segment_of_url( url ) -- :string
	-- This will use the pattern "/.+$" to match any sequence of characters starting with '/' and ending with the end of the string. 
	-- This will extract the last path segment from the URL.
    local text = string.match( url, "/.+$" );
    -- Pattern can also return a //
    if not text or text == "" then return ""; end
    -- If there remove all /
    return string.gsub( text, "/", "");
end

-- Just get the parameter name after the split by pattern.paramname_and_paramvalue( text )
function pattern.paramname( text )
    local param_table =  pattern.paramname_and_paramvalue( text );
     return param_table[1];
end

-- Split of a text like a = b into param_name = a and param_value = b.
function pattern.paramname_and_paramvalue( text )
    -- We must exclude "==" if that's the start
    if string.find( text, "^%s*==" ) then
    	return { nil, text };
    end

    -- Let's divide the part into one that has valid characters for a possible parametername and the remaining stuff
    local param_name, rest = pattern.split_paramname_from_the_rest( text );
    -- We must exclude "==" if that's the start
    if rest and string.find( rest, "^%s*==" ) then
    	return { nil, text };
    end

    -- If there is a param_name it can still be part of the param_value.
    -- So there must be content after a starting = in the rest.
    if param_name and pattern.content_after_starting_equal_sign( rest ) then
    	return { param_name, pattern.content_after_starting_equal_sign( rest ) }; 
    end

    -- If there is no param_name it can still be the case of a unnamed parameter defined by "  = xjbkjxAK"
    -- We can have either " = param_value" or "param_value"
    if not param_name and pattern.content_after_starting_equal_sign( text ) then
    	return { nil, pattern.content_after_starting_equal_sign( text ) };
    end
    
    -- Now the only remaining situation is that all text is the value of an unnamed paramter.
     return { nil, text };
end

-- Just get the parameter value after the split by pattern.paramname_and_paramvalue( text )
function pattern.paramvalue( text )
    local param_table =  pattern.paramname_and_paramvalue( text );
    return param_table[2];
end

-- This function will returns a string with the last segment from the url removed.
function pattern.remove_last_segment_from_url( url ) -- :string
	-- The / character is a literal character that is matched in the string and seperates the segments in a URL
    -- The [^/] part of the pattern matches any character that is not a '/'. 
    -- The * character indicates that the preceding character (in this case, the [^/] character class) should be matched zero or more times.
    -- The $ character is a special character that represents the end of the string. It is used to ensure that the pattern only matches characters at the end of the string.
    -- Together, the pattern "/[^/]+$" will match any sequence of characters starting with '/' and ending with the end of the string, 
    -- that does not contain any '/' characters. 
    return url:gsub("/[^/]*$", "");
end

-- This function removes a template definition
function pattern.remove_template_definition( text, template_name ) -- :string or nil
	if not pattern.template_definition_at_start_and_end( text, template_name ) then return nil; end
    -- '^{{' means start at the exact beginning of the string
    text = text:gsub( '^{{' .. template_name, '' )
    -- '}}$' means end at the exact ending of the string
    return text:gsub('}}$', '')
end

-- This function replaces the | characters inside lines that start with a certain character.
function pattern.replace_in_lines_that_start_with_a_character( text, start, search, replace )
    if not ( 
    	type( text )    == "string"  and 
    	type( start )   == "string" and 
    	type( search )  == "string" and 
    	type( replace ) == "string" ) then
        return text;
    end
	local start_pos = 1;
	while true do
	    -- find the next line starting with * or the next \n*
	    local from, to = string.find( text, "^%" .. start, start_pos ) or string.find( text, "\n%" .. start, start_pos );
	    if not from then break end
	    -- find the next newline or the end of the string
	    local _, end_pos = string.find( text, "\n", to);
	    if not end_pos then end_pos = string.len( text ) end
	    -- replace | with special character on the line
	    text = string.sub( text, 1, from - 1) .. string.gsub( string.sub( text, from, end_pos ), search, replace ) .. string.sub( text, end_pos + 1 )
	    start_pos = from + 1;
	end
	
	return text;
end

-- This function replaces the | characters inside lists, templates, tables, links, headings and tags with a special character.
function pattern.replace_inner_pipes( text )
    local special_character = "¦";
    
    -- Replace the | into lines that are lists and start with *, # or :
    text = pattern.replace_in_lines_that_start_with_a_character( text, "*", "|", special_character );
    text = pattern.replace_in_lines_that_start_with_a_character( text, "#", "|", special_character );
    text = pattern.replace_in_lines_that_start_with_a_character( text, ":", "|", special_character );
    
    --  %b{} is a pattern that matches balanced brackets, 
    -- so this finds all remaining templates {{ }} and tables {| |}in the text after we removed the actual template we want.
    text = text:gsub('%b{}', function(t) return t:gsub('|', '¦') end );
    
    --  %b[] would match balanced square brackets [] to find links
    text = text:gsub('%b[]', function(t) return t:gsub('|', '¦') end );

    --  %b() would match balanced parentheses (). But hese are not allow outside links so they do not have to be removed. Still for safety let's do it.
    text = text:gsub('%b()', function(t) return t:gsub('|', '¦') end );
   
    -- '%b<>' also tags can contain the | character in itself.
    text = text:gsub('%b<>', function(t) return t:gsub('|', '¦') end );
    
    -- Remove also | within the tag-pairs
    text = text:gsub('<(.-)>(.-)</%1>', function( tag, contents ) contents = contents:gsub('|', '¦'); return '<' .. tag .. '>' .. contents .. '</' .. tag .. '>'; end );

    -- Also the headings can contain the | character. But this not allowed in templates
    return text;
end

-- This pattern captures the first sequence of letters, digits, or underscores at the beginning of the part string and assigns it to param_name, 
-- and assigns the rest of the part string to rest.
function pattern.split_paramname_from_the_rest( text ) -- :indexed table or list
	-- The pattern '^(%a[%a%d_]*)(.*)' consists of two capture groups. 
	-- The first capture group '(%a[%a%d_]*)' matches one or more letters, digits, or underscores, 
	-- and the second capture group '(.*)' matches any character zero or more times.
    return text:match('^(%a[%a%d_]*)(.*)');	
end

-- This pattern checks if the text starts with a definition of the template {{template_name and is ended correctly by }}
function pattern.template_definition_at_start_and_end( text, template_name ) -- :boolean
	-- "^{{" matches the beginning of the string and the characters "{{".
    -- template_name is a variable that represents the name of the template.
    -- Now it is crucial that the end of the name of template is reached to distinguish between for example Test versus Testing as name.
    -- "[}|%s]+" matches one or more occurrences of "}" or "|" a space type character (like space itself or newline of tab).
    -- "}}$" matches the characters "}}" at the end of the string.
    -- The and true or false part at the end just returns true if the pattern matches, or false if it doesn't.
    -- The {{ the start and the }} at he end must be machting. So look for the first matching {{}} pair and check if they start and end the string.
    local first, last = string.find( text, "%b{}" );
    if ( first ~= 1 or last ~= #text ) then return false; end
    return text:match( "^{{" .. template_name.."[}|%s]+" ) and text:match( "}}$" ) and true or false;
end

return pattern
