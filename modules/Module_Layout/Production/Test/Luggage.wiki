local test = {};
-- local testframe = mw.getCurrentFrame();

-- local CFG       = require( "Module:Layout/Production/Configuration" );
-- local luggage   = CFG.INCLUDE( "production", "luggage" );

function test.main()
--     local result = "<ol>";
--     result = result .. "<li>" .. test.drop()       .. "</li>";
--     return result .. "</ol>";
end

-- function test.drop()
-- 	local call = luggage.drop( testframe, CFG, "production" );
-- 	local result1 = "Leeftijd,Boek,Categorie,Hoofdstuk,Schaak,Concept,Voettekst,Koptekst,Infobox,Logo,Module,Persoon,Schilderij,Voortgang,Paragraaf,Reeks,Overleg,Sjabloon,Gebruiker,Wikijunior,Wikipedia";
-- 	local result = "";

-- 	-- Iterate over the key-value pairs in the table
-- --	for key, value in pairs( call ) do
-- --	    -- Concatenate the key and value with an equal sign and a space as the separator
-- --	    result = result .. key .. "=" .. tostring( value ) .. " ";
-- --	end
--     if table.concat( call.message.HOOK.OBJECT, "," ) == result1 then 
--     	result = result .. "The call.message.HOOK.OBJECT is filled correctly.";
--     else
--     	result = result .. "The call.message.HOOK.OBJECT should be " .. result1 .. " but is " .. table.concat( call.message.HOOK.OBJECT, "," );
--     end

-- 	return result;
-- end

return test;