-- This view is what you can see above this code
local mdl = {};

-- The main function for viewing a module
function mdl.main( call )
	-- The functions from other modules that are used in this function
	local valid, pattern = call.include( "validation", "pattern" );
	
	-- The outer box contains from left to right the TOC, the elaboration and the icon of a module
    local result = mdl.outer_box( call, mdl.inner_box( call ) );
    result = result .. "\n";
    if call.content.elaboration then result = result .. call.content.elaboration .. "\n"; end
    
    -- Place the module in the correct category
    result = result .. call.content.category;
    
    -- Make sure we return wikitext and HTML  
    return tostring( result );
end

-- The inner box of the view contains the elaboration of the module
function mdl.inner_box( call )
    local inner_box = mw.html.create( 'div' );
    inner_box:addClass( 'inner-box' );
    inner_box:cssText( string.format( [[
        display: inline-block;
        padding: 15px;
        background-color: %s;
        color: black;
        border-radius: 10px;
        border: 1px solid %s;
        transition: border-color 0.2s ease-out;
        box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2);
        text-align: center;
    ]], call.color[1].tints[5], call.color[1].shades[5] ) );
    inner_box:wikitext( call.content.description );
    return inner_box;
end

-- This function returns the outer box of the view of the module.
-- The outer box contains from left to right the TOC, the elaboration and the icon of a module.
function mdl.outer_box( call, inner_box )
	-- The functions from other modules that are used in this function
    local toc = call.include( "toc" );
	
    local outer_box = mw.html.create( 'div' );
    outer_box:addClass( 'outer-box' );
    outer_box:cssText( string.format( [[
        display: inline-block;
        padding: 15px;
        background-color: %s;
        color: black;
        border-radius: 10px;
        border: 1px solid %s;
        transition: border-color 0.2s ease-out;
        text-align: center;
        margin: 10 auto;
        width: 97%%;
    ]], call.color[1].tints[9], call.color[1].tints[5] ) );
  
    outer_box:wikitext( call.content.MODULE.ICON );
    outer_box:node( inner_box );
    outer_box:wikitext( toc.float() );
    return tostring( outer_box );
end

return mdl;