local section = {};

function section.main( call )
    local response = "";
    
    if call.title then
        response = response .. mw.ustring.format('== %s ==\n', call.title);
    end

    local text = table.concat( call.unnamed, "\n\n" );
    if call.part[1] then text = table.concat( call.part, "\n\n" ); end
    
    response = response .. text;
    
    return response;
end

return section;