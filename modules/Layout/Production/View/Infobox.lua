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
    local subpage_name = mw.title.getCurrentTitle().subpageText;
    local infobox_title = 'Wikibooks:Infobox/' .. subpage_name;
    local infobox_page = mw.title.new( infobox_title );
    local print_page_title = subpage_name .. '/Printversie';
    local print_page = mw.title.new( print_page_title );

    local container = mw.html.create('div');
    container:addClass('noprint');

    if infobox_page.exists then
        local htmlTable = mw.html.create('table');
        htmlTable:addClass( 'bookInfobox' );
        local tr = mw.html.create('tr');
        local td1 = mw.html.create('td');
        td1:wikitext( string.format( '[[File:Messagebox info.png|30px|link=%s]]', infobox_title ) );
        tr:node( td1 );
        if print_page.exists then
            local td2 = mw.html.create( 'td' );
            td2:wikitext( string.format( '[[File:Exquisite-print printer.png|30px|link=%s]] ', print_page_title ) );
            tr:node( td2 );
        end
        if ( pdf ~= nil and pdf ~= "" ) then
            local td3 = mw.html.create( 'td' );
            td3:wikitext( string.format( '[[File:Nuvola mimetypes pdf.png|30px|link=media:%s.pdf]]', pdf ) );
            tr:node( td3 );
        end
        htmlTable:node( tr );
        container:node( htmlTable );
        container:wikitext( call.message.INFOBOX.CATEGORY );
  else
        local span = mw.html.create( 'span' );
        span:wikitext( string.format( call.message.INFOBOX.NONE, infobox_title ) );
        container:node(span);
  end
  return tostring( container );
end

function infobox.info( call )
	local markup = call.include( "markup" );
	return markup.click_with_link( "30px", "Wikibooks:Infobox", "Information icon.svg" );
end

function infobox.content( call )
    local bookshelf = "boekenplank"
    local booktype = "boekentype"

    local htmlTable = mw.html.create('table')
        :addClass('vatop')
        :css('width', '100%')
    
    for _, detail in ipairs(call.content.detail) do
	    if detail.value and detail.value ~= "" then
	        htmlTable:tag('tr')
	            :tag('th')
	            :wikitext( detail.name )
	            :done()
	            :tag('td')
	            :wikitext( detail.value )
	    end
    end
 
    return tostring( htmlTable )
end

return infobox;
