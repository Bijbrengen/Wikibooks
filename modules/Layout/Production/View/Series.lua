local series = {};

local private = {};

function series.main( call )
	local toc, infobox, progress, logo, definition, description, bookshelf, gradient, wikipedia, category, wikijunior = 
	    call.include( "toc", "infobox", "progress", "logo", "definition", "description", "bookshelf", "gradient", "wikipedia", "category", "wikijunior" );
	local br = mw.html.create('br');
	local background_color = call.color[2].tints[8];
	local box_color = call.color[2].shades[2];
	local text_color = call.color[2].tints[2];	local black = call.color[3].shades[10];
	
	local response = "";
    response = response .. toc.none();
    response = response .. progress.box( call );
    response = response .. infobox.icon( "", call );
    response = response .. logo.box( call );
    response = response .. definition.box( call.definition, background_color );
    response = response .. description.box( call.description, text_color );
    response = response .. bookshelf.box( box_color, call.content.bookshelf.image, call.content.bookshelf.link, call.content.bookshelf.book, call );
    response = response .. toc.box( call.content.book, call.content.max_number_of_book_title_lines, call.content.max_number_of_book_chapters)    
    response = response .. gradient.box( table.concat( call.content.text, tostring(br)..tostring(br) ), 'left', box_color, call.style.BLACK );
    if call.content.wikipedia  then 
    	response = response .. wikipedia.box( call ); 
    else 
    	response = response .. category.link( call.message.CATEGORY.WIKIPEDIA_LINK_MISSING, call );
    end
    if call.content.wikijunior then response = response .. wikijunior.box( call ); end
    return response;
end

return series;
