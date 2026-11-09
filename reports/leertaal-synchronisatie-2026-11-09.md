# Synchronisatie en publicatie Leertaal — 9 november 2026

## Resultaat

- 350 beschikbare pagina’s opgehaald en lokaal gespiegeld, inclusief doorverwijzingen.
- Alle 56 hoofdtitels/prefixen uit de aangeleverde lijst via de API op subpagina’s gecontroleerd. De aanvullende inventarisatie leverde 21 titels op, waarvan één eveneens ontbreekt.
- 53 lokale boek-/paginaboommappen met leesindex en revisiemetadata. Hieronder vallen ook een handleiding en oude titelaliassen; het is geen telling van 53 zelfstandige inhoudelijke boeken.
- 25 bestaande online pagina’s bijgewerkt en de inhoud na upload gecontroleerd.
- De zestien bestaande pagina’s van Leertaal (hoofdpagina en vijftien hoofdstukken) bevatten nu de uitgewerkte opzet. Aanvullende onderwerpen zijn als paragrafen opgenomen en met sectielinks verbonden.
- In de actuele inhoud van de opgehaalde pagina’s staat de oude benaming niet meer. Het woord kan nog in ongewijzigde historische bewerkingssamenvattingen, titelaliassen en hun bronmetadata voorkomen.

## Indeling van de aanvullende inhoud

| Onderwerp | Hoofdstuk en paragraaf |
| --- | --- |
| Architectuur | Inleiding#Architectuur |
| Grondslagen | Logica#Grondslagen |
| Leeruitspraak | Definitie#Leeruitspraak |
| Leeractor | Typen#Leeractor |
| Leeractie | Leren#Leeractie |
| Leerobject | Leerbox#Leerobject |
| Leercontext | Vrijheid#Leercontext |
| Leerproces | Toepassing#Leerproces |

De beschrijving gebruikt algemene wikitaal. Indelingen, afhankelijkheden en verwachte leerwerking worden als modelaannamen behandeld. Persoonsnamen, een specifieke taalnaam, financiering en projectverantwoording zijn niet in de toegevoegde inhoud opgenomen. Begrippen verwijzen waar passend naar beschikbare boeken uit de aangeleverde lijst.

De algemene hoofdstukken zijn inhoudelijk aangesloten: declaratieve notatie, alternatieve type-indeling, prompting, interpreter, conversie, testen en portfolio blijven behandeld. Een technisch geldige beschrijving wordt onderscheiden van een ware leerclaim; domeindekking van Turing-volledigheid; en een correctielus van blijvende modeltraining.

## Publicatie

De aanwezige botlogin heeft bewerkrechten maar geen recht om nieuwe pagina’s aan te maken. De eerste poging tot aanmaken werd met `cantcreate` geweigerd. Daarom is alle aanvullende inhoud in bestaande hoofdstukken geïntegreerd. Er zijn geen nieuwe pagina’s nodig of aangemaakt. Bij de verificatie is rekening gehouden met het feit dat MediaWiki een laatste regeleinde verwijdert.

[Publicatierevisies per pagina](leertaal-publicatie-2026-11-09.json).

## Niet-beschikbare titels

De volgende opgevraagde titels hebben geen beschikbare pagina. Hiervoor is geen inhoud verzonnen:

- `Onderwijstaal`
- `Onderwijsdeskundige/Resultaten`
- `Ondernemend onderwijs`
- `Onderwijstechnoloog/Onderwijstaal`
- `Onderwijstechnoloog/Omgeving`
- `Ontdekkend leren`
- `Onderwijsdeskundige`

De nog bestaande oude subpaginatitels verwijzen naar de nieuwe titels en zijn als redirects gespiegeld. Ze zijn geen actieve oude hoofdstukken. De hoofdstukkenlijst van Onderwijstechnoloog is aangepast naar de bestaande pagina Leertaal.

## Controles

Alle 350 tekstbestanden zijn vergeleken met de opgehaalde revisies. De boekkopieën en collectiekopieën zijn gelijk. De 25 publicaties zijn na upload gecontroleerd; wikitextbegrenzingen en nieuwe verwijzingen naar eigen boeken zijn gecontroleerd. Bronopmaak uit andere opgehaalde boeken is exact behouden, inclusief eventueel bestaande eindspaties.

Een sitebrede zoekindex kan nog oude treffers tonen na wijziging. Buiten de opgehaalde bibliotheek is het woord ook een algemene historische term, bijvoorbeeld in een hoofdstuk over BASIC. Dat is geen verwijzing naar het hernoemde boek en is niet als onderdeel van deze boekbewerking aangepast.

## Herhalen

Ophalen:

```sh
python3 tools/sync-library.py --list page-lists/mijn-boeken.txt --state /tmp/wikibooks-bronmomentopname.json
```

Publiceren gebeurt met een afzonderlijk plan dat bronrevisie, bestand, hash en bewerkingssamenvatting per pagina bevat. Zonder `--apply` voert het publicatiescript alleen een lokale controle uit. Een revisieconflict stopt de publicatie zodat tussentijdse bijdragen niet worden overschreven. Loginwaarden worden niet gelogd. De bestaande PowerShell-tools en het eerdere synchronisatiescript blijven beschikbaar.
