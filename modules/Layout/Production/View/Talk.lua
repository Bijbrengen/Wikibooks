local talk = {};

function talk.main( call )
	local box = call.include( "box" );
    local title = mw.title.getCurrentTitle();
    local talkTitle = title.talkPageTitle;
    
    if not talkTitle then
        return "";
    end

    local linkText = call.message.TALK.NAME .. " " .. call.message.PREPOSITION.ABOUT .. " " .. title.prefixedText;
    local link = string.format( "[[%s|%s]]", talkTitle.prefixedText, linkText );
    
    return box.wikiproject( link );
end

return talk;
