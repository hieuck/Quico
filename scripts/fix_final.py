#!/usr/bin/env python3
"""Final comprehensive fix for all remaining errors."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_references(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    if 'as db' not in content:
        return False

    original = content

    # Fix: final db = ref.read(appDatabaseProvider) -> final database = ref.read(db.appDatabaseProvider)
    content = re.sub(
        r'final db = ref\.read\(appDatabaseProvider\)',
        'final database = ref.read(db.appDatabaseProvider)',
        content
    )

    # Fix: ref.read(appDatabaseProvider) -> ref.read(db.appDatabaseProvider) (no 'final db =')
    content = re.sub(
        r'(?<!final db = )ref\.read\(appDatabaseProvider\)',
        'ref.read(db.appDatabaseProvider)',
        content
    )

    # Fix: ref.watch(appDatabaseProvider) -> ref.watch(db.appDatabaseProvider)
    content = re.sub(
        r'ref\.watch\(appDatabaseProvider\)',
        'ref.watch(db.appDatabaseProvider)',
        content
    )

    # Fix: CustomersCompanion -> db.CustomersCompanion (and similar)
    for companion in ['CustomersCompanion', 'ExpensesCompanion', 'ProductsCompanion',
                      'OrdersCompanion', 'OrderItemsCompanion', 'InventoryMovementsCompanion',
                      'StoresCompanion', 'BankAccountsCompanion', 'AppSettingsCompanion']:
        content = re.sub(
            rf'(?<![a-zA-Z.]){companion}(?![a-zA-Z.])',
            f'db.{companion}',
            content
        )

    # Fix: Value( used outside db. prefix
    content = re.sub(
        r'(?<![a-zA-Z.])Value\(',
        'db.Value(',
        content
    )

    # Fix: OrderingTerm
    content = re.sub(
        r'(?<![a-zA-Z.])OrderingTerm\(',
        'db.OrderingTerm(',
        content
    )

    # Fix: OrderingMode
    content = re.sub(
        r'(?<![a-zA-Z.])OrderingMode\.',
        'db.OrderingMode.',
        content
    )

    if content != original:
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
            if fix_references(fp):
                print(f'FIXED: {os.path.relpath(fp, ROOT)}')
                count += 1
    print(f'\nFixed {count} files.')
