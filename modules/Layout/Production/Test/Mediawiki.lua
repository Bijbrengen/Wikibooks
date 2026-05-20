local test = {};

local CFG       = require("Module:Layout/Configuration");
local mediawiki = CFG.LOAD.LIBRARY_MEDIAWIKI();
local unittest  = CFG.LOAD.LIBRARY_TEST();
local testframe = {};
local testpath  = "Module:Layout/Test/Testcases/";
local private   = {};

test = unittest:new();

local testpage = {
	not_exist          = testpath .. "Does_Not_Exist",     -- Page is not existing.
	empty              = testpath .. "Empty",              -- Page has no content.
	only_text          = testpath .. "Empty Page"          -- Page has only text into it. No headings, templates or whatsoever.
}


return test;
