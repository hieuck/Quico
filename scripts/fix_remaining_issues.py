#!/usr/bin/env python3
"""Fix remaining Drift 2.x reference issues."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Files that need drift/drift.dart import or db. prefix
FIXES = {
    'lib/features/inventory/domain/inventory_service.dart': [
        ("import '../../../core/database/app_database.dart' as db;", None),
        # Add drift import
        ("import 'package:drift/drift.dart';", "import 'package:drift/drift.dart';\nimport '../../../core/database/app_database.dart' as db;"),
    ],
}

def fix_file(fp, replacements):
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    for old, new in replacements:
        if new is None:
            continue
        if old != content and old in content:
            content = content.replace(old, new)
            print(f'  {os.path.relpath(fp, ROOT)}: replaced')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)

def add_drift_import(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    if 'import \'package:drift/drift.dart\'' in content:
        return
    # Add after the last import
    lines = content.split('\n')
    last_import = -1
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
    if last_import >= 0:
        lines.insert(last_import + 1, "import 'package:drift/drift.dart';")
        with open(fp, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))
        print(f'  Added drift import to {os.path.relpath(fp, ROOT)}')

def scan_and_fix():
    """Find files that use Drift types without proper imports."""
    drift_types = ['AppDatabase', 'Value(', 'Value.absent(', 'Companion',
                   'OrderingTerm', 'OrderingMode', 'ProductsCompanion',
                   'OrdersCompanion', 'CustomersCompanion', 'ExpensesCompanion',
                   'StoresCompanion', 'BankAccountsCompanion',
                   'InventoryMovementsCompanion', 'OrderItemsCompanion',
                   'AiParseLogsCompanion', 'AppSettingsCompanion']

    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            # Check if file uses Drift types but doesn't import drift
            uses_drift = any(t in content for t in drift_types)
            has_drift_import = "import 'package:drift/drift.dart'" in content
            has_db_import = "import '" in content and "app_database.dart'" in content

            if uses_drift and not has_drift_import and not has_db_import:
                add_drift_import(fp)

if __name__ == '__main__':
    print('Scanning for missing Drift imports...')
    scan_and_fix()
    print('Done.')
