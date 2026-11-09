#!/usr/bin/env python3
"""Publiceer een expliciet wijzigingsplan met revisiecontrole en verifieer de inhoud.

Een plan bevat uitsluitend titel, pad, bewerkingssamenvatting en basisrevisie.
Zonder --apply is dit een lokale controle. Login via omgevingsvariabelen of de
bestaande lokale BeeBot-configuratie; wachtwoorden worden nooit gelogd.
"""
import argparse
import ast
import hashlib
import http.cookiejar
import json
import os
from pathlib import Path
import time
import urllib.parse
import urllib.request

ROOT=Path(__file__).resolve().parents[1]
API='https://nl.wikibooks.org/w/api.php'

def credentials():
    name=os.environ.get('WIKIBOOKS_BOT_USERNAME');password=os.environ.get('WIKIBOOKS_BOT_PASSWORD')
    if name and password:
        return name,password
    values={}
    for node in ast.parse((ROOT/'beebot.py').read_text()).body:
        if isinstance(node,ast.Assign) and isinstance(node.value,ast.Constant):
            for target in node.targets:
                if isinstance(target,ast.Name) and target.id in ['USERNAME','BOT_NAME','BOT_PASSWORD']:
                    values[target.id]=node.value.value
    return values['USERNAME']+'@'+values['BOT_NAME'],values['BOT_PASSWORD']

class Client:
    def __init__(self):
        self.opener=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    def call(self,params,post=False):
        params=dict(params,format='json',formatversion=2)
        raw=urllib.parse.urlencode(params).encode()
        request=urllib.request.Request(API if post else API+'?'+raw.decode(),data=raw if post else None,headers={'User-Agent':'BeeBot library maintenance/1.0 (Gebruiker:BeeBringer)'})
        with self.opener.open(request,timeout=60) as response:
            result=json.load(response)
        if 'error' in result:
            raise RuntimeError(result['error']['code']+': '+result['error'].get('info',''))
        return result
    def login(self):
        token=self.call(dict(action='query',meta='tokens',type='login'))['query']['tokens']['logintoken']
        name,password=credentials()
        response=self.call(dict(action='login',lgname=name,lgpassword=password,lgtoken=token),True)
        if response.get('login',{}).get('result')!='Success':
            raise RuntimeError('Botlogin niet geslaagd: '+response.get('login',{}).get('result','onbekend'))
        return self.call(dict(action='query',meta='tokens'))['query']['tokens']['csrftoken']
    def page(self,title):
        data=self.call(dict(action='query',prop='revisions',titles=title,rvprop='ids|timestamp|content',rvslots='main',curtimestamp=1))
        return data['query']['pages'][0],data['curtimestamp']

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--plan',type=Path,required=True)
    parser.add_argument('--receipt',type=Path,required=True)
    parser.add_argument('--apply',action='store_true')
    args=parser.parse_args();plan=json.loads(args.plan.read_text());client=Client();receipts=[]
    for edit in plan:
        path=(ROOT/edit['file']).resolve()
        if ROOT not in path.parents or path.suffix!='.wiki':
            raise RuntimeError('Ongeldig bronpad')
        content=path.read_text()
        if hashlib.sha256(content.encode()).hexdigest()!=edit['sha256']:
            raise RuntimeError('Bestand gewijzigd na controle: '+edit['title'])
    if not args.apply:
        print('Plan gecontroleerd:',len(plan),'pagina’s. Geen publicatie uitgevoerd.')
        return
    token=client.login()
    for edit in plan:
        title=edit['title'];content=(ROOT/edit['file']).read_text()
        try:
            page,start=client.page(title)
            current=page.get('revisions',[{}])[0]
            if current.get('slots',{}).get('main',{}).get('content','').rstrip('\n')==content.rstrip('\n'):
                receipts.append(dict(title=title,status='reeds gelijk',revid=current['revid']))
                continue
            if current.get('revid',0)!=edit['baserevid']:
                raise RuntimeError('Revisieconflict: online inhoud is tussentijds gewijzigd')
            params=dict(action='edit',title=title,text=content,summary=edit['summary'],token=token,assertuser='BeeBringer',starttimestamp=start,maxlag=5)
            if edit['baserevid']:
                params.update(baserevid=edit['baserevid'],basetimestamp=current['timestamp'],nocreate=1)
            else:
                params['createonly']=1
            response=client.call(params,True)
            if response.get('edit',{}).get('result')!='Success':
                raise RuntimeError('Bewerking niet bevestigd')
            page,_=client.page(title);revision=page['revisions'][0]
            if revision['slots']['main']['content'].rstrip('\n')!=content.rstrip('\n'):
                raise RuntimeError('Controle na upload wijkt af')
            receipts.append(dict(title=title,status='geverifieerd',revid=revision['revid']))
            print(title+': geverifieerd',flush=True)
        except Exception as exc:
            receipts.append(dict(title=title,status='fout',reason=str(exc)))
            args.receipt.write_text(json.dumps(receipts,ensure_ascii=False,indent=2)+'\n')
            raise
        args.receipt.write_text(json.dumps(receipts,ensure_ascii=False,indent=2)+'\n')
        time.sleep(1)
    args.receipt.write_text(json.dumps(receipts,ensure_ascii=False,indent=2)+'\n')
    print('Voltooid:',len(receipts),'pagina’s gecontroleerd.')

if __name__=='__main__':
    main()
