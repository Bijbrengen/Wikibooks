local box = {};

local function get_definition_error( value )
    value = tostring( value or "<leeg>" )
    if value == "" or value == "nil" then value = "<leeg>" end
    return string.format( "FOUT: De waarde %s van de <b>Definitie</b> parameter is niet geldig!", value )
end

local function get_bron_error( value )
    value = tostring( value or "<leeg>" )
    if value == "" or value == "nil" then value = "<leeg>" end
    return string.format( "FOUT: De waarde %s van de <b>Bron</b> parameter is niet geldig!", value )
end

local function valid_mediafile( logo )
	if type(logo) ~= "string" or logo == "" or logo:match('^%s*$') then return false; end
    local file_extension = logo:match('^.+%.(%a+)$');
    if type(file_extension) ~= "string" or file_extension == "" or file_extension:match('^%s*$') then return false; end
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

function box.logo( logo )
    if logo == nil or type(logo) ~= "string" or logo == "" then return get_bron_error() end
    if not valid_mediafile( logo ) then return get_bron_error( logo ) end
    return string.format( "<div>[[File:%s|300px|Logo|center]]</div>", logo )
end

function box.progress()
    return '<div style="border-bottom:1px solid grey">Dit boek is in ontwikkeling. Volg de wijzigingen door bij elk hoofdstuk op de ster te klikken of gebruik de toetscombinatie [alt+shift+w]</div>'
end

function box.wikijunior( wiki )
    if wiki == nil or type(wiki) ~= "string" or wiki == "" then return get_definition_error() end
    return string.format( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%%"><div>&nbsp;[[Afbeelding:Wikibooks-logo.png|25px|Wikibooks]]&nbsp;&nbsp;[[Hoofdpagina|Wikibooks]] heeft een boek over [[Wikijunior:%s|%s]]</div></div>', wiki, wiki )
end

function box.wikipedia( wiki )
    if wiki == nil or type(wiki) ~= "string" or wiki == "" then return get_definition_error() end
    return string.format( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%%"><div>&nbsp;[[Afbeelding:Wikipedia-logo.png|25px|Wikipedia]]&nbsp;&nbsp;[[w:Hoofdpagina|Wikipedia]] heeft een artikel over [[w:%s|%s]]</div></div>', wiki, wiki )
end

function box.wikiproject( wiki )
	if wiki == nil or type( wiki ) ~= 'string' or wiki == "" then return get_definition_error() end
    return string.format( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%%"><div>%s</div></div>', wiki )
end

return box;