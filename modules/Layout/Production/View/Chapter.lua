local chapter = {};

function chapter.main( call )
	local progress, logo = call.include( "progress", "logo" );
    local bookPage = mw.title.getCurrentTitle().rootText
    
    -- Design tokens matching the Book design language
    local background_color = call.color[3].tints[9];
    local border_color = call.color[3].tints[5];
    local title_color = call.color[3].shades[2];
    
    -- Only render if format is header (Koptekst)
    if call.format ~= "header" then
        return "";
    end
    
    -- Create the container with premium styling
    local container = mw.html.create( 'div' )
        :addClass( 'floatright noprint' )
        :css({
            ['width'] = '300px',
            ['margin'] = '0 0 1.5em 1.5em',
            ['padding'] = '15px',
            ['background-color'] = background_color,
            ['border'] = '1px solid ' .. border_color,
            ['border-radius'] = '10px',
            ['box-shadow'] = '0 4px 10px rgba(0, 0, 0, 0.1)',
            ['font-family'] = 'sans-serif'
        });
    
    -- Logo
    if call.source and call.source ~= "" then
        container:tag('div')
            :css({
                ['text-align'] = 'center',
                ['margin-bottom'] = '15px'
            })
            :wikitext( mw.ustring.format('[[Bestand:%s|120px|center|Logo]]', call.source) )
    end
    
    -- Title
    container:tag('div')
        :css({
            ['text-align'] = 'center',
            ['font-size'] = '1.4em',
            ['font-weight'] = '800',
            ['margin-bottom'] = '10px',
            ['color'] = title_color
        })
        :wikitext( mw.ustring.format('[[%s|%s]]', bookPage, call.title or bookPage) )
    
    -- Separator
    container:tag('hr'):css({
        ['border'] = '0',
        ['border-top'] = '1px solid ' .. border_color,
        ['margin'] = '10px 0'
    })
    
    -- Chapters list
    if #call.part > 0 then
        local list = container:tag('ul')
            :css({
                ['margin'] = '10px 0 10px 20px',
                ['list-style-type'] = 'square',
                ['font-size'] = '0.95em',
                ['line-height'] = '1.6'
            })
            
        for _, part in ipairs( call.part ) do
            local cleanPart = mw.text.trim(part)
            if cleanPart ~= "" then
                local link = bookPage .. "/" .. cleanPart
                list:tag('li'):wikitext( mw.ustring.format('[[%s|%s]]', link, cleanPart) )
            end
        end
    end
    
    -- Progress
    if call.progress then
        container:tag('hr'):css({
            ['border'] = '0',
            ['border-top'] = '1px solid ' .. border_color,
            ['margin'] = '10px 0'
        })
        container:tag('div')
            :css({
                ['padding'] = '5px 0',
                ['text-align'] = 'center'
            })
            :wikitext( progress.box( call ) )
    end
    
    return tostring( container );
end

return chapter;
