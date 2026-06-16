#!/usr/bin/env python3
"""TDD audit: verify structure, find remaining issues."""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ERRORS, WARN = [], []

def e(msg): ERRORS.append(msg)
def w(msg): WARN.append(msg)

def audit():
    comps = ['CustomersCompanion','ExpensesCompanion','ProductsCompanion','OrdersCompanion',
             'OrderItemsCompanion','InventoryMovementsCompanion','StoresCompanion',
             'BankAccountsCompanion','AppSettingsCompanion']

    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            name = os.path.relpath(fp, ROOT)
            has_db_import = 'as db' in content

            if 'StateProvider<' in content and 'flutter_riverpod' not in content:
                e(f'{name}: StateProvider no flutter_riverpod import')

            if has_db_import:
                for c in comps:
                    idx = 0
                    while True:
                        idx = content.find(c, idx)
                        if idx < 0: break
                        if idx > 0 and content[idx-1] != '.':
                            prev = content[max(0,idx-10):idx]
                            if 'db.' not in prev:
                                e(f'{name}:{content[:idx].count(chr(10))+1}: {c} without db.')
                        idx += 1

                for m in re.finditer(r'\bValue\(', content):
                    start = max(0, m.start()-10)
                    if 'db.' not in content[start:m.start()]:
                        e(f'{name}:{content[:m.start()].count(chr(10))+1}: Value() without db.')

            if 'ExpenseRow' in content:
                e(f'{name}: ExpenseRow should be dynamic')

            if 'InventoryMovementRow' in content:
                e(f'{name}: InventoryMovementRow should be dynamic')

    # Check required files
    required = ['lib/main.dart','lib/app/router.dart','lib/app/theme.dart',
                'lib/core/database/app_database.dart','lib/core/ai/parser/rule_based_order_text_parser.dart',
                'lib/l10n/app_en.arb','lib/l10n/app_vi.arb',
                '.github/workflows/flutter-ci.yml','.github/workflows/ios-release.yml','pubspec.yaml']
    for r in required:
        if not os.path.exists(os.path.join(ROOT, r)):
            e(f'MISSING: {r}')

    # Check _database -> _db regression
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            # _database should NOT appear (reverted to _db)
            if '_database' in content and 'app_database' not in fp:
                name = os.path.relpath(fp, ROOT)
                w(f'{name}: has _database (maybe should be _db)')

    print(f'=== Audit Results: {len(ERRORS)} errors, {len(WARN)} warnings ===')
    for x in ERRORS: print(f'  ERROR: {x}')
    for x in WARN: print(f'  WARN: {x}')
    return len(ERRORS)

if __name__ == '__main__':
    sys.exit(audit())
