import requests
import time
import sys

# Zorg dat de output in UTF-8 is
if sys.stdout.encoding != 'utf-8':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.detach())

# --- CONFIGURATIE ---
USERNAME = "BeeBringer"
BOT_NAME = "DeleteTechnologieBot"
BOT_PASSWORD = "sb1h508eb2midrm75s68ggs56brkjtan"
API_URL = "https://nl.wikibooks.org/w/api.php"

PAGES_TO_DELETE = [
    "Onderwijstechnologie/Bewegings-, energie- en lifestyle monitoring systeem",
    "Onderwijstechnologie/Computer anxiety",
    "Onderwijstechnologie/Computer onderhouden",
    "Onderwijstechnologie/Digitale leermaterialen",
    "Onderwijstechnologie/Educatieve software, hardware en websites",
    "Onderwijstechnologie/Educatieve software/hardware/websites",
    "Onderwijstechnologie/Ergonomie",
    "Onderwijstechnologie/ICT aspecten",
    "Onderwijstechnologie/ICT en 'doven en slechthorenden'",
    "Onderwijstechnologie/ICT en afstandsonderwijs in het Vlaamse onderwijs",
    "Onderwijstechnologie/ICT en beperkingen",
    "Onderwijstechnologie/ICT en laaggeletterden",
    "Onderwijstechnologie/ICT en leerstoornissen",
    "Onderwijstechnologie/ICT en mindervalide leerlingen",
    "Onderwijstechnologie/ICT en sekse",
    "Onderwijstechnologie/Juridisch",
    "Onderwijstechnologie/Klastechnologie",
    "Onderwijstechnologie/Klastechnologie/Blogs",
    "Onderwijstechnologie/Klastechnologie/Digitaal toetsen",
    "Onderwijstechnologie/Klastechnologie/Digitale boeken en papier",
    "Onderwijstechnologie/Klastechnologie/Digitale schoolborden",
    "Onderwijstechnologie/Klastechnologie/Digitale schooltafels",
    "Onderwijstechnologie/Klastechnologie/Digitale toetsen",
    "Onderwijstechnologie/Klastechnologie/Presentatietips",
    "Onderwijstechnologie/Klastechnologie/Videoprojectoren",
    "Onderwijstechnologie/Klastechnologie/iPad en onderwijs",
    "Onderwijstechnologie/Plaats van de leerkracht in het e-learningverhaal",
    "Onderwijstechnologie/Rapport",
    "Onderwijstechnologie/Rapport Project OpiniO",
    "Onderwijstechnologie/Rapport SLO Economische Wetenschappen en Rechten 2011-2012",
    "Onderwijstechnologie/Resultatenrapport Cat-project met MDL2",
    "Onderwijstechnologie/Second Life",
    "Onderwijstechnologie/Vakgerichte ICT/Economische wetenschappen",
    "Onderwijstechnologie/Veiligheid online",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Lichamelijke Opvoeding en Bewegingswetenschappen 3/Rapport",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/RapportSLO Taal en Letterkunde 4 2011-2012",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport Agogische Wetenschappen - Groep culturele",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport Agogische Wetenschappen Groep Sociale agogiek",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport BioGezRev 2012-2013",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport Blended Learning by Moodle",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport CultMaatschappij2 2012-2013",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport LIO 1 2012-2013",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport LK 2012-2013",
    "Onderwijstechnologie/Voorbeelden onderwijstechnologische realisaties/Rapport LO Beweging 1 2012-2013"
]

def run_delete_bot():
    print(f"DeleteBot start voor {len(PAGES_TO_DELETE)} pagina's...")
    
    session = requests.Session()
    session.headers.update({'User-Agent': 'DeleteBot/1.0 (Gebruiker:BeeBringer)'})

    try:
        # 1. Inloggen
        token_res = session.get(API_URL, params={"action": "query", "meta": "tokens", "type": "login", "format": "json"}).json()
        login_token = token_res["query"]["tokens"]["logintoken"]

        login_res = session.post(API_URL, data={
            "action": "login",
            "lgname": f"{USERNAME}@{BOT_NAME}",
            "lgpassword": BOT_PASSWORD,
            "lgtoken": login_token,
            "format": "json"
        }).json()

        if login_res["login"]["result"] != "Success":
            print(f"❌ Inloggen mislukt: {login_res['login'].get('reason', 'Onbekend')}")
            return
        
        print("✅ Ingelogd met verwijder-rechten!")

        # 2. Pagina's verwijderen
        delete_count = 0
        for title in PAGES_TO_DELETE:
            # CSRF token ophalen
            res = session.get(API_URL, params={"action": "query", "meta": "tokens", "type": "csrf", "format": "json"}).json()
            csrf_token = res["query"]["tokens"]["csrftoken"]
            
            print(f"Verwijderen: {title}...")
            del_res = session.post(API_URL, data={
                "action": "delete",
                "title": title,
                "reason": "Opschonen van verouderde of verplaatste pagina's in Onderwijstechnologie",
                "token": csrf_token,
                "format": "json"
            }).json()
            
            if "delete" in del_res:
                print(f"   🗑️  Verwijderd.")
                delete_count += 1
            else:
                err = del_res.get("error", {}).get("info", "Onbekende fout")
                print(f"   ❌ Fout: {err}")
            
            time.sleep(2) # Korte pauze tussen verwijderingen

        print(f"🏁 Klaar! Totaal {delete_count} pagina's verwijderd van Wikibooks.")

    except Exception as e:
        print(f"💥 Kritieke fout: {e}")

if __name__ == "__main__":
    run_delete_bot()
