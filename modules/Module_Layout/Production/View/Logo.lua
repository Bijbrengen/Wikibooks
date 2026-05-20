local logo = {};

function logo.main( call )
    return logo.box( call );
end

function logo.box( call )
    local response = mw.html.create('div');
    if call.source and type( call.source ) == "string" and #call.source ~= 0 then
        response:wikitext( string.format('[[File:%s|300px|Logo|center]]', call.source ) );
    end
    return tostring( response );
end

return logo;