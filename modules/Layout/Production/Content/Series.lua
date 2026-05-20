local content = {}

function content.main( call )
	local array, extract, text = call.include( "array", "extract", "text" );

    -- Extend the call variable with messages that are specific to the type of the objects book includes
    call.message.PROGRESS   = call.include( call.language_path .. "/Progress" );
    
    call.content = {};
    call.content.wikipedia  = false;
    call.content.wikijunior = false;
    if call.reference then 
     	if array.search( call.reference, "wikipedia" ) then 
            call.message.WIKIPEDIA  = call.include( call.language_path .. "/Wikipedia" );
    		call.content.wikipedia  = true;
    	end
    	if array.search( call.reference, "wikijunior" ) then 
            call.message.WIKIJUNIOR = call.include( call.language_path .. "/Wikijunior" );
    		call.content.wikijunior  = true;
    	end
        if ( call.title == nil or type( call.title ) ~= 'string' or call.title == "" ) then call.title = call.caller; end
    end
	call.content.book = {}
	local text_strings = {}
	for i, s in ipairs(call.unnamed) do
	   if s and s ~= "" then
	   	  table.insert(text_strings, text.trim(s)) 
	   end
	end
	call.content.text = text_strings

    call.content.bookshelf = {};
    call.content.bookshelf.image = "";
    call.content.bookshelf.link = "";
    call.content.bookshelf.book = {};
    local bookshelf_name = call.message.OBJECT.BOOKSHELF;
    if call.collection[1] then 
		call.content.bookshelf.link = text.trim( call.collection[1] );
		local wiki_bookshelf = mw.title.new( bookshelf_name .. ":" .. call.content.bookshelf.link );
		if wiki_bookshelf then
			local source_parameters = extract.parameter( wiki_bookshelf:getContent(), call.message.TEMPLATENAME, call.message.PARAM.SOURCE, call );
		    if source_parameters and source_parameters[1] and #source_parameters[1] >0 then
		    	call.content.bookshelf.image = mw.ustring.format('[[image:%s|30px]]&nbsp;', source_parameters[1])
		    end
		    local collection_parameters = extract.parameter( wiki_bookshelf:getContent(), call.message.TEMPLATENAME, call.message.PARAM.COLLECTION, call );
		    if collection_parameters and collection_parameters[1] then
		    	call.content.bookshelf.link = mw.ustring.format('[[%s:%s|%s]]', bookshelf_name, collection_parameters[1], call.content.bookshelf.link );
		    end
		    local title_parameters = extract.parameter( wiki_bookshelf:getContent(), call.message.TEMPLATENAME, call.message.PARAM.TITLE, call );
		    if title_parameters and title_parameters[1] then
		    	call.content.bookshelf.link = mw.ustring.format('[[%s:%s|%s]]', bookshelf_name, collection_parameters[1], title_parameters[1] );
		    end
		    local part_parameters = extract.parameter( wiki_bookshelf:getContent(), call.message.TEMPLATENAME, call.message.PARAM.PART, call );
		    if part_parameters and part_parameters[1] then
		    	local parts = text.split( part_parameters[1], true);
				for i, book in ipairs( parts ) do
				    if book and book ~= "" then
				        table.insert( call.content.bookshelf.book, extract.book_progress( book, call ) );
				    end
				end
		    end
		end
    end
    
	call.content.max_number_of_book_title_lines = 0
	call.content.max_number_of_book_chapters = 0
	for i, book in ipairs(call.part) do
	    if book and book ~= "" then
	    	book = mw.text.trim( book )
		    local book_title_lines = select(2, book:gsub('&shy;', '')) + 1
			if book_title_lines > call.content.max_number_of_book_title_lines then
			    call.content.max_number_of_book_title_lines = book_title_lines
			end
            local formatted_book = book:gsub(" &shy;", "&shy;")
            formatted_book = formatted_book:gsub("&shy; ", "&shy;")
            formatted_book = formatted_book:gsub(" ", "&nbsp;")
            formatted_book = formatted_book:gsub("&shy;", "<br>")
            book = book:gsub("&shy;", "")
            
	    	local new_book = {}
	    	new_book.name = book
	    	new_book.number = i
	    	new_book.caption = 'Boek'
	    	new_book.subelements = {}
	    	local currentPageTitle = mw.title.getCurrentTitle().prefixedText;
			local book_text = mw.ustring.format('[[%s|%s]]', book, formatted_book)
			local wiki_book = mw.title.new(book)
	    	if wiki_book then
		        book_text = mw.ustring.format('[[%s|%s]]', wiki_book.prefixedText, formatted_book)
		        local part_parameters = extract.parameter( wiki_book:getContent(), call.message.TEMPLATENAME, call.message.PARAM.PART, call )
		        if part_parameters and part_parameters[1] then 
			        local subelements = text.split( part_parameters[1], true);
			        new_book.subelements = {};
			        for i, subelement in ipairs(subelements) do
			            new_book.subelements[i] = mw.ustring.format('[[%s/%s|%s]]', wiki_book.prefixedText, subelement:gsub("&shy;", ""), subelement)
	                end
					local aantal_chapters = #new_book.subelements
					if aantal_chapters > call.content.max_number_of_book_chapters then
					    call.content.max_number_of_book_chapters = aantal_chapters
					end
				end
	    	end
            new_book.text = book_text;
			new_book.button = call.message.BUTTON.READ;
			if wiki_book then
			    new_book.button = mw.ustring.format( '[[%s|%s]]', wiki_book.prefixedText, new_book.button );
			end
	        table.insert( call.content.book, new_book );
	    end
	end

    return call;
end

return content;
