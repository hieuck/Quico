#!/usr/bin/env python3
"""Extract hardcoded UI strings from Dart files for i18n."""
import re, os, sys, json

def extract_strings(filepath):
    with open(filepath, encoding='utf-8', errors='replace') as f:
        content = f.read()
    strings = set()
    for m in re.finditer(r"'([^']{2,})'", content):
        s = m.group(1)
        if s and len(s) > 1 and not s.startswith('http') and not s.startswith('packages/'):
            strings.add(s)
    return strings

all_strings = set()
for root, dirs, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'): continue
        all_strings.update(extract_strings(os.path.join(root, f)))

for s in sorted(all_strings):
    print(s)
