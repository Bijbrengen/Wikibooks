local content = {}

function content.main( call )
    local convert = call.include( "convert" );
    call.content = convert.date_to_age( call );
    return call;
end

return content;
