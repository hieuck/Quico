#!/usr/bin/env python3
"""Fix screen files to use sqflite raw SQL instead of Drift ORM."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Known table -> column mappings for the ORM-style queries
TABLE_COLUMNS = {
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

def fix_screen_file(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    original = content

    # 1. Replace `await (database.select(database.tableName)..where((t) => t.col.equals(val))).getSingleOrNull()`
    # with: `await (await database.database).query('table_name', where: 'col = ?', whereArgs: [val])`
    
    # Pattern: database.select(database.xxx) -> (await database.database).query('xxx_table')
    for dartName, sqlName in TABLE_COLUMNS.items():
        # Simple select
        content = re.sub(
            r'database\.select\(database\.' + dartName + r'\)',
            f'(await database.database).query(\'{sqlName}\')',
            content
        )
        # where((t) => t.col.equals(val))
        content = re.sub(
            r'\.\.where\(\(t\) => t\.(\w+)\.equals\((\w+)\)\)',
            r", where: '\1 = ?', whereArgs: [\2]",
            content
        )
        # where((t) => t.col.isNull())
        content = re.sub(
            r'\.\.where\(\(t\) => t\.(\w+)\.isNull\(\)\)',
            r", where: '\1 IS NULL'",
            content
        )
        # orderBy
        content = re.sub(
            r'\.\.orderBy\(\[\(t\) => OrderingTerm\(expression: t\.(\w+), mode: OrderingMode\.(\w+)\)\]\)',
            r", orderBy: '\1 \2'",
            content
        )
        content = re.sub(
            r'\.orderBy\(\[\(t\) => OrderingTerm\(expression: t\.(\w+), mode: OrderingMode\.(\w+)\)\]\)',
            r" ORDER BY \1 \2",
            content
        )
        # .get() -> no op for query
        content = re.sub(r'\.get\(\)', '', content)
        # .getSingleOrNull() -> keep as is for now
        content = re.sub(r'\.getSingleOrNull\(\)', '.getSingleOrNull()', content)

    # 2. Replace `database.into(database.xxx).insert(...)` with db insert
    for dartName, sqlName in TABLE_COLUMNS.items():
        content = re.sub(
            r'database\.into\(database\.' + dartName + r'\)\.insert\(',
            f'_insert(\'{sqlName}\', ',
            content
        )

    # 3. Replace `database.update(database.xxx)..where(...).write(...)`
    for dartName, sqlName in TABLE_COLUMNS.items():
        content = re.sub(
            r'database\.update\(database\.' + dartName + r'\)',
            f'_update(\'{sqlName}\'',
            content
        )
    content = re.sub(r'\.\.where\(\(t\) => t\.(\w+)\.equals\((\w+)\)\)\.write\(', r', \1: \2', content)

    if content != original:
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

if __name__ == '__main__':
    count = 0
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib', 'features')):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            if fix_screen_file(fp):
                print(f'Fixed: {os.path.relpath(fp, ROOT)}')
                count += 1
    print(f'\nFixed {count} screen files.')
