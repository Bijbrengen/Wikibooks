-- The view of the template as a wiki-object
local template = {};

-- This function is called by the interface by default
function template.main( call )
	local result =     call.content.header;
	
	-- The view consists of a header, the template documentation and adds the template to the correct category
	result = result .. template.hiding( call );
	result = result .. template.elaboration( call );
	result = result .. call.message.TEMPLATE.CATEGORY;
	
	-- The result is returned as a string with wikitext and HTML
    return result;
end

-- This function formats in HTML the message about hiding the template-documentation when included
function template.hiding( call )
    local hiding = mw.html.create('div');
    hiding:addClass('sjabdocnoot');
    hiding:cssText(   string.format([[
        color: %s;
        text-align: center;
        margin-top: 1em;
        font-size: small;
    ]], call.color[1].tints[1] ) );
    hiding:wikitext( call.message.TEMPLATE.HIDING );
    return tostring( hiding );
end

-- This function displays the documentation itself
function template.elaboration( call )
    local documentation = mw.html.create('div')
    documentation:addClass('toccolours template-documentation');
    documentation:cssText( string.format( [[
        background: %s;
        color: black;
        border: 1px solid %s;
        font-size: 100%%;
    ]], call.color[2].tints[10], call.color[2].tints[2] ) );
    documentation:wikitext( call.content.elaboration );

    return tostring( documentation );
end

return template;
