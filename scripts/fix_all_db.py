#!/usr/bin/env python3
"""Comprehensive fix: replace ALL db.select -> database.select and similar."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

WRONG_PATTERNS = [
    ('db.select(', 'database.select('),
    ('db.update(', 'database.update('),
    ('db.into(', 'database.into('),
    ('db.stores', 'database.stores'),
    ('db.appSettings', 'database.appSettings'),
    ('db.expenses', 'database.expenses'),
    ('db.bankAccounts', 'database.bankAccounts'),
    ('db.products', 'database.products'),
    ('db.customers', 'database.customers'),
    ('db.orders', 'database.orders'),
    ('db.orderItems', 'database.orderItems'),
    ('db.inventoryMovements', 'database.inventoryMovements'),
]

def fix_all():
    count = 0
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            original = content
            for old, new in WRONG_PATTERNS:
                content = content.replace(old, new)

            if content != original:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                print(f'Fixed: {os.path.relpath(fp, ROOT)}')
                count += 1
    return count

if __name__ == '__main__':
    c = fix_all()
    print(f'\nFixed {c} files.')
