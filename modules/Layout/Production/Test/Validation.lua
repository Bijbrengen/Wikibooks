local test = {};

local CFG      = require("Module:Layout/Configuration");
local valid    = CFG.LOAD.LIBRARY_VALIDATION();
local unittest = CFG.LOAD.LIBRARY_TEST();

test = unittest:new();

function test:test_Library_Validation_mediafile()
    self:assertFalse( valid.mediafile()               , "No parameter given" );
    self:assertFalse( valid.mediafile( "" )           , "Empty parameter given" );
    self:assertFalse( valid.mediafile( {} )           , "No string given" );
    self:assertFalse( valid.mediafile( true )         , "Bool given" );
    self:assertFalse( valid.mediafile( "Trash" )      , "No correct mediafile syntax" );
    self:assertFalse( valid.mediafile( "Trash.trash" ), "No correct mediafile extension" );
    self:assertTrue ( valid.mediafile( "Huma.JPG" )   , "Valid Huma.JPG" );
end

function test:test_Library_Validation_text()
    self:assertFalse( valid.text()          , "No parameter given" );
    self:assertFalse( valid.text( "" )      , "Empty parameter given" );
    self:assertFalse( valid.text( {} )      , "No string given" );
    self:assertFalse( valid.text( true )    , "Bool given" );
    self:assertFalse( valid.text( nil )     , "Nil given" );
    self:assertFalse( valid.text( " " )     , "One space" );
    self:assertFalse( valid.text( "      " ), "Multiple spaces" );
    self:assertTrue ( valid.text( "Test" )  , "Valid string" );
end

function test:test_Library_Validation_title()
	local test_too_long = ""
    for i = 1, 256 do
        test_too_long = test_too_long .. "a"
    end
    self:assertFalse( valid.title()          , "No parameter given" );
    self:assertFalse( valid.title( "" )      , "Empty parameter given" );
    self:assertFalse( valid.title( {} )      , "No string given" );
    self:assertFalse( valid.title( true )    , "Bool given" );
    self:assertFalse( valid.title( nil )     , "Nil given" );
    self:assertFalse( valid.title( " " )     , "One space" );
    self:assertFalse( valid.title( "      " ), "Multiple spaces" );
    self:assertFalse( valid.title( "Te#st" )  , "Contains # " );
    self:assertFalse( valid.title( "Tes,t" )  , "Contains , " );
    self:assertFalse( valid.title( "Tes<t" )  , "Contains < " );
    self:assertFalse( valid.title( "T>est" )  , "Contains > " );
    self:assertFalse( valid.title( "Tes[t" )  , "Contains [ " );
    self:assertFalse( valid.title( "T]est" )  , "Contains ] " );
    self:assertFalse( valid.title( "Te|st" )  , "Contains | " );
    self:assertFalse( valid.title( "T{est" )  , "Contains { " );
    self:assertFalse( valid.title( "Tes}t" )  , "Contains } " );
    self:assertFalse( valid.title( "(Test" )  , "Contains ( " );
    self:assertFalse( valid.title( "Test)" )  , "Contains ) " );
    self:assertFalse( valid.title( "T+est" )  , "Contains + " );
    self:assertFalse( valid.title( "Tes~~~t" )  , "Contains ~~~ " );
    self:assertFalse( valid.title( "T&est" )  , "Contains & " );
    self:assertFalse( valid.title( ":Test" )  , "Beginning with : " );
    self:assertFalse( valid.title( ".Test" )  , "Beginning with . " );
    self:assertFalse( valid.title( "%11 Test" )  , "Contains % followed by two hexadecimal digits " );
    self:assertFalse( valid.title( test_too_long )  , "256 characters" ); 
    self:assertTrue ( valid.title( "Te:st" )  , "Contains : but not at the start" );
    self:assertTrue ( valid.title( "Te_st" )  , "Contains _ " );
    self:assertTrue ( valid.title( "Test" )  , "Test" );
    self:assertTrue ( valid.title( "Test1" )  , "Test1" );
    self:assertTrue ( valid.title( "1" )  , "1" );
end
return test;
