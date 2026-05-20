import requests
import os
import json
import time
import re

# --- CONFIGURATION ---
API_URL = "https://nl.wikibooks.org/w/api.php"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
VOLGLIJST_PATH = os.path.join(BASE_DIR, "volglijst.txt")
COLLECTIONS_DIR = os.path.join(BASE_DIR, "collections")
MODULES_DIR = os.path.join(BASE_DIR, "modules")

def make_safe(s):
    return s.replace(":", "_").replace("*", "_").replace("?", "_").replace('"', "_").replace("<", "_").replace(">", "_").replace("|", "_")

def determine_path(title, contentmodel):
    # Mapping logic based on observed patterns
    
    # 1. Modules
    if title.startswith("Module:"):
        parts = title.split("/", 1)
        module_name = make_safe(parts[0].replace("Module:", "Module_"))
        if len(parts) == 1:
            return os.path.join(MODULES_DIR, module_name, "_module.lua" if contentmodel == "Scribunto" else "_module.wiki")
        else:
            subpath = "/".join([make_safe(p) for p in parts[1].split("/")])
            ext = ".lua" if contentmodel == "Scribunto" else ".wiki"
            return os.path.join(MODULES_DIR, module_name, subpath + ext)

    # 2. Templates
    if title.startswith("Sjabloon:"):
        parts = title.split("/", 1)
        template_name = make_safe(parts[0].replace("Sjabloon:", "Sjabloon_"))
        
        if template_name == "Sjabloon_Opmaak":
             if len(parts) == 1:
                 return os.path.join(COLLECTIONS_DIR, "Sjabloon_Opmaak", "_module.wiki")
             else:
                 subpath = "/".join([make_safe(p) for p in parts[1].split("/")])
                 return os.path.join(COLLECTIONS_DIR, "Sjabloon_Opmaak", subpath + ".wiki")
        
        if len(parts) == 1:
            return os.path.join(COLLECTIONS_DIR, "templates", template_name + ".wiki")
        else:
            subpath = "/".join([make_safe(p) for p in parts[1].split("/")])
            return os.path.join(COLLECTIONS_DIR, "templates", template_name, subpath + ".wiki")

    # 3. Everything else
    parts = title.split("/")
    safe_parts = [make_safe(p) for p in parts]
    
    if len(parts) == 1:
        return os.path.join(COLLECTIONS_DIR, "leerpret-bronnen", safe_parts[0], "_index.wiki")
    else:
        return os.path.join(COLLECTIONS_DIR, "leerpret-bronnen", "/".join(safe_parts[:-1]), safe_parts[-1] + ".wiki")

def get_pages_batch(session, titles):
    params = {
        "action": "query",
        "prop": "info|revisions",
        "titles": "|".join(titles),
        "rvprop": "content|timestamp|ids",
        "format": "json"
    }
    try:
        res = session.get(API_URL, params=params).json()
        pages = res.get("query", {}).get("pages", {})
        results = []
        for pid, pdata in pages.items():
            if pid == "-1":
                continue
            rev = pdata.get("revisions", [{}])[0]
            results.append({
                "title": pdata.get("title"),
                "content": rev.get("*"),
                "contentmodel": pdata.get("contentmodel")
            })
        return results
    except Exception as e:
        print(f"  [ERROR] Batch fetch failed: {e}")
        return []

def sync():
    if not os.path.exists(VOLGLIJST_PATH):
        print(f"File not found: {VOLGLIJST_PATH}")
        return

    with open(VOLGLIJST_PATH, "r", encoding="utf-8") as f:
        titles = [line.strip() for line in f if line.strip()]

    session = requests.Session()
    session.headers.update({'User-Agent': 'BeeBot/1.0 (Gebruiker:BeeBringer)'})

    batch_size = 50
    print(f"Starting batch sync of {len(titles)} pages (batch size {batch_size})...")

    for i in range(0, len(titles), batch_size):
        batch_titles = titles[i : i + batch_size]
        print(f"Syncing batch {i//batch_size + 1} ({len(batch_titles)} pages)...")
        
        pages_data = get_pages_batch(session, batch_titles)
        
        for data in pages_data:
            title = data["title"]
            path = determine_path(title, data["contentmodel"])
            os.makedirs(os.path.dirname(path), exist_ok=True)
            
            try:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(data["content"])
                
                if data["contentmodel"] == "Scribunto" and path.endswith(".lua"):
                    wiki_path = path.replace(".lua", ".wiki")
                    with open(wiki_path, "w", encoding="utf-8") as f:
                        f.write(data["content"])
                
                # print(f"  [OK] {title}")
            except Exception as e:
                print(f"  [ERROR] Could not save {title}: {e}")
        
        print(f"  Done batch {i//batch_size + 1}")
        time.sleep(1) # Be gentle

    print("Sync completed!")

if __name__ == "__main__":
    sync()
