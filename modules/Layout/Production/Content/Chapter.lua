local chapter = {}

function chapter.main( call )
	local extract, text = call.include( "extract", "text" );
	
    -- Determine the book page (root of the current page)
    local currentTitle = mw.title.getCurrentTitle()
    local bookTitle = mw.title.new( currentTitle.rootText )
    
    -- If we are on a subpage, try to inherit parts from the book page
    if currentTitle.isSubpage and bookTitle and bookTitle.exists then
        local bookContent = bookTitle:getContent()
        if bookContent then
            -- Extract parts (Onderdeel) from the {{Opmaak}} call on the book page
            local parts = extract.parameter( bookContent, call.message.TEMPLATENAME, call.message.HOOK.PARAMETER[13], call )
            if parts and parts[1] and (#call.part == 0) then
                -- Split the string into a table if it's not already
                call.part = text.split( parts[1], true )
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

    return call
end

return chapter
