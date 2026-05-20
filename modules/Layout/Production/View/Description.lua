local description = {};

function description.main( call )
   local frame = call.frame;
   return frame.args[ "part" ];
end

function description.box( description, color )
	if not description or type(description) ~= "string" or description == "" then return ""; end
	local description_box = mw.html.create('div')
	description_box
	    :css({
	        ['text-align'] = 'center',
	        ['margin-top'] = '16px',
	        ['margin-bottom'] = '32px'
	    })
	
	local description_text = mw.html.create('i')
	description_text
	    :wikitext(description)
	    :css({
	        ['color'] = color
	    })
	
	description_box:node(description_text)
	
	return tostring(description_box)
end

return description;
