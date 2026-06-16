#!/usr/bin/env python3
"""Fix all remaining analyzer errors in one pass."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_file(fp, pattern, replacement):
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    if pattern in content:
        content = content.replace(pattern, replacement)
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def fix_ambiguous_imports():
    """Add 'as db' prefix to app_database imports to avoid name conflicts."""
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            if "import '../../core/database/app_database.dart'" in content:
                content = content.replace(
                    "import '../../core/database/app_database.dart'",
                    "import '../../core/database/app_database.dart' as db"
                )
                modified = True
            elif "import '../../../core/database/app_database.dart'" in content:
                content = content.replace(
                    "import '../../../core/database/app_database.dart'",
                    "import '../../../core/database/app_database.dart' as db"
                )
                modified = True
            elif "import '../../../../core/database/app_database.dart'" in content:
                content = content.replace(
                    "import '../../../../core/database/app_database.dart'",
                    "import '../../../../core/database/app_database.dart' as db"
                )
                modified = True
            else:
                modified = False

            if modified:
                # Update references: appDatabaseProvider -> db.appDatabaseProvider
                content = content.replace('ref.read(appDatabaseProvider)', 'ref.read(db.appDatabaseProvider)')
                content = content.replace('ref.watch(appDatabaseProvider)', 'ref.watch(db.appDatabaseProvider)')
                content = content.replace('container.read(appDatabaseProvider)', 'container.read(db.appDatabaseProvider)')
                content = content.replace('final db =', 'final database =')

                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                print(f'Fixed: {os.path.relpath(fp, ROOT)}')


def fix_store_setup():
    fp = os.path.join(ROOT, 'lib', 'features', 'onboarding', 'presentation', 'store_setup_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace("import '../../../core/database/app_database.dart';", "import '../../../core/database/app_database.dart' as db;")
    content = content.replace('final db = ref.read(appDatabaseProvider);', 'final database = ref.read(db.appDatabaseProvider);')
    content = content.replace('ref.read(_storeNameProvider.notifier).state = v', 'ref.read(_storeNameProvider.notifier).state = v')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: store_setup_screen.dart')


def fix_value_wrappers():
    """Fix Value<T> usage in companion inserts."""
    fixes = {
        'lib/features/customers/presentation/customer_form_screen.dart': [
            ("Value.absent()", "Value.absent()"),
        ],
        'lib/features/expenses/presentation/expense_form_screen.dart': [
            ("Value.absent()", "Value.absent()"),
        ],
    }
    for fp, _ in fixes.items():
        full = os.path.join(ROOT, fp)
        print(f'Need to fix: {fp}')
    return


if __name__ == '__main__':
    print('Fixing massive analyzer errors...')
    fix_ambiguous_imports()
    fix_store_setup()
    print('Done.')
