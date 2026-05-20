local wikijunior = {};

function wikijunior.main( call )
	local response = "";
	response = wikijunior.box( call );
    return response;
end

function wikijunior.box( call )
	local box = call.include( "box" );
	
	if ( call.title == nil or type( call.title ) ~= 'string' or call.title == "" ) then return ""; end
    return box.wikiproject( string.format( call.message.WIKIJUNIOR.INTERLINK, tostring( call.title ), tostring( call.title ) ) );
end

return wikijunior;
