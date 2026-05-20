local bookshelf = {};

local private = {};

function bookshelf.main( call )
	local response = "";
    response = response .. bookshelf.list( call.content.book, call );
    return response;
end

function bookshelf.box( color, image, link, books, call )
	local gradient = call.include( "gradient" );
	
	local div = mw.html.create('div')

	local image_div = mw.html.create('div')
	    :wikitext( image )
	    :done();
	local b_tag = mw.html.create('b')
	    :wikitext( link )
	    :done();
	local span_tag = mw.html.create('span')
	    :attr('style', 'font-size: large;')
	    :node(b_tag)
	    :done();
    local br_tag = mw.html.create('br')	    
	    :done();
    local booklist = mw.html.create('p')
        :wikitext( bookshelf.list( books, call ) )
	    :done();

	div
	    :node(image_div)
	    :node(span_tag)
	    :node(br_tag)
	    :node(booklist)

    return gradient.box( tostring(div), 'center', color );
end

function bookshelf.list( books, call )
	local progress = call.include( "progress" );
	local response = "";
	for i, book in ipairs( books ) do
        local div_book = mw.html.create('div')
            :css('display', 'inline-flex')
            :css('align-items', 'center')
        local span_text = mw.html.create('span')
            :wikitext( book.text );
        div_book:node( span_text );
        div_book:wikitext( progress.svg( book.progress, "12", call ) );
        response = response .. " - " .. tostring( div_book );
	end
	response = response:gsub("^ %- ", "");
	return response;
end

return bookshelf;
