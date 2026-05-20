local infobox = {};

function infobox.main( call )
   return infobox.page( call );
end

function infobox.page( call )
	local prefixindex, progress = call.include( "prefixindex", "progress" );
	
    local infobox_page = mw.html.create('table')
                       :addClass('infobox')
                       :css('width', '600px')
                       :css('border-spacing', '0')
                       :css('background-color', '#fff')
                       :css('color', 'black')
    if call.content.title then
        infobox_page:tag('tr')
               :tag('td')
               :wikitext( progress.svg( call.content.progress, "32", call ) )
               :tag('td')
               :wikitext( prefixindex.icon( "30px", "Special:Prefixindex/" .. call.content.title, "Looking glass Hexagonal Icon.svg", call ) )
               :tag('td')
               :wikitext( string.format( '[[%s|%s]]', call.content.title, call.content.title ) )
               :tag('td')
               :wikitext( infobox.info( call ) )
               :tag('tr')
               :tag('td')
               :attr('colspan', '4')
               :wikitext( infobox.content( call ) );
    end
    return tostring( infobox_page )
end

function infobox.icon( pdf, call )
    local title = mw.title.getCurrentTitle();
    local subpage_name = title.subpageText;
    local root_name = title.rootText;
    
    -- Enforce root name if pdf is empty or nil
    if not pdf or pdf == "" then
        pdf = root_name;
    end

    local infobox_title = 'Wikibooks:Infobox/' .. subpage_name;
    local infobox_page = mw.title.new( infobox_title );
    local print_page_title = subpage_name .. '/Printversie';
    local print_page = mw.title.new( print_page_title );

    local container = mw.html.create('div');
    container:addClass('noprint');

    local table = mw.html.create('table');
    table:addClass( 'bookInfobox' )
         :attr('cellspacing', '5')
         :attr('cellpadding', '0');
    local tr = mw.html.create('tr');
    local has_content = false;

    if infobox_page and infobox_page.exists then
        local td1 = mw.html.create('td'):css('width', '35px');
        td1:wikitext( string.format( '[[File:Messagebox info.png|30px|link=%s]]', infobox_title ) );
        tr:node( td1 );
        has_content = true;
    end

    if print_page and print_page.exists then
        local td2 = mw.html.create( 'td' ):css('width', '35px');
        td2:wikitext( string.format( '[[File:Exquisite-print printer.png|30px|link=%s]] ', print_page_title ) );
        tr:node( td2 );
        has_content = true;
    end

    if ( pdf ~= nil and pdf ~= "" ) then
        local td3 = mw.html.create( 'td' ):css('width', '35px');
        local gen_url = tostring( mw.uri.fullUrl( 'Speciaal:DownloadAsPdf', { page = pdf, action = 'download' } ) );
        
        td3:wikitext( string.format( '[[File:PDF file icon.svg|30px|link=%s|Download de meest actuele PDF van dit boek]]', gen_url ) );

        tr:node( td3 );
        has_content = true;
    end

    if has_content then
        table:node( tr );
        container:node( table );
        container:wikitext( call.message.INFOBOX.CATEGORY );
        return tostring( container );
    end

    return "";
end

function infobox.info( call )
	local markup = call.include( "markup" );
	return markup.click_with_link( "30px", "Wikibooks:Infobox", "Information icon.svg" );
end

function infobox.content( call )
    local bookshelf = "boekenplank"
    local booktype = "boekentype"

    local table = mw.html.create('table')
        :addClass('vatop')
        :css('width', '100%')
    
    if type(call.content.detail) == "table" then
        for _, detail in ipairs(call.content.detail) do
            if detail.value and detail.value ~= "" then
                table:tag('tr')
                    :tag('th')
                    :wikitext( detail.name )
                    :done()
                    :tag('td')
                    :wikitext( detail.value )
            end
        end
    end
 
    return tostring( table )
end

return infobox;