local content = {};

local MODULE = {};
MODULE.CODE  = "[[File:Noun Project coding icon 2752876.svg|40x40px|link=%s]]";
MODULE.ICON  = "[[File:LUA layout for Wikibooks.png|200px|right|frameless|link=Module:Layout]]"
MODULE.EDIT  = "[[File:JS Icon Edit.svg|40x40px|link=%s]]";

function content.main( call )
	local text, pattern = call.include( "text", "pattern" );
	
	local result  = {};
	local title   = mw.title.getCurrentTitle();

	local description    = "https://" .. string.lower( call.language ) .. ".wikibooks.org/w/index.php?title=" .. title.fullText .. "/doc&action=edit";
    description = string.format( MODULE.EDIT, description ) .. "&nbsp;";
	local categorylink = call.message.MODULE.CATEGORY;
	if ( title.subpageText == "doc" ) then
		description =  "https://" .. string.lower( call.language ) .. ".wikibooks.org/w/index.php?title=Module:" .. title.baseText;
	    description = string.format( MODULE.CODE, description ) .. "&nbsp;";
	    categorylink = call.message.MODULE.DOCUMENTATION;
	end
	
    if title.rootText == "Layout" then
    	description = description .. string.format( call.message.MODULE.DESCRIPTION, categorylink, call.version ); 
    else
	    if call.description then
	        description = description .. call.description .. "\n";
	    else
	        description = description .. call.message.MODULE.ADD_DESCRIPTION;
	    end
    end
    
	-- If no content is provided set it to an empty string
	local elaboration = ""; 
	if ( text.valid( call.unnamed[ 1 ] ) ) then elaboration = call.unnamed[ 1 ]; end

    -- Determine the category
    local page_title = title.subpageText;
    local page_base  = pattern.last_segment_of_url( title.baseText ); 
	if ( page_title == "doc" ) then 
		local newtitle = title.basePageTitle;
		page_title = newtitle.subpageText;
    	page_base  = pattern.last_segment_of_url( newtitle.baseText ); 
	end
    -- Place only the main module and it's documentationpage in the correct category.
    result.category = "";
    if ( not title.isSubpage ) then
        result.category = "[[" .. call.message.MODULE.CATEGORY .. "]]";	
	elseif ( title.subpageText == "doc" and not title.basePageTitle.isSubpage ) then
        result.category = "[[" .. call.message.MODULE.DOCUMENTATION .. "]]";
	end

    result.description = description;
    result.elaboration = elaboration;
    result.MODULE = MODULE;
    call.content = result;
	return call;
end

return content;
