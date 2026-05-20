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
    call.content.detail = {}
	call.content.chapter = {}
	local text_strings = {}
	for i, s in ipairs(call.unnamed) do
	   if s and s ~= "" then
	   	  table.insert(text_strings, text.trim(s)) 
	   end
	end
	call.content.text = text_strings

    call.content.series = {};
    call.content.series.image = "";
    call.content.series.link = "";
    call.content.series.book = {};
    if call.collection[1] then 
		call.content.series.link = text.trim( call.collection[1] );
		local wiki_series = mw.title.new( call.content.series.link );
		call.content.series.link = mw.ustring.format('[[%s|%s]]', call.content.series.link, call.content.series.link );
		if wiki_series then
			local source_parameters = extract.parameter( wiki_series:getContent(), call.message.TEMPLATENAME, call.message.PARAM.SOURCE, call );
		    if source_parameters and source_parameters[1] and #source_parameters[1] >0 then
		    	call.content.series.image = mw.ustring.format('[[image:%s|30px]]&nbsp;', source_parameters[1])
		    end
		    local title_parameters = extract.parameter( wiki_series:getContent(), call.message.TEMPLATENAME, call.message.PARAM.TITLE, call );
		    if title_parameters and title_parameters[1] then
		    	call.content.series.link = mw.ustring.format('[[%s|%s]]', text.trim( call.collection[1] ), title_parameters[1] );
		    end
		    local part_parameters = extract.parameter( wiki_series:getContent(), call.message.TEMPLATENAME, call.message.PARAM.PART, call );
		    if part_parameters and part_parameters[1] then
		    	local parts = text.split( part_parameters[1], true);
				for i, book in ipairs( parts ) do
				    if book and book ~= "" then
			            local unformatted_book = book:gsub("&shy;", "")
				        table.insert( call.content.series.book, extract.book_progress( unformatted_book, call ) );
				    end
				end
		    end
		end
    end

	call.content.max_number_of_chapter_title_lines = 0
	call.content.max_number_of_chapter_headings = 0
	for i, chapter in ipairs(call.part) do
	    if chapter and chapter ~= "" then
	    	chapter = mw.text.trim( chapter )
		    local chapter_title_lines = select(2, chapter:gsub('&shy;', '')) + 1
			if chapter_title_lines > call.content.max_number_of_chapter_title_lines then
			    call.content.max_number_of_chapter_title_lines = chapter_title_lines
			end
            local formatted_chapter = chapter:gsub(" ", "&nbsp;")
            formatted_chapter = formatted_chapter:gsub("&shy;", "<br>")
            formatted_chapter = mw.ustring.gsub(formatted_chapter, mw.ustring.char(173), '<br>')
            chapter = chapter:gsub("&shy;", "")
            chapter = mw.ustring.gsub(chapter, mw.ustring.char(173), "")
            
	    	local new_chapter = {}
	    	new_chapter.name = chapter
	    	new_chapter.number = i
	    	new_chapter.caption = call.message.OBJECT.CHAPTER;
	    	new_chapter.subelements = {}
	    	local currentPageTitle = mw.title.getCurrentTitle().prefixedText;
			local chapter_text = mw.ustring.format('[[%s|%s]]', chapter, formatted_chapter)
			local wiki_chapter = nil
		    if currentPageTitle then
		    	local page_title = currentPageTitle
			    wiki_chapter = mw.title.new(page_title .. "/" .. chapter)
		    	if wiki_chapter then
			        chapter_text = mw.ustring.format('[[%s|%s]]', wiki_chapter.prefixedText, formatted_chapter)
			        local extract = call.include( "extract" );
			        new_chapter.subelements = extract.heading( wiki_chapter:getContent(), call );
					local aantal_headings = #new_chapter.subelements
					if aantal_headings > call.content.max_number_of_chapter_headings then
					    call.content.max_number_of_chapter_headings = aantal_headings
					end
		    	end
		    end
            new_chapter.text = chapter_text;
			new_chapter.button = call.message.BUTTON.READ;
			if wiki_chapter then
			    new_chapter.button = mw.ustring.format( '[[%s|%s]]', wiki_chapter.prefixedText, new_chapter.button );
			end
	        table.insert( call.content.chapter, new_chapter );
	    end
	end

    -- Categorization logic (Sjabloon:Boek)
    local title = mw.title.getCurrentTitle()
    local categories = { "[[Categorie:Boek]]" }
    
    -- Print version check
    local print_version = mw.title.new(title.prefixedText .. "/Printversie")
    if print_version and print_version.exists then
        table.insert(categories, "[[Categorie:Boeken met printversie]]")
    end
    
    -- Wikijunior check
    if call.content.wikijunior or title.prefixedText:match("Wikijunior:") then
        table.insert(categories, "[[Categorie:Wikijunior-boeken]]")
    end

    -- Phase check (Sjabloon:Fase) - mapped from progress (0-100) to phase (0-4)
    if title.subpageText ~= "Printversie" then
        local progress_str = tostring(call.progress or ""):gsub("%%", "")
        local progress_num = tonumber(progress_str)
        if progress_num then
            local phase = 0
            if progress_num >= 80 then phase = 4
            elseif progress_num >= 60 then phase = 3
            elseif progress_num >= 40 then phase = 2
            elseif progress_num >= 20 then phase = 1
            end
            table.insert(categories, "[[Categorie:Fase " .. phase .. "]]")
        elseif call.progress == false or call.progress == "" then
            table.insert(categories, "[[Categorie:Fase onbekend]]")
        end
    end
    
    -- Use newlines to separate from any preceding/following HTML
    call.content.categories = "\n" .. table.concat(categories, "\n") .. "\n"

    return call;
end

return content;