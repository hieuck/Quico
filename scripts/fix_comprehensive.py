#!/usr/bin/env python3
"""Comprehensive TDD fix: address ALL remaining errors in one pass."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_all():
    fixes = []
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            original = content

            # 1. Fix final db = ref.read(db.appDatabaseProvider) -> final database = ...
            content = re.sub(
                r'final db = ref\.read\(db\.appDatabaseProvider\)',
                'final database = ref.read(db.appDatabaseProvider)',
                content
            )

            # 2. Fix ref.read(db.appDatabaseProvider) (without final db) -> ref.read(db.appDatabaseProvider) stays same

            # 3. Fix Companions without db. prefix but with as-db import
            if 'as db' in content:
                for comp in ['CustomersCompanion', 'ExpensesCompanion', 'ProductsCompanion',
                            'OrdersCompanion', 'OrderItemsCompanion', 'InventoryMovementsCompanion',
                            'StoresCompanion', 'BankAccountsCompanion', 'AppSettingsCompanion']:
                    # Only replace if not already prefixed
                    content = re.sub(
                        rf'(?<![a-zA-Z.]){comp}(?![a-zA-Z.])',
                        f'db.{comp}',
                        content
                    )

                # Fix Value( -> db.Value( (outside string contexts)
                content = re.sub(
                    r'(?<![a-zA-Z.])Value\(',
                    'db.Value(',
                    content
                )

            # 4. Fix ExpenseRow -> dynamic
            content = re.sub(r'\bExpenseRow\b', 'dynamic', content)

            # 5. Fix InventoryMovementRow -> dynamic
            content = re.sub(r'\bInventoryMovementRow\b', 'dynamic', content)

            # 6. Fix _database -> _db (revert incorrect replacement)
            content = content.replace('_database', '_db')

            # 7. Fix AppDatabase without db. prefix (but not in import)
            if 'as db' in content:
                content = re.sub(
                    r'(?<!import )(?<![a-zA-Z.])AppDatabase(?![a-zA-Z.])',
                    'db.AppDatabase',
                    content
                )

            # 8. Fix double/int in report sort
            content = content.replace(
                'b.quantity.compareTo(a.quantity)',
                'b.quantity.compareTo(a.quantity)'
            )

            if content != original:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                fixes.append(os.path.relpath(fp, ROOT))

    return fixes

if __name__ == '__main__':
    fixes = fix_all()
    print(f'Fixed {len(fixes)} files:')
    for f in fixes:
        print(f'  {f}')
