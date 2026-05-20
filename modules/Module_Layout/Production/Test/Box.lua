local test = {};

local CFG      = require( "Module:Layout/Production/Configuration" );
local box     = CFG.INCLUDE( "production", "box" );
local unittest = CFG.INCLUDE( "production", "unittest" );

test = unittest:new();

function test.main( frame )
	return test.run( frame );
end

function test:test_Box_Logo()
	local result = 'FOUT: De waarde <leeg> van de <b>Bron</b> parameter is niet geldig!';
	local result2 = 'FOUT: De waarde Trash van de <b>Bron</b> parameter is niet geldig!';
	local result3 = 'FOUT: De waarde Trash.trash van de <b>Bron</b> parameter is niet geldig!';
	local result4 = '<div>[[File:Huma.JPG|300px|Logo|center]]</div>';
    self:assertEquals( result , box.logo()               , "No parameter given" );
    self:assertEquals( result , box.logo( {} )           , "No string given" );
    self:assertEquals( result , box.logo( "" )           , "Empty parameter given" );
    self:assertEquals( result , box.logo( true )         , "Bool given" );
    self:assertEquals( result2, box.logo( "Trash" )      , "No correct mediafile syntax" );
    self:assertEquals( result3, box.logo( "Trash.trash" ), "No correct mediafile extension" );
    self:assertEquals( result4, box.logo( "Huma.JPG" )   , "Valid Huma.JPG" );
end

function test:test_Box_Progress()
	local result = '<div style="border-bottom:1px solid grey">Dit boek is in ontwikkeling. Volg de wijzigingen door bij elk hoofdstuk op de ster te klikken of gebruik de toetscombinatie [alt+shift+w]</div>';
    self:assertEquals( result, box.progress() );
    self:assertEquals( result, box.progress( {} ) );
    self:assertEquals( result, box.progress( "" ) );
end

function test:test_Box_Wikijunior()
	local definitie_error =  "FOUT: De waarde <leeg> van de <b>Definitie</b> parameter is niet geldig!";
    self:assertEquals( definitie_error, box.wikijunior() );
    self:assertEquals( definitie_error, box.wikijunior( {} ) );
    self:assertEquals( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%"><div>&nbsp;[[Afbeelding:Wikibooks-logo.png|25px|Wikibooks]]&nbsp;&nbsp;[[Hoofdpagina|Wikibooks]] heeft een boek over [[Wikijunior:Test|Test]]</div></div>', box.wikijunior( "Test" ) );
end

function test:test_Box_Wikipedia()
	local definitie_error =  "FOUT: De waarde <leeg> van de <b>Definitie</b> parameter is niet geldig!";
    self:assertEquals( definitie_error, box.wikipedia() );
    self:assertEquals( definitie_error, box.wikipedia( {} ) );
    self:assertEquals( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%"><div>&nbsp;[[Afbeelding:Wikipedia-logo.png|25px|Wikipedia]]&nbsp;&nbsp;[[w:Hoofdpagina|Wikipedia]] heeft een artikel over [[w:Test|Test]]</div></div>', box.wikipedia( "Test" ) );
end

function test:test_Box_Wikiproject()
	local definitie_error =  "FOUT: De waarde <leeg> van de <b>Definitie</b> parameter is niet geldig!";
    self:assertEquals( definitie_error, box.wikiproject() );
    self:assertEquals( definitie_error, box.wikiproject( {} ) );
    self:assertEquals( '<div class="toccolours" style="clear:both;margin:1em 0px -0.5em 0px;width:99%"><div>Test</div></div>', box.wikiproject( "Test" ) );
end

return test;