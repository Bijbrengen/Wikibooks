local test = {};

local CFG      = require("Module:Layout/Configuration");
local chess    = CFG.LOAD.CHESS();
local unittest = CFG.LOAD.LIBRARY_TEST();

test = unittest:new();

function test:test_Library_Chess_rank()
    local even    = '<tr style="vertical-align:middle"><td style="color: black; background-color:white;text-align:center">%s</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld a%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld b%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld c%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld d%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld e%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld f%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld g%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld h%s zonder een schaakstuk]]</td><td style="color: black; background-color:white;text-align:center">%s</td></tr>'
	local uneven  = '<tr style="vertical-align:middle"><td style="color: black; background-color:white;text-align:center">%s</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld a%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld b%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld c%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld d%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld e%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld f%s zonder een schaakstuk]]</td><td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld g%s zonder een schaakstuk]]</td><td style="color: black; background-color:#f59364;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld h%s zonder een schaakstuk]]</td><td style="color: black; background-color:white;text-align:center">%s</td></tr>';
    local result1 = string.format( uneven, "1", "1", "1", "1", "1", "1", "1", "1", "1", "1" );
    local result2 = string.format( uneven, "3", "3", "3", "3", "3", "3", "3", "3", "3", "3" );
    local result3 = string.format(   even, "8", "8", "8", "8", "8", "8", "8", "8", "8", "8" );
	self:assertEquals( result1, tostring( chess.rank( ""         ) ), "empty" );
	self:assertEquals( result1, tostring( chess.rank( 0          ) ), "0" );
	self:assertEquals( result1, tostring( chess.rank( 1          ) ), "1" );
	self:assertEquals( result1, tostring( chess.rank( 9          ) ), "9" );
	self:assertEquals( result2, tostring( chess.rank( 3, ""      ) ), "2 empty" );
	self:assertEquals( result3, tostring( chess.rank( 8, "", ""  ) ), "8 empty empty" );
end

function test:test_Library_Chess_square()
	local result1 = '<td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld a1 zonder een schaakstuk]]</td>';
	local result2 = '<td style="color: black; background-color:#a94617;text-align:center">[[File:Chess t45.svg|26px|alt=Schaakveld h8 zonder een schaakstuk]]</td>';
	local result3 = '<td style="color: black; background-color:#a94617;text-align:center">[[File:Chess kdt45.svg|26px|alt=Schaakveld h8 met een zwarte koning]]</td>';
	local result4 = '<td style="color: black; background-color:#f59364;text-align:center">[[File:Chess qlt45.svg|26px|alt=Schaakveld e4 met een witte koningin]]</td>';
    self:assertEquals( result1, tostring( chess.square( ""         ) ), "empty" );
    self:assertEquals( result1, tostring( chess.square( " "        ) ), "SPACE" );
    self:assertEquals( result1, tostring( chess.square( nil        ) ), "nil" );
    self:assertEquals( result1, tostring( chess.square( "123"      ) ), "123" );
    self:assertEquals( result1, tostring( chess.square( "i1"       ) ), "i1" );
    self:assertEquals( result1, tostring( chess.square( "a9"       ) ), "i1" );
    self:assertEquals( result1, tostring( chess.square( "a1"       ) ), "a1" );
    self:assertEquals( result2, tostring( chess.square( "h8"       ) ), "h8" );
    self:assertEquals( result3, tostring( chess.square( "h8", "kd" ) ), "kd on h8" );
    self:assertEquals( result4, tostring( chess.square( "e4", "ql" ) ), "ql on e4" );
end

function test:test_Library_Chess_square_color()
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( ""      ), "empty" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( nil     ), "nil" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( "i1"    ), "i1" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( "a9"    ), "a9" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( " "     ), "SPACE" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( "d1q"   ), "d1q" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_WHITE, chess.square_color( "d1"    ), "d1" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_BLACK, chess.square_color( "a1"    ), "a1" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_BLACK, chess.square_color( "e1"    ), "e1" );
    self:assertEquals( CFG.STYLE.CHESS.COLOR_BLACK, chess.square_color( "h8"    ), "h8" );
end

return test;
