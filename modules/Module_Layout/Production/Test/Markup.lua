local test = {}

local CFG        = require( "Module:Layout/Production/Configuration" );
local markup     = CFG.INCLUDE( "production", "markup" );
local unittest   = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_markup_click_with_link()
    local result = markup.click_with_link("150px", "TestLink", "TestAfbeelding.jpg")
    
    self:assertStringContains( 'position:relative', result, true, "Outer div has position:relative" )
    self:assertStringContains( 'width:150px', result, true, "Width is 150px" )
    self:assertStringContains( 'height:150px', result, true, "Height is 150px" )
    self:assertStringContains( '[[:TestLink|___]]', result, true, "Link is generated" )
    self:assertStringContains( '[[image:TestAfbeelding.jpg|150px|TestLink]]', result, true, "Image is generated" )
end

function test:test_markup_click_with_link_invalid_args()
    self:assertDoesNotThrow( function() markup.click_with_link(nil, nil, nil) end, "Should not crash on nil arguments" )
end

return test;
