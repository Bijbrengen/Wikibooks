# Wikibooks Mirrors

Deze map bevat lokale mirrors van Wikibooks-pagina's die we willen verbeteren, testen of
herstructureren voordat wijzigingen teruggaan naar Wikibooks.

Werk bij voorkeur lokaal:

1. mirror ophalen of verversen;
2. wijzigingen maken in Git;
3. lokale checks uitvoeren;
4. diff/release-notes maken;
5. pas daarna de wijziging handmatig of via een geautoriseerde MediaWiki-flow op Wikibooks zetten.

Voor live wijzigingen is een geldige Wikibooks-login met passende rechten nodig. Lokale voorbereiding,
revisiecontrole en een expliciet wijzigingsplan gaan vooraf aan publicatie.

## Bibliotheek en synchronisatie

Zie [alle lokale boeken en paginabomen](books/README.md), de [actuele titellijst](page-lists/mijn-boeken.txt) en het [synchronisatie- en publicatieverslag](reports/leertaal-synchronisatie-2026-11-09.md).

De Python-tools `tools/sync-library.py` en `tools/publish-library.py` ondersteunen een volledige bibliotheekmirror en publicatie van een expliciet gecontroleerd wijzigingsplan. Het publicatiescript bewaakt bronrevisies en verifieert de inhoud na upload.
