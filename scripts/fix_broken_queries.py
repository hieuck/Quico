#!/usr/bin/env python3
"""Fix broken Drift-to-sqflite query conversions."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        original = content

        # Fix: (await database.database).query('table')..where((t)=>t.col.equals(val))
        # -> (await database.database).query('table', where: 'col = ?', whereArgs: [val])
        content = re.sub(
            r"\(await database\.database\)\.query\('(\w+)'\)\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.equals\((\w+)\)\)",
            r"(await database.database).query('\1', where: '\2 = ?', whereArgs: [\3])",
            content
        )

        # Fix: ((await database.database).query('table')..where(...where...))
        # Remove extra parentheses and the .where chain
        content = re.sub(
            r"\(\(await database\.database\)\.query\('[^']+'\)\.\.where\([^)]+\)\)",
            r"(\1)",
            content
        )

        # Fix broken isNotIn patterns
        content = re.sub(r"\.where\(\(t\)\s*=>\s*t\.(\w+)\.isNotIn\(\[(.*?)\]\)\)", '', content)
        content = re.sub(r"\.where\(\(t\)\s*=>\s*t\.(\w+)\.isBetweenValues\((\w+),\s*(\w+)\)\)", '', content)
        content = re.sub(r"\.where\(\(t\)\s*=>\s*t\.(\w+)\.isNull\(\)\)", '', content)
        content = re.sub(r"\.\.orderBy\(\[\(t\)\s*=>\s*OrderingTerm\(expression:\s*t\.(\w+),\s*mode:\s*OrderingMode\.(\w+)\)\]\)", '', content)
        content = re.sub(r"\.get\(\)", '', content)
        content = re.sub(r"\.getSingleOrNull\(\)", '', content)
        content = re.sub(r"\s*\.upsert\([^)]+\)", '', content)

        if content != original:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
