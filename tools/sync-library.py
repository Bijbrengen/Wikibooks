#!/usr/bin/env python3
"""Synchroniseer een exacte paginalijst en alle subpagina's van de opgegeven boeken.

Gebruikt dezelfde titel-naar-padindeling als sync_wikibooks.py. Redirects worden
als redirects bewaard; bronmetadata worden nooit als te publiceren tekst gebruikt.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import re
import sys
import time
import threading
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
API = 'https://nl.wikibooks.org/w/api.php'
UA = 'BeeBot/1.0 (Gebruiker:BeeBringer)'
RATE_LOCK = threading.Lock()
LAST_REQUEST = 0.0

def api(params):
    global LAST_REQUEST
    query = dict(params, format='json', formatversion=2)
    for attempt in range(7):
        try:
            with RATE_LOCK:
                time.sleep(max(0, 1.2-(time.monotonic()-LAST_REQUEST)))
                LAST_REQUEST = time.monotonic()
            req = urllib.request.Request(API+'?'+urllib.parse.urlencode(query), headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=60) as response:
                data = json.load(response)
            if 'error' in data:
                raise RuntimeError(data['error'].get('info', data['error']['code']))
            return data
        except Exception:
            if attempt == 6:
                raise
            time.sleep(min(30, 5*(attempt+1)))

def safe(title):
    return re.sub(r'[<>:"\\|?*]', '_', title).strip()

def collection_path(title):
    parts = title.split('/')
    parent = ROOT/'collections/leerpret-bronnen'/safe(parts[0])
    return parent/('_index.wiki' if len(parts)==1 else '/'.join(safe(x) for x in parts[1:])+'.wiki')

def discover(root):
    result = {root}
    more = {}
    while True:
        data = api(dict(action='query', list='allpages', apnamespace=0, apprefix=root+'/', aplimit='500', **more))
        result.update(x['title'] for x in data['query']['allpages'])
        more = data.get('continue', {})
        if not more:
            return result

def fetch(titles):
    return api(dict(action='query',prop='info|revisions',titles='|'.join(titles),rvprop='ids|timestamp|user|comment|content|sha1',rvslots='main',curtimestamp=1))

def metadata(page, relative):
    rev = page['revisions'][0]
    return dict(title=page['title'],file=str(relative),pageid=page['pageid'],contentmodel=page.get('contentmodel','wikitext'),**{x:rev.get(x) for x in ['revid','parentid','timestamp','user','comment','sha1']},bytes=len(rev['slots']['main']['content'].encode('utf-8')))

def save(pages, requested, destination=None):
    now = datetime.now(timezone.utc).isoformat()
    manifest = dict(source='https://nl.wikibooks.org/wiki/',api=API,fetched_at_utc=now,requested_count=len(requested),pages=[],missing=[])
    for page in sorted(pages, key=lambda x:x['title']):
        title=page['title']; path=collection_path(title)
        if page.get('missing') or 'revisions' not in page:
            manifest['missing'].append(title)
            if path.exists():
                path.unlink()
            continue
        path.parent.mkdir(parents=True,exist_ok=True)
        text=page['revisions'][0]['slots']['main']['content']
        path.write_text(text,encoding='utf-8')
        manifest['pages'].append(metadata(page,path.relative_to(ROOT/'collections/leerpret-bronnen')))
    manifest['fetched_count']=len(manifest['pages']);manifest['missing_count']=len(manifest['missing'])
    collection=ROOT/'collections/leerpret-bronnen'
    (collection/'_manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
    (collection/'_index.md').write_text('# Lokale bibliotheek\n\nOpgehaald: '+now+'\n\n'+'\n'.join('- ['+p['title']+']('+urllib.parse.quote(p['file'])+')' for p in manifest['pages'])+'\n')
    byroot={}
    for p in manifest['pages']:
        byroot.setdefault(p['title'].split('/')[0],[]).append(p)
    for root, entries in byroot.items():
        cr=collection/safe(root)
        cr.mkdir(parents=True,exist_ok=True)
        (cr/'_index.md').write_text('# '+root+'\n\nOpgehaald: '+now+'\n\n'+'\n'.join('- ['+p['title']+']('+urllib.parse.quote(str(Path(p['file']).relative_to(safe(root))))+')' for p in entries)+'\n')
        if ':' in root:
            continue
        book=ROOT/'books'/safe(root);book.mkdir(parents=True,exist_ok=True)
        records=[]; expected=set()
        for entry in entries:
            name='_module.wiki' if entry['title']==root else entry['title'][len(root)+1:]+'.wiki'
            target=book/name;expected.add(target)
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text((collection/entry['file']).read_text(),encoding='utf-8')
            records.append(dict(entry,file=name))
        # Remove obsolete active copies only; revision history stays in Git.
        for old in book.rglob('*.wiki'):
            if old not in expected:
                old.unlink()
        bm=dict(source='https://nl.wikibooks.org/wiki/'+urllib.parse.quote(root),api=API,title=root,fetched_at_utc=now,page_count=len(records),pages=records)
        (book/'_manifest.json').write_text(json.dumps(bm,ensure_ascii=False,indent=2)+'\n')
        (book/'_index.md').write_text('# '+root+'\n\nOpgehaald: '+now+'\n\n'+'\n'.join('- ['+p['title']+']('+urllib.parse.quote(p['file'])+')' for p in records)+'\n')
    return manifest

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--list',required=True,type=Path)
    parser.add_argument('--exact',action='store_true',help='Haal de volledige opgegeven lijst op zonder extra subpagina-inventarisatie.')
    parser.add_argument('--state',type=Path,required=True,help='Live bronmomentopname voor conflictveilige uploads; buiten de repository bewaren.')
    args=parser.parse_args()
    titles={line.strip() for line in args.list.read_text(encoding='utf-8-sig').splitlines() if line.strip() and not line.startswith('#')}
    roots={t.split('/')[0] for t in titles if ':' not in t}
    if not args.exact:
        with ThreadPoolExecutor(max_workers=4) as pool:
            for i,result in enumerate(pool.map(discover, sorted(roots)),1):
                titles.update(result)
                if i % 10 == 0:
                    print("Boeken geïnventariseerd:",i,"/",len(roots),flush=True)
    batches=[sorted(titles)[i:i+40] for i in range(0,len(titles),40)]
    pages=[]
    with ThreadPoolExecutor(max_workers=3) as pool:
        for i,data in enumerate(pool.map(fetch,batches),1):
            pages.extend(data['query']['pages'])
            print('Paginabatches opgehaald:',i,'/',len(batches),flush=True)
    state={p['title']:p for p in pages}
    args.state.write_text(json.dumps(state,ensure_ascii=False,indent=2)+'\n')
    manifest=save(pages,titles)
    print(json.dumps(dict(roots=len(roots),requested=len(titles),fetched=manifest['fetched_count'],missing=manifest['missing']),ensure_ascii=False),flush=True)

if __name__=='__main__':
    main()
