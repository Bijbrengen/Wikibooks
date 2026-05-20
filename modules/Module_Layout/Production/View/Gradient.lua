local gradient = {};

function gradient.main( call )
	local text = table.concat( call.unnamed, "<br>" );
	if call.part[1] then text = table.concat( call.part, "<br>" ); end
	
    return gradient.box( text, "center", call.color[1].hex, call.style.BLACK );
end

function gradient.box( text, align, color, textcolor )
    textcolor = textcolor or 'black'
    local gradient_box = mw.html.create('div');
    gradient_box:css('width', '100%');
    gradient_box:css( 'border-top', '20px solid' );
    gradient_box:css( 'border-bottom', '20px solid' );
    gradient_box:css( 'border-image', 'linear-gradient(to bottom, transparent, ' .. color .. ', transparent) 20' );
    local inner_box = mw.html.create( 'div' );
    inner_box:css({
        ['text-align']      = align,
        ['border-top']      = '20px solid linear-gradient(to bottom, transparent, ' .. color .. ')', 
        ['border-bottom']   = '20px solid linear-gradient(to top, transparent, ' .. color .. ')',
        ['color']           = textcolor,
        ['background-color'] = 'white',
        ['list-style-type'] = 'none'
    });
    inner_box:node(  text );
    gradient_box:node( inner_box );
    return tostring( gradient_box ) ;
end

return gradient;