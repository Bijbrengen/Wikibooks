local test = {};

local CFG       = require("Module:Layout/Configuration");
local library   = CFG.LOAD.LIBRARY();
local layout    = CFG.LOAD.LAYOUT();
local unittest  = CFG.LOAD.LIBRARY_TEST();
local book      = CFG.LOAD.BOOK();
local testframe = mw.getCurrentFrame();

test = unittest:new();

function test:test_System_Book()
    self:assertEquals( 'Testing', book.main( testframe ) );
end

function test:test_System_Template_usage()
	local new_testframe = testframe:newChild{title='wrong title'};
	local child_new_testframe = new_testframe:newChild{title='testcase'};
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.book( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.chapter( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.book_series( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.module_doc( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.user( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.category( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.talk( child_new_testframe ) );
    self:assertEquals( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.infobox( child_new_testframe ) );
	new_testframe = testframe:newChild{title=CFG.LOCATION.INTERFACE_TEMPLATE};
	child_new_testframe = new_testframe:newChild{title='testcase'};
	child_new_testframe.args[ "part" ] = "Koptekst";
	local title = mw.title.getCurrentTitle();
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.book( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.chapter( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.book_series( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.module_doc( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.user( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.category( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.talk( child_new_testframe ), true );
    self:assertNotStringContains( CFG.ERROR.NO_INTERFACE_TEMPLATE, layout.infobox( child_new_testframe ), true );
end

return test;