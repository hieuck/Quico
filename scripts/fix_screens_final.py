#!/usr/bin/env python3
"""Convert screen files from Drift ORM to sqflite - precise pattern matching."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TABLE_NAMES = {
    'appSettings': 'app_settings', 'stores': 'stores', 'products': 'products',
    'customers': 'customers', 'orders': 'orders', 'orderItems': 'order_items',
    'inventoryMovements': 'inventory_movements', 'expenses': 'expenses',
    'bankAccounts': 'bank_accounts',
}

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        original = content

        # ==========================================
        # PATTERN 1: database.select(database.XXX) followed by .where chains and .get/.getSingleOrNull()
        # ==========================================
        for dart_name, sql_name in TABLE_NAMES.items():
            # Full pattern: (database.select(database.XXX)..where((t)=>t.Y.equals(Z))..where(...)).getSingleOrNull()
            pattern = (
                r'\(database\.select\(database\.' + dart_name + r'\)'
                r'(?:\s*\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.equals\((\w+)\)\))*'
                r'\s*\)\.getSingleOrNull\(\)'
            )

            def replacement(m):
                # Extract WHERE conditions
                matches = re.findall(r't\.(\w+)\.equals\((\w+)\)', m.group())
                if matches:
                    conds = ' AND '.join(f"{col} = ?" for col, _ in matches)
                    args = ', '.join(val for _, val in matches)
                    return f'(await database.database).query(\'{sql_name}\', where: \'{conds}\', whereArgs: [{args}])'
                return f'(await database.database).query(\'{sql_name}\')'

            content = re.sub(pattern, replacement, content)

        # ==========================================
        # PATTERN 2: database.into(database.XXX).insert(Companion.insert(...))
        # ==========================================
        for dart_name, sql_name in TABLE_NAMES.items():
            pattern = r'database\.into\(database\.' + dart_name + r'\)\.insert\((\w+)Companion\.insert\('
            content = re.sub(pattern, f'(await database.database).insert(\'{sql_name}\', {{', content)

            # Insert close parens
            content = re.sub(r'\)\)\s*\)\s*;', '});', content)
            content = re.sub(r'\)\)\s*;\s*$', '});', content)

        # ==========================================
        # PATTERN 3: database.select(database.XXX) without .where (simple get query)
        # ==========================================
        for dart_name, sql_name in TABLE_NAMES.items():
            content = re.sub(
                r'database\.select\(database\.' + dart_name + r'\)',
                f'(await database.database).query(\'{sql_name}\')',
                content
            )

        # ==========================================
        # PATTERN 4: database.into(database.XXX) without Companion
        # ==========================================
        for dart_name, sql_name in TABLE_NAMES.items():
            content = re.sub(
                r'database\.into\(database\.' + dart_name + r'\)',
                f'(await database.database).insert(\'{sql_name}\'',
                content
            )

        # ==========================================
        # PATTERN 5: database.update(database.XXX)..where((t)=>...).write(StoresCompanion.custom({...}))
        # ==========================================
        for dart_name, sql_name in TABLE_NAMES.items():
            # Complex but common pattern
            pattern = r'database\.update\(database\.' + dart_name + r'\)\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.equals\((\w+)\)\)\.write\('
            content = re.sub(
                pattern,
                f'(await database.database).update(\'{sql_name}\', {{',
                content
            )

        # ==========================================
        # CLEANUP: remove leftover Drift-style patterns
        # ==========================================
        content = re.sub(r'\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.equals\((\w+)\)\)', '', content)
        content = re.sub(r'\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.isNull\(\)\)', '', content)
        content = re.sub(r'\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.isBetweenValues\((\w+),\s*(\w+)\)\)', '', content)
        content = re.sub(r'\.\.orderBy\(\[\(t\)\s*=>\s*OrderingTerm\(expression:\s*t\.(\w+),\s*mode:\s*OrderingMode\.(\w+)\)\]\)', '', content)
        content = re.sub(r'\.get\(\)', '', content)
        content = re.sub(r'\.getSingleOrNull\(\)', '', content)
        content = re.sub(r'\.isNotIn\(\[.*?\]\)', '', content)

        # Convert Companion.custom({...}) -> just {...}
        content = re.sub(r'(\w+)Companion\.custom\(\{', '{', content)
        content = re.sub(r'(\w+)Companion\.\w+\(', '{', content)

        # Fix Value() wrapper removal
        content = re.sub(r'Value\((\w+(?:\.\w+)*)\)', r'\1', content)
        content = re.sub(r'Value\.absent\(\)', 'null', content)

        # Remove 'as String' casts
        content = content.replace(' as String', '')
        content = content.replace(' as int', '')

        if content != original:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
