# Lokale MediaWiki-testomgeving

Deze map is bedoeld voor een lokale MediaWiki/Scribunto-testomgeving voor de Wikibooks-mirrors.

Belangrijk:

- de MediaWiki-software zelf wordt niet in Git opgenomen;
- extensies, skins, databasebestanden, uploads, cache en `LocalSettings.php` worden genegeerd;
- commit hier alleen eigen documentatie, configuratievoorbeelden of import-/exportscripts.

De broninhoud blijft in:

- `wikibooks/books/`
- `wikibooks/modules/`
- `wikibooks/collections/`

De lokale MediaWiki is alleen een validatielaag om te testen of modules en sjablonen zich gedragen
zoals verwacht in een echte Scribunto/ParserFunctions-omgeving.
