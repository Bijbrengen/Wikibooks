local markup= {}

function markup.click_with_link( size, link, image)
    local div_outer = mw.html.create('div')
        :css('position', 'relative')
        :css('height', size)
        :css('width', size)
        :css('overflow', 'hidden');
    
    local div_link = mw.html.create('div')
        :css('position', 'absolute')
        :css('top', '0')
        :css('left', '0')
        :css('font-size', '100px')
        :css('height', size)
        :css('width', size)
        :css('overflow', 'hidden')
        :css('line-height', '100px')
        :css('z-index', '3')
        :wikitext('[[:' .. link .. '|___]]');
    
    local div_image = mw.html.create('div')
        :css('position', 'absolute')
        :css('top', '0')
        :css('left', '0')
        :css('z-index', '2')
        :wikitext('[[image:' .. image .. '|' .. size .. '|' .. link .. ']]');
    
    div_outer
        :node(div_link)
        :node(div_image);
    
    return tostring(div_outer);
end

return markup;
