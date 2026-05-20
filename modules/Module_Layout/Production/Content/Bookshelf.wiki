local content = {}

function content.main( call )
	local array, extract, progress, text = call.include( "array", "extract", "progress", "text" );
	
    call.content = {};
    call.content.name = mw.title.getCurrentTitle().prefixedText;
	local text_strings = {}
	for i, s in ipairs(call.unnamed) do
	   if s and s ~= "" then
	   	  table.insert(text_strings, text.trim(s)) 
	   end
	end
	call.content.text = text_strings
	
	call.content.book = {}
	for i, book in ipairs(call.part) do
	    if book and book ~= "" then
	        table.insert( call.content.book, extract.book_progress( book, call ) );
	    end
	end

    return call;
end

return content;