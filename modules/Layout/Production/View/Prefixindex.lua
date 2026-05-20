local prefixindex = {};

function prefixindex.main( call )
	local response = "";
	response = call.content;
    return response;
end

function prefixindex.icon( size, link, image, call )
	local markup = call.include( "markup" );
	return markup.click_with_link( size, link, image);
end

return prefixindex;
