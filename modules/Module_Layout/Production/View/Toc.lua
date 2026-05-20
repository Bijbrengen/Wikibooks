-- This view returns a Table of Contents
local toc = {};

-- For now only a floating TOC is returned
function toc.main( call )
	local response = "";
	response = toc.float();
    return response;
end

function toc.float()
    local toc = mw.html.create( 'div' );
    toc:addClass( 'toc' );
    toc:css( 'float', 'left' );
    toc:wikitext( '__TOC__' );
    return tostring( toc );
end

function toc.none()
    local toc = mw.html.create('div');
    toc:wikitext('__NOTOC__');
    return tostring( toc );
end

function toc.box( elements, max_elements_title_lines, max_subelements )
    local toc_box_wrapper = mw.html.create( 'div' );
    toc_box_wrapper:css({
        ['margin']     = '0 auto',
        ['text-align'] = 'center'
    })

    local toc_box = mw.html.create( 'div' );
	toc_box:css({
	    ['display'] = 'flex',
	    ['flex-wrap'] = 'wrap',
	    ['justify-content'] = 'center',
	    ['align-items'] = 'flex-start',
	    ['gap'] = '20px',
	})

    if elements then
    	local all_elements_content = ""
		for i, element in ipairs(elements) do
		    all_elements_content = all_elements_content .. toc.element(element.number, element.text, element.caption, element.subelements, element.button, max_elements_title_lines, max_subelements)
		end
        toc_box:wikitext(all_elements_content)
    end
    toc_box_wrapper:node( toc_box );

    return tostring( toc_box_wrapper );
end

function toc.element(number, text, caption, subelements, button, max_title_lines, max_subelements)
    local div = mw.html.create('div')
        :css('font', "13px 'Lucida Sans', 'trebuchet MS', Arial, Helvetica")
        :css('background', '#fff')
        :css('border', '2px solid #ddd')
        :css('color', '#333')
        :css('padding', '20px')
        :css('width', '180px')
        :css('float', 'left')
        :css('position', 'relative')
        :css('margin', '5px 5px')
        :css('box-shadow', '0 2px 2px -1px rgba(0,0,0,.3)')

	local calculated_height = max_title_lines * 20
	local divTitle = mw.html.create('div')
	    :css('position', 'relative')
	    :css('font-size', '20px')
	    :css('font-weight', 'normal')
	    :css('text-transform', 'uppercase')
	    :css('padding', '40px')
	    :css('margin', '-20px -20px 20px -20px')
	    :css('border-bottom', '8px solid')
	    :css('background-color', '#eee')
        :css('color', 'black')
	    :css('background-image', 'linear-gradient(#fff, #eee)')
	    :css('border-bottom-color', (tonumber(number) % 2 == 0) and "#040034" or "#0B0080")
	    :css('white-space', 'normal')
	    :css('overflow', 'hidden')
	    :css('text-overflow', 'ellipsis')
	    :css('overflow-wrap', 'break-word')
	    :css('height', tostring(calculated_height) .. 'px')
	    :css('display', 'flex')
	    :css('align-items', 'center')
	    :css('justify-content', 'center')
	    :wikitext(text)

    div:node(divTitle)

    div:tag('div')
        :css('font-size', '13px')
        :css('margin-bottom', '20px')
        :css('text-transform', 'uppercase')
        :css('color', '#999')
        :wikitext(caption)

    div:tag('div')
        :css('font-size', '45px')
        :wikitext(number)

	local calculated_height = math.min(max_subelements * 38, 400)
	local subelements_div = mw.html.create('div')
	    :css('display', 'block')
	    :css('height', tostring(calculated_height) .. 'px')
	    :css('overflow-y', 'hidden')
	    :css('margin-top', '30px')
	    :css('margin-bottom', '30px')
	
	local ul = mw.html.create('ul')
	    :css('margin', '20px 0')
	    :css('padding', '0')
	    :css('list-style', 'none')
	    :css('height', '100%')

	if subelements then
	    for i, subelement in ipairs(subelements) do
	    	local li_output = subelement ~= '-' and mw.ustring.format('<b>%d.</b> %s', i, subelement) or '&nbsp;';
	    	if i > 10 then li_output = "&darr;&darr;&darr;" end
	        local li = mw.html.create('li')
	            :css('padding', '10px 0')
	            :wikitext( li_output )
	        ul:node(li)
	    end
	end
	
	-- Voeg de ul toe aan de div
	subelements_div:node(ul)
    div:node(subelements_div)

    div:tag('div')
        :css('position', 'relative')
        :css('padding', '10px 20px')
        :css('color', '#fff')
        :css('font', 'bold 14px Arial, Helvetica')
        :css('text-transform', 'uppercase')
        :css('text-decoration', 'none')
        :css('display', 'inline-block')
        :css('background-color', '#e7e5ff')
        :css('color', 'black')
        :css('border-radius', '3px')
        :css('text-shadow', '0 -1px 0 rgba(0,0,0,.15)')
        :css('opacity', '.9')
        :wikitext(button)

    return tostring(div)
end

return toc;