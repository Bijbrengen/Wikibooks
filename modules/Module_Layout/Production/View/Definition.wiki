local definition = {};

function definition.main( call )
	local text = call.definition or table.concat( call.part, "<br>" );
	if (not text or text == "") and call.unnamed[1] then text = table.concat( call.unnamed, "<br>" ); end
	
    return definition.box( text, call.color[1].tints[8] );
end

function definition.box( definition, background_color )
	if not definition then definition = "&nbsp;"; end
    local outer_box = mw.html.create('div');
    outer_box:css({
        ['text-align']            = 'center',
        ['-webkit-border-radius'] = '0% 0% 100% 100% / 0% 0% 8px 8px',
        ['-webkit-box-shadow']    = 'rgba(0, 0, 0,.30) 0 2px 3px',
        ['margin-top']            = '16px'
    });

    local inner_box = mw.html.create('div');
    inner_box:css({
        ['margin']        = '0 auto',
        ['margin-top']    = '32px',
        ['margin-bottom'] = '32px',
        ['height']        = 'auto',
        ['background-color'] = background_color,
        ['color']         = 'black',
        ['border']        = '1px solid #ccc',
        ['box-shadow']    = '1px 1px 2px #fff inset, -1px -1px 2px #fff inset',
        ['border-radius'] = '3px/6px'
    });

    local definition_text = mw.html.create('div');
    definition_text:css('font-weight', 'bold')
    definition_text:wikitext( definition );
    inner_box:node(definition_text);
    outer_box:node( inner_box );
    return tostring( outer_box );
end

return definition;