local box = {};

function box.wikiproject( wiki )
	if ( wiki == nil or type( wiki ) ~= 'string' or wiki == "" ) then return string.format( CFG.ERROR.NO_CORRECT_DEFINITION_PARAMETER, "<leeg>" ); end
    local wrapper_wikiproject = mw.html.create('div');
    wrapper_wikiproject:addClass('toccolours');
    wrapper_wikiproject:css({
        width  = '99%',
        clear  = 'both',
        margin = '1em 0px -0.5em 0px',
    });

    local wikiproject = mw.html.create('div');
    wikiproject:wikitext( wiki );

    wrapper_wikiproject:node( wikiproject );
    wrapper_wikiproject:allDone();

    return tostring( wrapper_wikiproject );
end

return box;
