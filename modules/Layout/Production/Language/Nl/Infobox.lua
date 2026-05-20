local INFOBOX = {};

INFOBOX.NAME = "Infobox";
INFOBOX.NONE = "<br>Er bestaat nog geen infobox voor dit boek. Klik [[%s|hier]] om die aan te maken.<br>";
INFOBOX.CATEGORY = "[[Categorie:Wikibooks:Boeken met infobox]]";
INFOBOX.BOOKTYPE = "Boekentype";
INFOBOX.INSTRUCTION = "instructie";
INFOBOX.NUMBER_OF_CHAPTER = "Aantal hoofdstukken";
INFOBOX.ACTIVITY = "Activiteit";
INFOBOX.ACTIVITY_LOW = "laag";
INFOBOX.DESCRIPTION = "Beschrijving";
INFOBOX.PROJECTPAGE = "Projectpagina";
INFOBOX.CONTRIBUTORS = "Belangrijkste&nbsp;auteurs";
INFOBOX.CONTRIBUTORS_TEXT = "bijdragers"
INFOBOX.CONTRIBUTORS_API = "https://nl.wikibooks.org/w/api.php?action=query&titles=%s&prop=contributors&format=xml";
INFOBOX.STARTDATE = "Startdatum";
INFOBOX.STARTDATE_TEXT = "eerste revisie";
INFOBOX.STARTDATE_API = "https://nl.wikibooks.org/w/api.php?action=query&titles=%s&prop=revisions&rvlimit=1&rvdir=newer&rvprop=timestamp&format=xml";

return INFOBOX;
