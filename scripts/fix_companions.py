#!/usr/bin/env python3
"""Fix ALL Companion references without db. prefix."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

COMPANIONS = [
    'CustomersCompanion', 'ExpensesCompanion', 'ProductsCompanion',
    'OrdersCompanion', 'OrderItemsCompanion', 'InventoryMovementsCompanion',
    'StoresCompanion', 'BankAccountsCompanion', 'AppSettingsCompanion',
]

def fix_file(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    modified = False

    for comp in COMPANIONS:
        idx = 0
        while True:
            idx = content.find(comp, idx)
            if idx < 0:
                break
            # Check if already has db. or _db. prefix
            if idx > 2 and content[idx-3:idx] in ('db.', '_db'):
                idx += len(comp)
                continue
            if idx > 0 and content[idx-1] == '.':
                idx += len(comp)
                continue
            # Add db. prefix
            content = content[:idx] + 'db.' + content[idx:]
            modified = True
            idx += len(comp) + 3  # skip past added 'db.'

    if modified:
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    count = 0
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            if fix_file(fp):
                print(f'Fixed: {os.path.relpath(fp, ROOT)}')
                count += 1
    print(f'\nFixed {count} files.')
