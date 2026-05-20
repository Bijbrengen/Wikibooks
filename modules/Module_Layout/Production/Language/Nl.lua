local LANGUAGE = {};

LANGUAGE.TEMPLATENAME = "Opmaak";

local BUTTON = {};
BUTTON.READ = "LEES";

local HOOK = {};
HOOK.FORMAT         = { "Tekst", "HTML", "Koptekst", "Voettekst" };
HOOK.ORIENTATION    = { "Landscape",  "Portrait", "Wit", "Zwart" };
HOOK.OBJECT         = { "Leeftijd", "Boek", "Boekenplank", "Categorie", "Hoofdstuk", "Schaken", "Concept", "Definitie", "Beschrijving", "Gradiënt", "Infobox", "Logo", "Module", "Persoon", "Schilderij", "Voortgang", "Sectie", "Serie", "Overleg", "Sjabloon", "Inhoud", "Gebruiker", "Wikijunior", "Wikipedia" };
HOOK.PARAMETER      = { "Object", "Support", "Formaat", "Orientatie", "Kleur", "Titel", "Definitie", "Beschrijving", "Voortgang", "Bron", "Referentie", "Collectie", "Onderdeel" };
HOOK.SUPPORT        = { "Negeer", "Signaleer", "Debug", "Help" };

local DEBUG = {};
DEBUG.CALLER                = "De module stelt vast dat de [[%s]] is aangeroepen door de pagina [[%s]]."
DEBUG.EXPLANATION           = "Zie de [[Module:Layout]]-pagina om het programma stap voor stap te volgen.";
DEBUG.HEADER                = "De volgende stappen heeft het sjabloon Opmaak doorlopen";
DEBUG.INVOKER               = "De [[Module:Layout]] stelt vast dat het is aangeroepen door de pagina [[%s]] met de volgende aanroep:<br><br>%s<br>";
DEBUG.NO_INTERFACE_TEMPLATE = "De authenticatie van de aanroepende pagina is afgekeurd omdat het niet via het sjabloon Opmaak is gebeurd.";
DEBUG.PARAMETER_MISTAKE     = "Er is één niet bestaande parameter %s in de aanroep van het [[Sjabloon:Opmaak]]."
DEBUG.PARAMETER_MISTAKES    = "Er zijn %d niet bestaande parameters %s in de aanroep van het [[Sjabloon:Opmaak]]."
DEBUG.PARAMETERS_OK         = "Alle parameters in de aanroep van het [[Sjabloon:Opmaak]] zijn correct."
DEBUG.VALUE_MISTAKE         = "Er is één fout geconstateerd in de waarde van de parameters van het [[Sjabloon:Opmaak]]."
DEBUG.VALUE_MISTAKES        = "Er zijn %d fouten geconstateerd in de waarde van de parameters van het [[Sjabloon:Opmaak]]."
DEBUG.VALUES_OK             = "Alle waarden van alle parameters in de aanroep van het [[Sjabloon:Opmaak]] zijn correct."

local HELP = {};
HELP.EXPLANATION           = "Zie de [[Sjabloon:Opmaak]]-pagina voor meer uitleg.";
HELP.HEADER                = "Het sjabloon adviseert je het volgende te proberen";

local MISTAKE = {};
MISTAKE.EXPLANATION           = "Zie de [[Sjabloon:Opmaak]]-pagina voor meer uitleg.";
MISTAKE.HEADER                = "Fouten geconstateerd";
MISTAKE.NO_INTERFACE_TEMPLATE = "De [[Module:Layout|module Layout]] mag alleen aangeroepen worden via het sjabloon Opmaak.\nGebruik dus niet &lcub;&lcub;#invoke:Layout|...&rcub;&rcub; maar &lcub;&lcub;Opmaak | ... &rcub;&rcub;.";

local WRONG = {};
WRONG.COLOR              = "De kleur %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Kleur = %s | ... &rcub;&rcub; moet een opsomming zijn van maximaal 3 hexadecimale (met of zonder de #) 6-digit kleurcodes!\nHier is een voorbeeld (blauw, oranje, paars); %s, %s, %s.";
WRONG.FORMAT             = "Het formaat %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Formaat  = %s | ... &rcub;&rcub; bestaat niet!\nGebruik een van de volgende types; %s.";
WRONG.HTML               = "De HTML-opmaak in de parameter %s bevat een ongebalanceerde tag (bijvoorbeeld de &lt;%s&gt; tag). Zorg dat elke HTML-tag correct wordt geopend en afgesloten om lintfouten te voorkomen.";
WRONG.INVOKE_PARAMETER   = "De invokeparameter %s die is gespecificeerd met &lcub;&lcub;#invoke | ... | %s  = %s | ... &rcub;&rcub; bestaat niet!\nGebruik het Opmaak sjabloon."
WRONG.OBJECT             = "Het type object %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Object  = %s | ... &rcub;&rcub; bestaat niet!\nGebruik een van de volgende types; %s.";
WRONG.ORIENTATION        = "De orientatie %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Orientatie = %s | ... &rcub;&rcub; bestaat niet!\nGebruik een van de volgende types; %s.";
WRONG.PAGE               = "De type pagina %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Pagina = %s | ... &rcub;&rcub; bestaat niet!\nGebruik een van de volgende types; %s.";
WRONG.PAGENAMELIST       = "De paginanaam %s zoals gespecificeerd in &lcub;&lcub;Opmaak | ... | %s = %s | ... &rcub;&rcub; is niet correct. Gebruik komma's om de pagina's te scheiden en gebruik geldige titles zoals beschreven in https://www.mediawiki.org/wiki/Manual:Page_title.";
WRONG.PROGRESS           = "De voortgang %s zoals gespecificeerd in &lcub;&lcub;Opmaak | ... | Voortgang = %s | ... &rcub;&rcub; is niet correct. Gebruik gehele getallen tussen 0 en 100 en sluit eventueel af met een %%.";
WRONG.SUPPORT            = "De type foutmelding %s die is gespecificeerd met &lcub;&lcub;Opmaak | ... | Foutmelding = %s | ... &rcub;&rcub; bestaat niet!\nGebruik een van de volgende types; %s.";
WRONG.TEMPLATE_PARAMETER = "De parameter %s zoals gespecificeerd in &lcub;&lcub;Opmaak | ... | %s = %s | ... &rcub;&rcub; bestaat niet.\nGebruik een van de volgende types; %s.";
MISTAKE.WRONG = WRONG;

local PREPOSITION = {};
PREPOSITION.ABOUT = "over";

LANGUAGE.BUTTON  = BUTTON;
LANGUAGE.HOOK    = HOOK;
LANGUAGE.DEBUG   = DEBUG;
LANGUAGE.HELP    = HELP;
LANGUAGE.MISTAKE = MISTAKE;
LANGUAGE.PREPOSITION = PREPOSITION;

return LANGUAGE;