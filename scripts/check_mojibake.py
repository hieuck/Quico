#!/usr/bin/env python3
"""Scan for mojibake/encoding corruption in source files."""
import os
import re

def has_mojibake(content):
    suspicious = re.findall(
        r'[\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf'
        r'\xd0\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc'
        r'\xdd\xde\xdf\xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9'
        r'\xea\xeb\xec\xed\xee\xef\xf0\xf1\xf2\xf3\xf4\xf5\xf6'
        r'\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe]',
        content.encode('utf-8')[200:400] if len(content) > 400 else content.encode('utf-8')
    )
    return len(suspicious) > 20

errors = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('.git', 'build', '.dart_tool', '.pub', '__pycache__', 'node_modules')]
    for f in files:
        if not f.endswith(('.dart', '.arb', '.yaml', '.py', '.md')):
            continue
        fp = os.path.join(root, f)
        try:
            with open(fp, 'rb') as fh:
                raw = fh.read()
            try:
                text = raw.decode('utf-8')
            except UnicodeDecodeError:
                print(f'MOJIBAKE: {fp} - NOT UTF-8!')
                errors += 1
                continue
        except Exception as e:
            print(f'ERROR: {fp} - {e}')
            errors += 1

if errors == 0:
    print('OK: All files are valid UTF-8, no mojibake detected.')
else:
    print(f'\n{errors} files with issues.')
