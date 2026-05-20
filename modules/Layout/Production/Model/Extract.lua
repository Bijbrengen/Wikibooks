local extract = {};

function extract.book_progress( book, call )
	local new_book = {};
	new_book.text = book;
	new_book.progress = "0";
    if book and book ~= "" then
    	book = mw.text.trim( book )
        local formatted_book = book:gsub(" ", "&nbsp;")
    	local wiki_book = mw.title.new(book)
    	if wiki_book then
	        local progress_parameters = extract.parameter( wiki_book:getContent(), call.message.TEMPLATENAME, call.message.PROGRESS.NAME, call )
            if progress_parameters[1] then 
            	new_book.progress = progress_parameters[1]:gsub("^%s*(.-)%s*$", "%1");
            end
        end
        new_book.text = mw.ustring.format('[[%s|%s]]', book, formatted_book);
    end
    return new_book;
end

-- This function extracts the content of the page with the titlename.
function extract.content( call )
	local text = call.include( "text" );
	if not text.valid( call.source ) then return nil; end
    local title = mw.title.new( call.source );
    if ( title == nil or title == '' ) then return nil; end
    return title:getContent();
end

-- This function extracts the level two headings out of the wikitext with the position as the key.
function extract.heading( wikitext, call )
	local text = call.include( "text" );
	
    if not text.valid( wikitext ) then return {}; end
    local lines = mw.text.split( wikitext, '\n' );
    local headings = {};
    for _, line in ipairs(lines) do
    	-- Check if the beginning of the line is ==.
		if ( line:match('^==') and not line:match('^===') ) then
            line = mw.text.trim( line, "\t\r\n\f " );
            -- Check if the end of the line is also == and there are no = in between.
            if string.sub( line, -2 ) == '==' and not string.find( string.sub( line, 3, -3 ) , "=" ) then 
	            line = line:gsub( "=", "" );
                line = mw.text.trim( line, "\t\r\n\f " );
            	table.insert( headings, line ); 
            end
	    end
	end
    return headings;
end

-- This functions get's the parameters of a template with the position as the key.
function extract.parameter( wikitext, templatename, parametername, call ) -- :table
	local text = call.include( "text" );
	if not text.valid( wikitext ) then return {}; end
	if not text.valid( templatename ) then return {}; end
	if parametername and not text.valid( parametername ) then return {}; end
	local template =  extract.template( wikitext, templatename, call );
    local result  = {};
    for i, sub_table in ipairs( template ) do
        for k, v in pairs( sub_table ) do
            if ( parametername and k == parametername ) or ( not parametername and type( k ) == "number" and k > 0 ) then
                table.insert( result, v );
            end
        end
    end
    return result;
end

-- This function returns all templates of the given template_name out in the given wikitext in a table with the position (first, second) number as the key.
function extract.template( wikitext, template_name, call ) -- :table 
	local text, pattern, convert = call.include( "text", "pattern", "convert" );
	if not text.valid( wikitext ) then return {}; end
	if not text.valid( template_name ) then return {}; end
    local templates = {};
    local i = 1;  -- start index
    -- Find all templates in the wikitext by fist looking at matching brackets by the pattern '%b{}'.
    -- Not all machting brackets are templates or if so the template we are looking for.
    -- If the matsching brackets look like {{template_name}} or {{template+name|}} etcetera, which we catch with the '^{{' .. template_name .. '[^}]*}}$' pattern, we've got the template.
    wikitext = wikitext:gsub( 
    	'%b{}', 
    	function( matching_brackets )
	        -- Check if the template is the one we're interested in
--	        if matching_brackets:match('^{{' .. template_name .. '[^}]*}}$') 
            if pattern.template_definition_at_start_and_end( matching_brackets, template_name )
	        then
	            -- Add the template table to the list
	            templates[i] = convert.template_to_table( matching_brackets, template_name, call );
	            i = i + 1;
	        end
	        -- Return an empty string to replace the matching_brackets in the wikitext
	        return "";
    	end
    );
    return templates;
end

return extract;
