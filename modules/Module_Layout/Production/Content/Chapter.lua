local chapter = {}

function chapter.main( call )
	local extract, text = call.include( "extract", "text" );
	
    -- Determine the book page (root of the current page)
    local currentTitle = mw.title.getCurrentTitle()
    call.root = currentTitle.rootText
    local bookTitle = mw.title.new( call.root )
    
    -- If we are on a subpage, try to inherit parts from the book page
    if currentTitle.isSubpage and bookTitle and bookTitle.exists then
        local bookContent = bookTitle:getContent()
        if bookContent then
            -- Extract parts (Onderdeel) from the {{Opmaak}} call on the book page
            local parts = extract.parameter( bookContent, call.message.TEMPLATENAME, call.message.HOOK.PARAMETER[13], call )
            if parts and parts[1] and (#call.part == 0) then
                local rawParts = parts[1]
                -- Clean all hyphens (literal soft hyphen and &shy; entity)
                local cleanParts = mw.ustring.gsub(rawParts, mw.ustring.char(173), '')
                cleanParts = mw.ustring.gsub(cleanParts, '&shy;', '')
                -- Split the cleaned string into a table
                call.part = text.split( cleanParts, true )
            end
            
            -- Also inherit logo (Bron) if not set locally
            local logo = extract.parameter( bookContent, call.message.TEMPLATENAME, call.message.HOOK.PARAMETER[10], call )
            if logo and logo[1] and not call.source then
                call.source = text.trim( logo[1] )
            end
            
            -- Inherit title if not set
            local title = extract.parameter( bookContent, call.message.TEMPLATENAME, call.message.HOOK.PARAMETER[6], call )
            if title and title[1] and not call.title then
                call.title = text.trim( title[1] )
            end
        end
    end

    -- If we still have no parts, we might be a standalone chapter, use unnamed parameters if provided
    if #call.part == 0 and #call.unnamed > 0 then
        call.part = call.unnamed
    end

    -- Ensure all parts are cleaned and filter out empty ones
    local validParts = {}
    for _, p in ipairs( call.part ) do
        local cleanP = text.trim(tostring(p))
        cleanP = mw.ustring.gsub(cleanP, mw.ustring.char(173), '')
        cleanP = mw.ustring.gsub(cleanP, '&shy;', '')
        if cleanP ~= "" then
            table.insert(validParts, cleanP)
        end
    end
    call.part = validParts
    
    if type(call.content) ~= "table" then
        call.content = {}
    end
    call.content.part = call.part;
    -- Part 1: Save root and title
    local saved_unnamed = {}
    for i = 1, 20 do saved_unnamed[i] = call.unnamed[i] end
    call.unnamed_sources = saved_unnamed -- Targeted copy instead of full clone

    local title = mw.title.getCurrentTitle()
    local pagename = title.text
    local sub = title.subpageText
    local base = title.baseText
    local root = title.rootText
    
    local categories = {}
    
    -- Part 1: Content Category
    if sub ~= "Printversie" then
        local cat_name = root
        if base == "Programmeren in PL/1" then
            cat_name = "Programmeren in PL/1"
        end
        
        local clean_pagename = mw.ustring.gsub( pagename, "%?", "" )
        local parts = mw.text.split( clean_pagename, "/" )
        local sortkey = ""
        if #parts > 1 then
            table.remove( parts, 1 )
            sortkey = table.concat( parts, "/" )
        end
        table.insert( categories, string.format( "[[Categorie:%s - inhoud|%s]]", cat_name, sortkey ) )
    end
    
    -- Part 2: Chapter Category (Switch logic)
    local chapter_cat = "Hoofdstuk"
    table.insert( categories, string.format( "[[Categorie:%s]]", chapter_cat ) )
    
    -- Part 3: Glossary
    if mw.ustring.find( mw.ustring.lower( pagename ), "woordenlijst" ) then
        table.insert( categories, "[[Categorie:Woordenlijst]]" )
    end
    
    -- Centralized Source Processing: Parse raw unnamed parameters into structured sources
    call.appendix_sources = {}
    for i = 1, 20 do
        local v = call.unnamed_sources[i]
        if v and type(v) == "string" and v:find(";") then
            local fields = mw.text.split(v, "%s*;%s*")
            if #fields >= 2 then
                table.insert(call.appendix_sources, {
                    soort = mw.text.trim(fields[1] or ""),
                    titel = mw.text.trim(fields[2] or ""),
                    url = mw.text.trim(fields[3] or ""),
                    bron = mw.text.trim(fields[4] or ""),
                    beschrijving = mw.text.trim(fields[5] or "")
                })
            end
        end
    end

    call.content.categories = table.concat( categories )

    return call;
end

return chapter