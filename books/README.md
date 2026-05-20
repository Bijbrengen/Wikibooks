# Wikibooks Books

Deze map bevat lokale mirrors van Wikibooks-boeken en paginabomen die inhoudelijk samenhangen met
de Leerpret-artikelen.

Waarom lokaal beheren:

- de inhoud kan onder Git worden gevolgd;
- bronmateriaal uit Wikibooks kan expliciet worden gekoppeld aan artikelen, casussen en simulator;
- wijzigingen kunnen eerst lokaal worden verbeterd voordat ze naar Wikibooks gaan;
- de relatie tussen `Module:Layout` en de boeken die ermee worden opgemaakt blijft zichtbaar.

## Formaat

Elke mirror krijgt een eigen map met:

- `_manifest.json`: metadata per pagina, inclusief Wikibooks-titel en revision-id;
- `_index.md`: leesbaar overzicht van de opgehaalde pagina's;
- `.wiki`-bestanden: ruwe wikitext per pagina.

De bestandsstructuur volgt de Wikibooks-subpagina's.

## Syncen

Gebruik vanuit de repo-root:

```powershell
.\wikibooks\tools\sync-wikibook.ps1 -Title "Filosofisch onderwijs"
```

Voor een boek met veel subpagina's:

```powershell
.\wikibooks\tools\sync-wikibook.ps1 -Title "Entreprenasium"
```

De tool haalt de hoofdpagina en alle subpagina's met dezelfde prefix op via de MediaWiki API.

## Huidige lokale mirrors

- `Filosofisch onderwijs`
- `Leren leren`
- `Onderwijsarchitect`
- `Entreprenasium`
- `Ondernemend leren`
- `Onderwijstechnoloog`
- `Onderwijsprofessional`
- `Leerparadijs`
