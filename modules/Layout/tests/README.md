# Layout tests

Deze map maakt de lokale mirror van `Module:Layout` testbaar.

## Wat wordt getest?

- De mirror is compleet volgens `_manifest.json`.
- Expliciete `require("Module:Layout/...")` verwijzingen bestaan lokaal of staan bewust in
  `known_legacy_requires.json`.
- De bestaande Wikibooks-testmodules onder `Production/Test` zijn vindbaar.
- `Sjabloon:Opmaak` is als fixture aanwezig en roept `Module:Layout|production` aan met de
  verwachte parameterbrug van Nederlands sjabloonveld naar Lua-frame-argument.

De fixture `fixtures/Sjabloon_Opmaak.raw.wiki` is de ruwe bron van
https://nl.wikibooks.org/wiki/Sjabloon:Opmaak en hoort bij de test van de route
boekpagina/sjabloon naar `Module:Layout`.

## Snelste check

```powershell
python -m unittest discover -s wikibooks/modules/Layout/tests -p "test_*.py"
```

Deze statische tests hebben geen Lua of MediaWiki nodig.

## Lua-tests draaien

```powershell
python wikibooks/modules/Layout/tests/run_layout_tests.py
```

De wrapper draait eerst de statische tests. Als `lua`, `lua5.1` of `luajit` beschikbaar is, draait
die daarna `run_layout_tests.lua`.

Een losse suite draaien:

```powershell
python wikibooks/modules/Layout/tests/run_layout_tests.py --suite Text
```

Alle gespiegeld aanwezige Lua-suites draaien:

```powershell
python wikibooks/modules/Layout/tests/run_layout_tests.py --all
```

De Lua-runner gebruikt een kleine `mw`/`frame` stub. Dat is genoeg voor library-achtige tests zoals
`Array`, `Text`, `Color`, `Pattern` en `Timestamp`. Volledige MediaWiki-template-expansie blijft een
taak voor een echte MediaWiki/Scribunto-installatie.

## Legacy paden

Een paar gespiegeld modules verwijzen nog naar oude namen, bijvoorbeeld
`Module:Layout/Configuration` en `Module:Layout/Production/Library/Test`. De harness aliaset die
lokaal naar de huidige productievarianten. De statische test houdt deze lijst expliciet bij, zodat
we later gericht kunnen opschonen.
