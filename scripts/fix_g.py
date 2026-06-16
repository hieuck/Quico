#!/usr/bin/env python3
"""Fix app_database.g.dart - replace broken escapes with $."""
import os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
fp = os.path.join(ROOT, 'lib', 'core', 'database', 'app_database.g.dart')
with open(fp, encoding='utf-8') as f:
    content = f.read()
# Fix all single backslashes before dollar signs
content = content.replace('\\$', '$')
# Fix the broken class name
content = content.replace('class _\\ extends', 'class _$AppDatabase extends')
content = content.replace('_\(QueryExecutor', '_$AppDatabase(QueryExecutor')
with open(fp, 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed g.dart')
