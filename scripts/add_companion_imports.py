#!/usr/bin/env python3
"""Add companions.dart import to files that need it."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

companions = ['CustomersCompanion','ExpensesCompanion','ProductsCompanion',
              'BankAccountsCompanion','StoresCompanion','AppSettingsCompanion',
              'InventoryMovementsCompanion','OrderItemsCompanion','OrdersCompanion']

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()

        needs_import = any(c in content for c in companions)
        needs_import = needs_import or 'Value(' in content or 'Value.absent()' in content
        if not needs_import:
            continue
        if 'companions.dart' in content:
            continue

        rel = os.path.relpath(
            os.path.join(ROOT, 'lib', 'core', 'database', 'companions.dart'),
            os.path.dirname(fp)
        ).replace('\\', '/')

        lines = content.split('\n')
        new_lines = []
        added = False
        for line in lines:
            new_lines.append(line)
            if 'app_database.dart' in line and not added:
                new_lines.append(f"import '{rel}';")
                added = True

        if added:
            with open(fp, 'w', encoding='utf-8') as fh:
                fh.write('\n'.join(new_lines))
            print(f'Added: {os.path.relpath(fp, ROOT)}')
