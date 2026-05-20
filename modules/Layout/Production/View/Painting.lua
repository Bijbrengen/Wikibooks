local painting = {};

function painting.main( call )
    local response = "";
    local definition, description = call.include( "definition", "description" );
    
    if call.source then
        -- Standard thumbnail for a painting
        response = response .. mw.ustring.format('[[Bestand:%s|thumb|center|400px|%s]]', call.source, call.title or call.message.PAINTING.NAME );
    end
    
    if call.definition then
        response = response .. definition.box( call.definition, call.color[1].tints[8] );
    end
    
    if call.description then
        response = response .. description.box( call.description, call.color[1].tints[2] );
    end
    
    return response;
end

return painting;
