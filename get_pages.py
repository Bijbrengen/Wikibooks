import requests

# --- CONFIGURATIE ---
API_URL = "https://nl.wikibooks.org/w/api.php"
MIJN_BOEKEN = [
    "Onderwijsontwikkelaar", "Onderwijsprofessional", "Onderwijstechnoloog",
    "Onderwijsarchitect", "Onderwijstechnologie", "Entreprenasium",
    "Ondernemend leren", "Leren leren", "Leerparadijs", "Filosofisch onderwijs"
]

def get_all_pages():
    # Identificeer het script netjes
    headers = {'User-Agent': 'BeeBot/1.0 (Gebruiker:BeeBringer)'}
    session = requests.Session()
    session.headers.update(headers)
    
    all_titles = []
    
    for boek in MIJN_BOEKEN:
        params = {
            "action": "query",
            "list": "allpages",
            "apprefix": boek,
            "aplimit": "500",
            "format": "json"
        }
        try:
            res = session.get(API_URL, params=params).json()
            pages = res.get("query", {}).get("allpages", [])
            for p in pages:
                all_titles.append(p["title"])
        except Exception as e:
            print(f"Fout bij ophalen van {boek}: {e}")
            
    # Dubbele titels verwijderen en sorteren
    all_titles = sorted(list(set(all_titles)))
    
    # Print alles in een blok dat je zo kunt kopiëren
    print("--- START LIJST ---")
    for t in all_titles:
        print(t)
    print("--- EINDE LIJST ---")

if __name__ == "__main__":
    get_all_pages()
