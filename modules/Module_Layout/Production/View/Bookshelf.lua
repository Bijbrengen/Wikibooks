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
	local b_tag = mw.html.create('div')
        :css('font-weight', 'bold')
	    :wikitext( link )
	    :done();
	local span_tag = mw.html.create('div')
	    :css('font-size', 'large')
	    :node(b_tag)
	    :done();
    local br_tag = mw.html.create('br')	    
	    :done();
    local booklist = mw.html.create('div')
        :node( bookshelf.list( books, call ) )
	    :done();

	div
	    :node(image_div)
	    :node(span_tag)
	    :node(br_tag)
	    :node(booklist)

    return "\n" .. mw.text.trim( tostring( gradient.box( tostring(div), 'center', color ) ) ) .. "\n";
end

function bookshelf.list( books, call )
	local progress = call.include( "progress" );
	local container = mw.html.create('div')
	for i, book in ipairs( books ) do
		if i > 1 then container:wikitext(" - ") end
        local div_book = mw.html.create('div')
            :css('display', 'inline-flex')
            :css('align-items', 'center')
        div_book:tag('span')
            :wikitext( book.text );
        div_book:wikitext( progress.svg( book.progress, "12", call ) );
        container:node( div_book );
	end
	return container;
end

return bookshelf;