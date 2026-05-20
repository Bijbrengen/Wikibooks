local user = {};

function user.main( call )
    local title = mw.title.getCurrentTitle();
    
    if title.namespace == 2 or title.nsText == "Gebruiker" then
        -- Get colors from inventory (fallback to BeeBringer palette if not specified)
        local c1 = call.color[1].hex; -- Main color (default Purple)
        local c2 = call.color[2].hex; -- Accent color (default Orange)
        local c3 = call.color[3].hex; -- Background color (default Dark Orange)
        
        -- Derive data
        local username = title.rootText;
        local display_name = call.title or username;
        local slogan = call.description or 'brengt graag mensen [[Bestand:UserIconTrust.svg|40px]] bij elkaar [[Bestand:Crystal_Clear_app_korn.png|30px]]<span style="font-size: small; vertical-align: super;">[[Speciaal:Emailuser/'..username..'|e-mail]]</span>, <br>en probeert zijn [[Bestand:Bitlbee logo.png|80px]] naam eer aan te doen';
        local goal = call.definition or "'''Ik heb als doel initiatieven te steunen en te ontwikkelen waarbij mensen van elkaar leren door elkaar te ontmoeten. Mijn interesse ligt vooral op het gebied van [[leren]] en [[onderwijs]].'''";

        -- Preset boxes mapping
        local PRESETS = {
            wikipedia = { logo = '[[Bestand:Wikipedia svg logo-nl.svg|center|44x44px]]', text = 'Ik ben op [[w:Gebruiker:%s|Wikipedia]]' },
            wikiwoordenboek = { logo = '[[Bestand:Wiktionary-logo-en.png|center|44x44px]]', text = 'Ik ben op [[wikt:Gebruiker:%s|WikiWoordenboek]]' },
            wikiquote = { logo = '[[Bestand:Wikiquote-logo-en.svg|center|44x44px]]', text = 'Ik ben op [[q:Gebruiker:%s|Wikiquote]]' },
            wikimedia = { logo = '[[Bestand:Wikimedia-logo.svg|center|35px]]', text = 'Ik heb een [[:m:Help:Unified login/nl|universele login]]' },
            wikigroup = { logo = '[[Bestand:Wikigroup.png|center|44x44px]]', text = 'Ik breng graag mensen bijelkaar' },
            bijdrager = { logo = '[[Bestand:PartOfWikipedia.gif|center|44x44px]]', text = 'Ik voeg graag iets nieuws toe' }
        }

        -- Determine which items to show
        local items = call.part;
        if not items or #items == 0 or ( #items == 1 and items[1] == "" ) then
            items = { "wikipedia", "wikiwoordenboek", "wikiquote", "wikimedia", "wikigroup", "bijdrager" }
        end

        -- Helper function to draw a userbox using mw.html
        local function draw_box( border, bg, logo, content )
            local container = mw.html.create('div')
                :css('float', 'left'):css('border', '1px solid ' .. border):css('margin', '1px')
            
            local tbl = container:tag('table')
                :attr('cellspacing', '0'):css('width', '238px')
                :css('background-color', bg):css('color', 'black')
            
            local tr = tbl:tag('tr')
            tr:tag('td')
                :css('width', '45px'):css('max-width', '45px'):css('height', '45px')
                :css('background-color', border):css('text-align', 'center')
                :css('color', 'white')
                :css('font-weight', 'bold'):css('font-size', '14pt')
                :wikitext( logo )
            
            tr:tag('td')
                :css('font-size', '8pt'):css('padding', '4pt'):css('line-height', '1.25em')
                :wikitext( content )
                
            return tostring( container )
        end

        local res = ""
        -- Part 1: Top bar
        local t1 = mw.html.create('table')
            :attr('width', '100%'):css('margin', '0 auto'):css('padding', '1em 0')
            :css('text-align', 'center'):css('letter-spacing', '5px')
            :css('border', '3px solid ' .. c2):css('background', 'white')
            :css('color', c1):css('font', "bold larger 'Helvetica Neue', Helvetica, Arial, sans-serif")
        local header_td = t1:tag('tr'):tag('td')
        header_td:wikitext(string.format('[[Bestand:Logo Onderwijs Wiki-%s.png|Logo]] ', username))
        
        local sub_tag = header_td:tag('span'):css({['font-size']='small', ['vertical-align']='sub'})
        sub_tag:wikitext("[[Gebruiker:" .. username .. "|")
        sub_tag:tag('span'):css({['font-family']='Script', ['font-size']='14px', ['font-weight']='bold', ['color']=c1}):wikitext(display_name)
        sub_tag:wikitext("]]")
        
        header_td:wikitext(" ")
        local sup_overleg = header_td:tag('span'):css({['font-size']='small', ['vertical-align']='super'})
        sup_overleg:wikitext("[[Overleg_gebruiker:" .. username .. "|overleg]]")
        
        header_td:wikitext(string.format('    <span style="color: %s;"><b>%s</b></span>', c2, slogan))
        res = res .. tostring(t1)

        -- Part 2: Spacer bar
        local t2 = mw.html.create('table')
            :attr('width', '100%'):css('margin', '0 auto'):css('padding', '1em 0')
            :css('border', '3px solid ' .. c2):css('background', c2):css('color', c1)
        res = res .. tostring(t2)

        -- Part 3: Grid
        local t3 = mw.html.create('table')
            :attr('width', '100%'):css('margin', '0 auto'):css('padding', '1em 0')
            :css('text-align', 'center'):css('letter-spacing', '5px')
            :css('border', '3px solid ' .. c2):css('background', c3)
            :css('color', 'white'):css('font', "bold larger 'Helvetica Neue', Helvetica, Arial, sans-serif")
        
        local tr3 = t3:tag('tr')
        
        -- Split items into two columns
        local split_at = math.ceil(#items / 2)

        -- Left column
        local td_left = tr3:tag('td')
        for i = 1, split_at do
            local key = mw.text.trim(items[i]:lower())
            local box_data = PRESETS[key]
            if box_data then
                td_left:wikitext( draw_box(c1, c2, box_data.logo, string.format(box_data.text, username)) )
                if i < split_at then td_left:tag('br') end
            end
        end

        -- Middle column: Goal text
        tr3:tag('td'):tag('div'):css('text-align', 'center'):wikitext(goal):done():done()

        -- Right column
        local td_right = tr3:tag('td')
        for i = split_at + 1, #items do
            local key = mw.text.trim(items[i]:lower())
            local box_data = PRESETS[key]
            if box_data then
                td_right:wikitext( draw_box(c1, c2, box_data.logo, string.format(box_data.text, username)) )
                if i < #items then td_right:tag('br') end
            end
        end

        res = res .. tostring(t3)
        return res
    end
    
    return call.part or "";
end

return user;
