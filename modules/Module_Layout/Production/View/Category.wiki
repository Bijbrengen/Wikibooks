local category = {};

function category.main( call )
   return "";
end

function category.link( title, call )
	return "[[" .. call.message.CATEGORY.NAME .. ":" .. title .. "]]";
end

return category;