#!/usr/bin/env python3
"""Fix db.select -> database.select and similar Drift API issues."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FILES_TO_FIX = [
    'lib/features/settings/presentation/backup_screen.dart',
    'lib/features/settings/presentation/bank_accounts_screen.dart',
    'lib/features/settings/presentation/store_settings_screen.dart',
    'lib/features/onboarding/presentation/store_setup_screen.dart',
]

# Map: db.tableName -> database.tableName
TABLE_PREFIX = {
    'db.stores': 'database.stores',
    'db.appSettings': 'database.appSettings',
    'db.expenses': 'database.expenses',
    'db.bankAccounts': 'database.bankAccounts',
    'db.products': 'database.products',
    'db.customers': 'database.customers',
    'db.orders': 'database.orders',
    'db.orderItems': 'database.orderItems',
    'db.inventoryMovements': 'database.inventoryMovements',
}

def fix_file(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    original = content

    # Fix: db.select( -> database.select(
    content = re.sub(r'db\.select\(', 'database.select(', content)

    # Fix: db.update( -> database.update(
    content = re.sub(r'db\.update\(', 'database.update(', content)

    # Fix: db.into( -> database.into(
    content = re.sub(r'db\.into\(', 'database.into(', content)

    # Fix: db.tableName -> database.tableName
    for old, new in TABLE_PREFIX.items():
        content = content.replace(old, new)

    if content != original:
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Fixed: {os.path.relpath(fp, ROOT)}')
        return True
    return False

if __name__ == '__main__':
    count = 0
    for fp in FILES_TO_FIX:
        full = os.path.join(ROOT, fp)
        if os.path.exists(full):
            if fix_file(full):
                count += 1
    # Also scan for any other files with the same pattern
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            if fp in [os.path.join(ROOT, x) for x in FILES_TO_FIX]:
                continue
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            if 'db.select(' in content:
                print(f'ALSO NEEDS FIX: {os.path.relpath(fp, ROOT)}')
    print(f'Fixed {count} files.')
