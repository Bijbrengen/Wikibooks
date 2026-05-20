import requests
import re
import time
import sys
import json
import os

# Zorg dat de output in UTF-8 is
if sys.stdout.encoding != 'utf-8':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.detach())

# --- CONFIGURATIE ---
USERNAME = "BeeBringer"
BOT_NAME = "BeeBot"
BOT_PASSWORD = "9p0l7sm0n6644mhvlfs8lkfbuqqu3uu6"
API_URL = "https://nl.wikibooks.org/w/api.php"
PAGES_FILE = os.path.join(os.path.dirname(__file__), "pages.json")

def parse_params(template_text):
    ook = ""
    inhoud = ""
    ook_match = re.search(r'\|\s*[Oo]ok\s*=\s*(.*?)(?=\s*\||\s*\}\})', template_text, re.DOTALL)
    if ook_match: ook = ook_match.group(1).strip()
    inhoud_match = re.search(r'\|\s*(?:[Ii]nhoud|[Vv]erdieping)\s*=\s*(.*?)(?=\s*\||\s*\}\})', template_text, re.DOTALL)
    if inhoud_match: inhoud = inhoud_match.group(1).strip()
    return ook, inhoud

def run_bot():
    # Laad toegestane pagina's
    if not os.path.exists(PAGES_FILE):
        print(f"❌ Fout: {PAGES_FILE} niet gevonden.")
        return
    
    with open(PAGES_FILE, "r", encoding="utf-8") as f:
        allowed_titles = set(json.load(f))

    base_path = os.path.join(os.path.dirname(__file__), "collections", "leerpret-bronnen")
    if not os.path.exists(base_path):
        print(f"❌ Fout: {base_path} niet gevonden.")
        return

    print(f"BeeBot start de Moderniseringsronde voor de leerpret-bronnen collectie...")
    
    session = requests.Session()
    session.headers.update({'User-Agent': 'BeeBot/1.0 (Gebruiker:BeeBringer)'})

    try:
        # 1. Inloggen
        token_res = session.get(API_URL, params={"action": "query", "meta": "tokens", "type": "login", "format": "json"}).json()
        login_token = token_res["query"]["tokens"]["logintoken"]
        login_res = session.post(API_URL, data={
            "action": "login", "lgname": f"{USERNAME}@{BOT_NAME}", "lgpassword": BOT_PASSWORD, "lgtoken": login_token, "format": "json"
        }).json()

        if login_res["login"]["result"] != "Success":
            print(f"Inloggen mislukt.")
            return
        print("✅ Ingelogd!")

        # 2. Door lokale bestanden lopen
        edit_count = 0
        for root, _, files in os.walk(base_path):
            for file in files:
                if not file.endswith(".wiki") or file.startswith("_"):
                    continue
                
                local_path = os.path.join(root, file)
                
                # Bepaal de titel op basis van het pad
                rel_path = os.path.relpath(local_path, base_path)
                title = rel_path.replace("\\", "/").replace(".wiki", "")
                
                if title not in allowed_titles:
                    # Soms is de titel anders geformatteerd (spaties vs underscores)
                    # Maar in pages.json staan ze meestal netjes
                    pass
                
                if title in allowed_titles:
                    with open(local_path, "r", encoding="utf-8") as f:
                        new_text = f.read()
                    
                    # CSRF Token ophalen voor deze pagina
                    res = session.get(API_URL, params={
                        "action": "query", "meta": "tokens", "type": "csrf", "format": "json"
                    }).json()
                    csrf_token = res["query"]["tokens"]["csrftoken"]
                    
                    print(f"Updaten: {title}...")
                    save_res = session.post(API_URL, data={
                        "action": "edit", "title": title, "text": new_text,
                        "summary": "Bot: Modernisering van voettekst en opschoning (Opmaak | Voettekst)",
                        "token": csrf_token, "format": "json"
                    }).json()
                    
                    if "edit" in save_res and save_res["edit"]["result"] == "Success":
                        print(f"   [OK]")
                        edit_count += 1
                        time.sleep(5) # Iets sneller dan 10 sec als het kan
                    elif "edit" in save_res and save_res["edit"]["result"] == "Failure" and "ratelimit" in str(save_res):
                        print(f"   [PAUZE] Rate limit. We wachten 60 sec...")
                        time.sleep(60)
                    else:
                        print(f"   [FOUT] {save_res.get('error', {}).get('info', 'Onbekend')}")
            
        print(f"🏁 Klaar! Totaal {edit_count} pagina's bijgewerkt.")

    except Exception as e:
        print(f"Fout: {e}")

if __name__ == "__main__":
    run_bot()
