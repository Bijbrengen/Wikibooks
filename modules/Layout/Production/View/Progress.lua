local progress = {};

function progress.main( call )
	local response = "";
	response = progress.box( call );
    return response;
end

function progress.box(call)
    local prefixindex = call.include("prefixindex")
    local progress_box = mw.html.create('div')
    progress_box:css('border-bottom', '1px solid grey')
                :css('display', 'flex')
                :css('align-items', 'center')

    if call.title ~= nil and call.title ~= "" then
        local prefixindexDiv = mw.html.create('div')
            :css('display', 'inline-block')
            :css('margin-right', '10px') -- kleine marge aan de rechterkant
            :wikitext( prefixindex.icon( "30px", "Special:Prefixindex/", "Looking glass Hexagonal Icon.svg", call ) )
        progress_box:node(prefixindexDiv)
    end

    if call.progress ~= nil and call.progress ~= "" then
        local progressSvgDiv = mw.html.create('div')
            :css('display', 'inline-block')
            :css('margin-right', '10px') -- kleine marge aan de rechterkant
            :wikitext(progress.svg(call.progress, "32", call))
        progress_box:node(progressSvgDiv)
    end

    local messageDiv = mw.html.create('div')
        :css('display', 'inline-block')
        :wikitext(call.message.PROGRESS.DEVELOPMENT)
    progress_box:node(messageDiv)

    return tostring(progress_box)
end

function progress.svg( progress_string, size, call )
	local text = call.include( "text" );
	progress_string = text.trim( tostring( progress_string ) );
	if string.sub( progress_string, -1) == "%" then
        progress_string = string.sub( progress_string, 1, -2)
    end
	local progress_number = tonumber( progress_string );
	
    if not progress_number    then return mw.ustring.format( call.message.PROGRESS.NOTHING, size ); end
    if progress_number <   13 then return mw.ustring.format( call.message.PROGRESS.NOTHING, size ); end
    if progress_number <   38 then return mw.ustring.format( call.message.PROGRESS.IO, size ); end
    if progress_number <   63 then return mw.ustring.format( call.message.PROGRESS.RO, size ); end
    if progress_number <   78 then return mw.ustring.format( call.message.PROGRESS.GO, size ); end
    if progress_number <= 100 then return mw.ustring.format( call.message.PROGRESS.ZO, size ); end
    return nothing;
end

return progress;
