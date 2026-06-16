#!/usr/bin/env python3
"""Fix ALL screen files to use sqflite database methods."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TABLE_NAMES = {
    'appSettings': 'app_settings',
    'stores': 'stores',
    'products': 'products',
    'customers': 'customers',
    'orders': 'orders',
    'orderItems': 'order_items',
    'inventoryMovements': 'inventory_movements',
    'expenses': 'expenses',
    'bankAccounts': 'bank_accounts',
}

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib', 'features')):
    for f in files:
        if not f.endswith('.dart'): continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()

        if 'database.select(' not in content and 'database.into(' not in content and 'database.update(' not in content:
            continue

        original = content

        # Pattern 1: database.select(database.TableName)
        for dart_name in TABLE_NAMES:
            content = content.replace(
                f'database.select(database.{dart_name})',
                f'(await database.database).query(\'{TABLE_NAMES[dart_name]}\')'
            )

        # Pattern 2: database.into(database.TableName).insert(...)
        for dart_name in TABLE_NAMES:
            content = content.replace(
                f'database.into(database.{dart_name}).insert(',
                f'(await database.database).insert(\'{TABLE_NAMES[dart_name]}\', '
            )

        # Pattern 3: database.update(database.TableName)..where((t) => t.col.equals(val)).write(Companion)
        # This is complex, let's use a regex approach
        for dart_name, sql_name in TABLE_NAMES.items():
            content = content.replace(
                f'database.update(database.{dart_name})',
                f'(await database.database).update(\'{sql_name}\''
            )

        # Fix companions in insert calls: StoreCompanion.insert(...) -> raw map
        content = re.sub(r'(\w+)Companion\.insert\(', '{', content)

        # Fix closing parens: add }) at the end
        content = re.sub(r'\)\)\);\s*$', '});', content)

        # Simplify: remove .where().getSingleOrNull() chain
        content = re.sub(r'\.\.where\(.*?\)', '', content)
        content = re.sub(r'\.\.orderBy\(.*?\)', '', content)
        content = re.sub(r'\.get\(\)', '', content)
        content = re.sub(r'\.getSingleOrNull\(\)', '', content)

        if content != original:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
