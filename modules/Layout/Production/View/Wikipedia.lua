local wikipedia = {};

function wikipedia.main( call )
	local response = "";
	response = wikipedia.box( call );
    return response;
end

function wikipedia.box( call )
	local box = call.include( "box" );
	
	if ( call.title == nil or type( call.title ) ~= 'string' or call.title == "" ) then return ""; end
    return box.wikiproject( string.format( call.message.WIKIPEDIA.INTERLINK, tostring( call.title ), tostring( call.title ) ) );
end

return wikipedia;
