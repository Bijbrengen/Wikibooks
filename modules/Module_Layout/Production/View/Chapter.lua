local chapter = {};

function chapter.main( call )
    local response = "";
    
    if call.format == "footer" then
        response = chapter.appendix( call );
    elseif call.format == "header" then
        response = chapter.header( call );
    else
        response = chapter.header( call );
    end
    
    response = response .. (call.content.categories or "");
    
    return response;
end

function chapter.header( call )
    local accent_color = call.color[2].hex;
    local root = call.root or ""
    
    local html = mw.html.create('div')
        :addClass('chapter-header-box')
        :css({
            ['float'] = 'right',
            ['width'] = '260px',
            ['margin'] = '0 0 20px 20px',
            ['padding'] = '15px',
            ['background-color'] = '#ffffff',
            ['color'] = '#000000',
            ['border'] = '1px solid #e2e8f0',
            ['border-radius'] = '8px',
            ['text-align'] = 'center'
        })

    if call.source and call.source ~= "" then
        html:tag('div'):css({['margin-bottom'] = '10px'})
            :wikitext(string.format('[[Bestand:%s|120px|center]]', call.source))
    end

    html:tag('div')
        :css({['font-size']='18px', ['font-weight']='800', ['color']=accent_color, ['margin-bottom']='10px'})
        :wikitext(root)

    html:tag('div')
        :css({['font-size']='0.9em', ['margin-bottom']='15px'})
        :wikitext("[[:" .. root .. "|← Terug naar " .. root .. "]]")

    if call.part and #call.part > 0 then
        html:tag('hr'):css({['border']='0', ['border-top']='1px solid #edf2f7', ['height']='0', ['margin']='10px 0'})
        local list = html:tag('ul'):css({['list-style']='none', ['margin']='0', ['padding']='0', ['font-size']='13px', ['text-align']='left'})
        
        local currentTitle = mw.title.getCurrentTitle()
        for _, p in ipairs(call.part) do
            if p and p ~= "" then
                local isCurrent = (currentTitle.subpageText == p) or (currentTitle.text == root .. "/" .. p)
                local item = list:tag('li'):css({['margin-bottom']='5px', ['padding-left']='15px', ['position']='relative'})
                item:tag('div'):css({['position']='absolute', ['left']='0', ['color']=isCurrent and accent_color or '#cbd5e0'}):wikitext("•")
                
                if isCurrent then
                    item:tag('div'):css({['font-weight']='800', ['color']='#2d3748'}):wikitext(p)
                else
                    item:wikitext(string.format('[[%s/%s|%s]]', root, p, p))
                end
            end
        end
    end

    return tostring(html)
end

function chapter.appendix( call )
    local html = mw.html.create('div'):addClass('chapter-appendix'):css({['clear']='both', ['margin-top']='40px'})
    local accent_color = call.color[2].hex
    local border_color = call.color[2].tints[5]
    
    -- 1. Bronnen Section (Only if there are sources)
    if call.appendix_sources and #call.appendix_sources > 0 then
        html:tag('h2'):wikitext("Bronnen")
        html:tag('hr'):css({['border']='0', ['border-top']='1px solid #eee', ['height']='0', ['margin-bottom']='1em'})
        
        local verdieping = html:tag('div'):css({['margin-bottom']='20px'})
        verdieping:tag('h3'):wikitext("Verdieping")
        
        local htmlTable = verdieping:tag('table'):css({['width']='100%', ['border-collapse']='collapse', ['font-size']='14px', ['border']='1px solid #e2e8f0'})
        local headerRow = htmlTable:tag('tr'):css({['background-color']='#f8f9fa', ['color']='#000000'})
        
        local function addH(t, w) 
            headerRow:tag('th'):css({['padding']='10px', ['text-align']='left', ['border-bottom']='2px solid '..border_color, ['width']=w, ['font-size']='11px', ['text-transform']='uppercase'}):wikitext(t) 
        end
        addH("Soort", "12%") addH("Bron", "23%") addH("Link", "15%") addH("Beschrijving", "50%")
        
        for i, s in ipairs(call.appendix_sources) do
            local row = htmlTable:tag('tr'):css({['background-color']=(i%2==0 and "#fcfcfc" or "#ffffff"), ['color']='#000000', ['border-bottom']='1px solid #edf2f7'})
            row:tag('td'):css({['padding']='8px'}):wikitext("'''"..s.soort.."'''")
            row:tag('td'):css({['padding']='8px'}):wikitext(s.titel)
            local link = s.url:match("^http") and "["..s.url.." "..(s.bron~="" and s.bron or "Link").."]" or s.url
            row:tag('td'):css({['padding']='8px'}):wikitext(link)
            row:tag('td'):css({['padding']='8px'}):wikitext(s.beschrijving)
        end
    end

    -- 2. Referentie (The manual bibliography)
    if call.reference and call.reference ~= "" then
        local ref_section = html:tag('div'):css({['margin-top']='2em', ['padding-top']='1em', ['border-top']='1px solid #eee'})
        ref_section:tag('h3'):wikitext("Referenties")
        local ref_text = type(call.reference) == "table" and table.concat(call.reference, "<br>") or call.reference
        ref_section:tag('div'):css({['font-size']='0.9em', ['color']='#555'}):wikitext(ref_text)
    end
    
    -- 3. Footnotes (Verwijzingen)
    local ref_container = html:tag('div')
        :css({['background-color']='#f8f9fa', ['color']='#000000', ['border']='1px solid #e2e8f0', ['border-left']='5px solid '..accent_color, ['padding']='15px', ['margin-top']='30px', ['font-size']='90%'})
    
    ref_container:tag('div'):css({['font-weight']='800', ['margin-bottom']='10px', ['text-transform']='uppercase'}):wikitext("Verwijzingen")
    ref_container:tag('div'):addClass('mw-references-wrap'):wikitext(call.frame:extensionTag('references', ''))
        
    return tostring(html)
end

function chapter.sub( call )
    return ""
end

return chapter;
