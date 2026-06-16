#!/usr/bin/env python3
"""Add l10n_extension import to files using context.l10n."""
import os

def add_import(filepath):
    with open(filepath, encoding='utf-8') as f:
        lines = f.readlines()

    rel_path = os.path.relpath('lib/l10n/l10n_extension.dart', os.path.dirname(filepath)).replace('\\', '/')
    import_line = f"import '{rel_path}';\n"

    if any(import_line.strip() in l for l in lines):
        return False

    last_import = -1
    for i, line in enumerate(lines):
        if line.startswith('import ') or line.startswith('export '):
            last_import = i

    if last_import >= 0:
        lines.insert(last_import + 1, import_line)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        return True
    return False

for root, dirs, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            c = fh.read()
        if 'context.l10n' in c and 'l10n_extension.dart' not in c:
            if add_import(fp):
                print(f'Added import: {fp}')
