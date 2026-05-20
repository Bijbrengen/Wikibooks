local MODULE = {};

MODULE.NAME          = "Module";
MODULE.CATEGORY      = "Categorie:Module";
MODULE.DOCUMENTATION = "Categorie:Moduledocumentatie";
MODULE.DESCRIPTION   = "'''''Deze [[:%s|module]] is nog in ontwikkeling (versie %s) en wordt [[Module:Layout/Production/Test|getest]].'''''<br>\n" ..
	"De [[Module:Layout]] is bedoeld om snel, consistent en uitgebreid een pagina [[Sjabloon:Opmaak|op te maken]].<br>\n" ..
	"Er is een op de module afgestemde handleiding over deze [[Onderwijswiki|onderwijswiki]] beschikbaar.<br><br>\n" ..
	"''De module wordt geïnitialiseerd met de configuratie in [[Module:Layout/Production/Configuration]].''<br>\n" ..
	"''Controleer op [[:Categorie:Wikibooks:Pagina's met scriptfouten|scriptfouten]], [[Speciaal:LintErrors|lintfouten]] of [[:Categorie:Module Layout|opmaak notificaties]].''";
MODULE.ADD_DESCRIPTION = "Voeg een Beschrijving parameter toe aan het sjabloon:Opmaak\n";

return MODULE;
