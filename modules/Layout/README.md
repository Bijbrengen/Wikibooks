# Module:Layout mirror

Lokale mirror van de Nederlandstalige Wikibooks-module:

https://nl.wikibooks.org/wiki/Module:Layout

## Inhoud

- `_module.lua` is de hoofdpagina `Module:Layout`.
- Submodules staan in dezelfde boomstructuur als op Wikibooks.
- Documentatiepagina's eindigen op `.wiki`.
- `_manifest.json` bevat per pagina de Wikibooks-titel, revision-id, timestamp, auteur,
  contentmodel en lokaal bestand.

Deze mirror is opgehaald via de MediaWiki API en is bedoeld om wijzigingen lokaal te ontwerpen
voordat ze naar Wikibooks gaan.

## Herkomst en licentie

De oorspronkelijke inhoud komt van Nederlandstalige Wikibooks. De revision-id, auteur en timestamp
staan per pagina in `_manifest.json`. Behoud deze metadata bij verdere verwerking, zodat wijzigingen
later correct herleidbaar blijven en compatibel blijven met de licentievoorwaarden van Wikibooks.

## Waarom lokaal werken?

Lokaal verbeteren is handig omdat we:

- alle wijzigingen onder Git-versiebeheer hebben;
- grotere refactors veilig kunnen voorbereiden;
- tests of statische controles kunnen toevoegen;
- een nette patch en bewerkingssamenvatting kunnen maken;
- minder risico lopen dat een live module op Wikibooks breekt.

## Testen

De bestaande Wikibooks-testmodules staan onder `Production/Test`. Lokaal staat de test-harness in
`tests/`.

Statische checks, zonder Lua of MediaWiki:

```powershell
python -m unittest discover -s wikibooks/modules/Layout/tests -p "test_*.py"
```

Wrapper voor statische checks en, indien een Lua-runtime beschikbaar is, de Lua-testmodules:

```powershell
python wikibooks/modules/Layout/tests/run_layout_tests.py
```

De lokale Lua-runner simuleert alleen de noodzakelijke `mw`- en `frame`-delen. Voor volledige
Scribunto-template-expansie blijft een lokale MediaWiki/Scribunto-installatie de referentie.

## Terugplaatsen naar Wikibooks

Ik kan niet zelfstandig namens jou inloggen of live wijzigingen publiceren op Wikibooks. Wat ik wel
kan doen:

- de gewenste Lua-code lokaal aanpassen;
- een exacte lijst maken van welke Wikibooks-pagina's gewijzigd moeten worden;
- per pagina de nieuwe wikitext/Lua-code klaarzetten;
- een korte edit summary schrijven;
- desgewenst een MediaWiki API-script voorbereiden dat jij met je eigen account of bot-password
  uitvoert.

Voor live publicatie is de veilige route:

1. eerst wijzigen in `Module:Layout/Sandbox` of een eigen test-submodule;
2. testen via `{{#invoke:Layout|sandbox|...}}` of een testpagina;
3. daarna pas naar `Stage`;
4. uiteindelijk naar `Production`.

## Let op

Scribunto-modules gebruiken MediaWiki-specifieke globals zoals `mw`, `frame` en `require('strict')`.
Gewone Lua-checks kunnen daarom syntax en structuur controleren, maar niet automatisch het volledige
MediaWiki-gedrag simuleren.
