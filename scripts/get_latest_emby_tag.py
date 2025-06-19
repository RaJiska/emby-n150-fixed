#!/usr/bin/env python3
import requests

def get_latest_tag():
    url = 'https://hub.docker.com/v2/repositories/emby/embyserver/tags?page_size=10'
    r = requests.get(url)
    r.raise_for_status()
    tags = r.json()['results']
    # Filter out non-standard tags (e.g., 'beta', 'dev')
    stable_tags = [t['name'] for t in tags if t['name'][0].isdigit()]
    # Sort tags by version (descending)
    from packaging.version import parse as vparse
    stable_tags.sort(key=vparse, reverse=True)
    print(stable_tags[0])

if __name__ == '__main__':
    get_latest_tag() 