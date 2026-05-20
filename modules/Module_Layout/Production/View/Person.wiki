local person = {};

function person.main( call )
    local response = "";
    local definition, description = call.include( "definition", "description" );
    
    if call.source then
        -- Standard thumbnail for a person (portrait)
        response = response .. mw.ustring.format('[[Bestand:%s|thumb|left|200px|%s]]', call.source, call.title or call.message.PERSON.NAME );
    end
    
    if call.title then
        response = response .. mw.ustring.format('== %s ==\n', call.title);
    end

    if call.definition then
        response = response .. definition.box( call.definition, call.color[2].tints[8] );
    end
    
    if call.description then
        response = response .. description.box( call.description, call.color[2].tints[2] );
    end
    
    -- Clear float
    response = response .. '<div style="clear:both;"></div>';
    
    return response;
end

return person;