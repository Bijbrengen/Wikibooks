local valid = {}

-- Only allow 6-digit hexadecimal color codes
function valid.color( hexcode )
	-- string.match( hexcode, "^#(%x%x%x)$" ) is also correct for colorcodes but not in this module
	if string.match( hexcode, "^#(%x%x%x%x%x%x)$" ) then return true; end
	return false;
end

function valid.mediafile( logo )
	if not valid.text( logo ) then return false; end
    local file_extension = logo:match('^.+%.(%a+)$');
    if not valid.text( file_extension ) then return false; end
    file_extension = string.lower( file_extension );
    if     file_extension == 'jpg' 
        or file_extension == 'jpeg'
        or file_extension == 'png'
        or file_extension == 'gif'
        or file_extension == 'svg'
        or file_extension == 'ogg'
        or file_extension == 'webm'
    then
        return true;
    end
    return false;
end

-- Check if pagename fulfills the rules for a page title as described on https://www.mediawiki.org/wiki/Manual:Page_title
function valid.title( pagename ) -- :boolean
	if not pagename or type( pagename ) ~= "string" or pagename == "" or string.sub( pagename, 1, 1) == ":" then return false; end
	-- Enhance strict rules on pagename beyond that of title.new will allow.
    local special_characters = {",", "#", "(", ")", ".", "+", "&"};
    for i = 1, #special_characters do
        if string.find( pagename, "%" .. special_characters[i]) ~= nil then
            return false;
        end
    end
    local title = mw.title.new( pagename );
    if title == nil then return false; end
    return true;
end

return valid;
