local content = {}

function content.main( call )
	local array, extract, text = call.include( "array", "extract", "text" );
	local content = {};
	
	local title = mw.title.getCurrentTitle();
	content.title = "";
	if title then content.title = title.subpageText; end
    
    content.progress = "0";
    content.detail = {};
    content.detail[1] = {};
    content.detail[1].name = call.message.BOOKSHELF.NAME;
	content.detail[1].value = "";
    content.detail[2] = {};
    content.detail[2].name = call.message.INFOBOX.BOOKTYPE;
	content.detail[2].value = call.message.INFOBOX.INSTRUCTION;
    content.detail[3] = {};
    content.detail[3].name = call.message.INFOBOX.NUMBER_OF_CHAPTER;
	content.detail[3].value = "0";
    content.detail[4] = {};
    content.detail[4].name = call.message.INFOBOX.ACTIVITY;
	content.detail[4].value = call.message.INFOBOX.ACTIVITY_LOW;
    content.detail[5] = {};
    content.detail[5].name = call.message.INFOBOX.STARTDATE ;
	content.detail[5].value = "";
    content.detail[6] = {};
    content.detail[6].name = call.message.INFOBOX.CONTRIBUTORS ;
	content.detail[6].value = "";
    content.detail[7] = {};
    content.detail[7].name = call.message.INFOBOX.DESCRIPTION;
	content.detail[7].value = "";
	content.detail[8] = {};
    content.detail[8].name = call.message.INFOBOX.PROJECTPAGE;
	content.detail[8].value = "";

	local wiki_title = mw.title.new( content.title );
	if wiki_title then
        local url_title = mw.uri.encode( content.title, "WIKI" );

 	    local progress_parameters = extract.parameter( wiki_title:getContent(), call.message.TEMPLATENAME, call.message.PARAM.PROGRESS, call );
	    if progress_parameters and progress_parameters[1] and #progress_parameters[1] > 0 then
			content.progress = progress_parameters[1];
	    end
	
		local bookshelf = false;
 	    local collection_parameters = extract.parameter( wiki_title:getContent(), call.message.TEMPLATENAME, call.message.PARAM.COLLECTION, call );
	    if collection_parameters and collection_parameters[1] and #collection_parameters[1] > 0 then
	       local serie_wiki_title = mw.title.new( collection_parameters[1] );
	       if serie_wiki_title.exists then 
	           local serie_collection_parameters = extract.parameter( serie_wiki_title:getContent(), call.message.TEMPLATENAME, call.message.PARAM.COLLECTION, call );
	           if serie_collection_parameters and serie_collection_parameters[1] and #serie_collection_parameters[1] > 0 then
                   	bookshelf = serie_collection_parameters[1];
               end
           else
           	   bookshelf = collection_parameters[1];
           end
	    end
        if bookshelf then content.detail[1].value = string.format( "[[%s:%s|%s]]", call.message.BOOKSHELF.NAME, bookshelf, bookshelf ); end

	    local part_parameters = extract.parameter( wiki_title:getContent(), call.message.TEMPLATENAME, call.message.PARAM.PART, call );
	    if part_parameters and part_parameters[1] then
	    	local parts = text.split( part_parameters[1], true );
	    	content.detail[3].value = tostring( #parts );
	    end

	    content.detail[5].value = call.message.INFOBOX.STARTDATE_TEXT .. string.format( "[%s]", string.format( call.message.INFOBOX.STARTDATE_API, url_title ) );
	    content.detail[6].value = call.message.INFOBOX.CONTRIBUTORS_TEXT .. string.format( "[%s]", string.format( call.message.INFOBOX.CONTRIBUTORS_API, url_title ) );

	    local description_parameters = extract.parameter( wiki_title:getContent(), call.message.TEMPLATENAME, call.message.PARAM.DEFINITION, call );
	    if description_parameters and description_parameters[1] then
	    	content.detail[7].value = description_parameters[1];
	    end
	    
	    content.detail[8].value = string.format( "[[%s|%s]]", wiki_title.talkPageTitle.fullText, wiki_title.talkNsText );
    end

    call.content = content;
    return call;
end

return content;
