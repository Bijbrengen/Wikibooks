# Lokale Wikibooks-bibliotheek

De bibliotheek bevat de beschikbare boeken en paginabomen uit de aangeleverde lijst, inclusief de via de API aangetroffen subpagina’s. Oude titels die nog bestaan als doorverwijzing blijven herkenbaar als alias. Iedere map bevat ruwe wikitext, een leesindex en metadata met bronrevisies.

## Synchroniseren

```sh
python3 tools/sync-library.py --list page-lists/mijn-boeken.txt --state /tmp/wikibooks-bronmomentopname.json
```

Met `--exact` worden alleen de titels uit de lijst opgehaald. Zonder die optie worden ook alle subpagina’s geïnventariseerd. Uploaden gebeurt afzonderlijk via een expliciet plan en revisiecontrole.

## Opgehaalde boeken en paginabomen

| Titel | Pagina’s | Lokale map |
| --- | --- | --- |
| Acceptance and commitment therapy | 5 | [Open](Acceptance%20and%20commitment%20therapy/_index.md) |
| Beeldend leren | 11 | [Open](Beeldend%20leren/_index.md) |
| Bewust leren | 1 | [Open](Bewust%20leren/_index.md) |
| Cognitieve zelftherapie | 3 | [Open](Cognitieve%20zelftherapie/_index.md) |
| E-coach | 2 | [Open](E-coach/_index.md) |
| Entreprenasium | 9 | [Open](Entreprenasium/_index.md) |
| Filosofie | 1 | [Open](Filosofie/_index.md) |
| Filosofisch onderwijs | 8 | [Open](Filosofisch%20onderwijs/_index.md) |
| Handleiding moderatoren | 21 | [Open](Handleiding%20moderatoren/_index.md) |
| Hoofdpagina | 1 | [Open](Hoofdpagina/_index.md) |
| Humanature | 21 | [Open](Humanature/_index.md) |
| Hypnotherapie | 6 | [Open](Hypnotherapie/_index.md) |
| Learngames | 7 | [Open](Learngames/_index.md) |
| Leerattractie | 5 | [Open](Leerattractie/_index.md) |
| Leerbroedplaats | 5 | [Open](Leerbroedplaats/_index.md) |
| Leerparadijs | 5 | [Open](Leerparadijs/_index.md) |
| Leerpret | 2 | [Open](Leerpret/_index.md) |
| Leerpretpark | 1 | [Open](Leerpretpark/_index.md) |
| Leerstijl | 1 | [Open](Leerstijl/_index.md) |
| Leertaal | 16 | [Open](Leertaal/_index.md) |
| Leren | 3 | [Open](Leren/_index.md) |
| Leren leren | 9 | [Open](Leren%20leren/_index.md) |
| Meditatie | 9 | [Open](Meditatie/_index.md) |
| Mindfulness | 10 | [Open](Mindfulness/_index.md) |
| Model leren | 5 | [Open](Model%20leren/_index.md) |
| Modelleren | 1 | [Open](Modelleren/_index.md) |
| Onbewust leren | 4 | [Open](Onbewust%20leren/_index.md) |
| Ondernemend leren | 5 | [Open](Ondernemend%20leren/_index.md) |
| Onderwijs | 1 | [Open](Onderwijs/_index.md) |
| Onderwijsarchitect | 11 | [Open](Onderwijsarchitect/_index.md) |
| Onderwijsniveau | 5 | [Open](Onderwijsniveau/_index.md) |
| Onderwijsondernemer | 1 | [Open](Onderwijsondernemer/_index.md) |
| Onderwijsplatform | 1 | [Open](Onderwijsplatform/_index.md) |
| Onderwijsprofessional | 8 | [Open](Onderwijsprofessional/_index.md) |
| Onderwijstaal | 15 | [Open](Onderwijstaal/_index.md) |
| Onderwijstechnoloog | 17 | [Open](Onderwijstechnoloog/_index.md) |
| Onderwijsvorm | 3 | [Open](Onderwijsvorm/_index.md) |
| Onderwijswiki | 16 | [Open](Onderwijswiki/_index.md) |
| Onderzoekend leren | 4 | [Open](Onderzoekend%20leren/_index.md) |
| Ontwerpend leren | 6 | [Open](Ontwerpend%20leren/_index.md) |
| Opvolgend leren | 1 | [Open](Opvolgend%20leren/_index.md) |
| Passend leren | 4 | [Open](Passend%20leren/_index.md) |
| Schaken | 1 | [Open](Schaken/_index.md) |
| Schaken door meesters | 23 | [Open](Schaken%20door%20meesters/_index.md) |
| Schaken voor beginners | 8 | [Open](Schaken%20voor%20beginners/_index.md) |
| Schaken voor experts | 5 | [Open](Schaken%20voor%20experts/_index.md) |
| Schaken voor gevorderden | 11 | [Open](Schaken%20voor%20gevorderden/_index.md) |
| Speels leren | 7 | [Open](Speels%20leren/_index.md) |
| Verhalend leren | 1 | [Open](Verhalend%20leren/_index.md) |
| Visualisatie | 3 | [Open](Visualisatie/_index.md) |
| Vrij leren | 5 | [Open](Vrij%20leren/_index.md) |
| Zelf leren | 9 | [Open](Zelf%20leren/_index.md) |
| Zelftherapie | 1 | [Open](Zelftherapie/_index.md) |
