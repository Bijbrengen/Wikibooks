import os
import re
import json

# --- CONFIGURATIE ---
SEARCH_DIRS = ["books", "collections/leerpret-bronnen"]
ROOT_DIR = "d:/repos/Leerpret/wikibooks"
LOG_FILE = "transformed_pages.json"

def get_balanced_parameter(text, start_pos):
    """Extraheert een parameterwaarde rekening houdend met geneste accolades."""
    braces = 0
    pos = start_pos
    while pos < len(text):
        char = text[pos]
        if char == '{':
            braces += 1
        elif char == '}':
            if braces == 0:
                return text[start_pos:pos].strip(), pos
            braces -= 1
        elif char == '|' and braces == 0:
            return text[start_pos:pos].strip(), pos
        pos += 1
    return text[start_pos:].strip(), pos

def parse_template(text):
    """Parses a template call and returns its name and a dictionary of named parameters."""
    # Remove outer {{ and }}
    if text.startswith('{{'): text = text[2:]
    if text.endswith('}}'): text = text[:-2]
    
    parts = []
    current = ""
    depth = 0
    for char in text:
        if char == '{': depth += 1
        elif char == '}': depth -= 1
        
        if char == '|' and depth == 0:
            parts.append(current.strip())
            current = ""
        else:
            current += char
    parts.append(current.strip())
    
    name = parts[0].strip()
    params = {}
    for p in parts[1:]:
        if '=' in p:
            k, v = p.split('=', 1)
            params[k.strip().lower()] = v.strip()
        else:
            # Handle unnamed params if needed, but for Sub/Bronnen we care about named ones
            pass
    return name, params

def parse_verdieping_bron(text):
    """Extraheert velden uit {{Verdieping/Bron ... }}."""
    _, params = parse_template(text)
    # Volgorde: soort ; titel ; url ; bron ; beschrijving
    def clean(s):
        # Strip comments and trim
        s = re.sub(r'<!--.*?-->', '', s, flags=re.DOTALL)
        return s.strip()
        
    soort = clean(params.get("soort", ""))
    titel = clean(params.get("titel", ""))
    url = clean(params.get("url", ""))
    bron = clean(params.get("bron", ""))
    beschrijving = clean(params.get("beschrijving", ""))
    
    return f"{soort} ; {titel} ; {url} ; {bron} ; {beschrijving}"

def find_templates(text):
    results = []
    pos = 0
    while True:
        # Zoek start van een sjabloon
        match = re.search(r'\{\{\s*(Sub/Bronnen|Voettekst)', text[pos:], re.IGNORECASE)
        if not match: break
        
        start = pos + match.start()
        # Vind het einde van dit specifieke sjabloon (gebalanceerd)
        depth = 0
        end = -1
        for i in range(start, len(text)):
            if text[i:i+2] == '{{':
                depth += 1
            elif text[i:i+2] == '}}':
                depth -= 1
                if depth == 0:
                    end = i + 2
                    break
        
        if end != -1:
            results.append((start, end, text[start:end]))
            pos = end
        else:
            pos = start + 2
    return results

def transform_content(content):
    changed = False
    
    # 1. Voeg {{Opmaak}} toe bovenaan als het er nog niet staat
    if not re.search(r'^\s*\{\{\s*Opmaak\s*\}\}', content, re.IGNORECASE | re.MULTILINE):
        content = "{{Opmaak}}\n" + content
        changed = True

    # 2. Verwijder {{Sub}} en {{Links}}
    new_content = re.sub(r'\n?\s*\{\{\s*(Sub|Links)\s*\}\}\s*\n?', '\n', content, flags=re.IGNORECASE)
    if new_content != content:
        content = new_content
        changed = True

    # 3. Transformeer Voettekst / Sub/Bronnen
    templates = find_templates(content)
    for start, end, full_text in reversed(templates):
        name, params = parse_template(full_text)
        
        ook = params.get("ook", "")
        inhoud = params.get("inhoud", params.get("verdieping", ""))
        
        # Parse alle Verdieping/Bron aanroepen in de inhoud
        sources = []
        if inhoud:
            # Vind alle {{Verdieping/Bron ... }}
            bron_matches = re.findall(r'\{\{\s*Verdieping/Bron.*?(?:\}\})', inhoud, re.DOTALL | re.IGNORECASE)
            for b in bron_matches:
                # We moeten oppassen met geneste braces, maar Verdieping/Bron is meestal simpel
                # Voor de zekerheid vinden we het echte einde
                real_end = -1
                depth = 0
                match_start = inhoud.find(b)
                for i in range(match_start, len(inhoud)):
                    if inhoud[i:i+2] == '{{': depth += 1
                    elif inhoud[i:i+2] == '}}':
                        depth -= 1
                        if depth == 0:
                            real_end = i + 2
                            break
                if real_end != -1:
                    sources.append(parse_verdieping_bron(inhoud[match_start:real_end]))

        # Bouw de nieuwe Opmaak | Voettekst aanroep
        if len(sources) > 0 or ook:
            new_call = "{{Opmaak\n | Voettekst"
            if ook:
                new_call += f"\n | Referentie = {ook}"
            for s in sources:
                new_call += f"\n | {s}"
            new_call += "\n}}"
        else:
            new_call = "{{Opmaak | Voettekst}}"
            
        content = content[:start] + new_call + content[end:]
        changed = True
        
    # 4. Zorg dat er altijd een Voettekst onderaan staat
    if not re.search(r'\{\{\s*Opmaak\s*\|\s*Voettekst', content, re.IGNORECASE):
        content = content.rstrip() + "\n\n{{Opmaak | Voettekst}}\n"
        changed = True
        
    return content, changed

def strip_verdieping_wrapper(text):
    """Verwijdert {{Verdieping | ... }} en geeft alleen de inhoud terug."""
    text = text.strip()
    if re.match(r'^\{\{\s*Verdieping\s*\|', text, re.IGNORECASE | re.DOTALL):
        # Zoek de eerste pipe
        pos = text.find('|')
        # Verwijder de laatste }}
        content = text[pos+1:].strip()
        if content.endswith('}}'):
            content = content[:-2].strip()
        return content
    return text

def bron_content_for_page(inhoud):
    """Bepaalt of we Bron moeten vullen. Als inhoud leeg is of {{Verdieping}}, dan is het default."""
    if not inhoud: return False
    # Als het alleen {{Verdieping}} is (zonder parameters), laten we het aan de module over
    if inhoud.strip() == "{{Verdieping}}": return False
    return True

def main():
    transformed = []
    
    # Target alleen de leerpret-bronnen collectie
    base_path = "collections/leerpret-bronnen"
    
    for root, dirs, files in os.walk(base_path):
        for file in files:
            # Sla _index.wiki en andere niet-content bestanden over
            if file.endswith(".wiki") and not file.startswith("_"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                new_content, changed = transform_content(content)
                if changed:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    transformed.append(path)
                    print(f"Transforming: {path}")
    
    with open("transformed_pages.json", "w") as f:
        json.dump(transformed, f, indent=2)
    
    print(f"Klaar! {len(transformed)} bestanden aangepast. Zie {LOG_FILE}.")

if __name__ == "__main__":
    main()
