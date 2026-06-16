#!/usr/bin/env python3
"""
TDD-driven fix: identify all errors, apply fixes, verify.
Run this locally, then commit + push to verify on CI.
"""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_all():
    """Fix all known issues in one pass."""
    fixes_applied = 0

    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            original = content

            # 1. Add 'as db' alias to app_database imports
            patterns = [
                ("import '../../core/database/app_database.dart';",
                 "import '../../core/database/app_database.dart' as db;"),
                ("import '../../../core/database/app_database.dart';",
                 "import '../../../core/database/app_database.dart' as db;"),
                ("import '../../../../core/database/app_database.dart';",
                 "import '../../../../core/database/app_database.dart' as db;"),
            ]
            for old, new in patterns:
                if old in content and 'as db' not in content:
                    content = content.replace(old, new)
                    break

            # 2. Fix missing flutter_riverpod import for StateProvider
            if 'StateProvider<' in content and 'flutter_riverpod' not in content:
                if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
                    content = content.replace(
                        "import 'package:flutter/material.dart';",
                        "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';"
                    )

            # 3. Replace appDatabaseProvider with db.appDatabaseProvider
            if 'app_database.dart as db' in content:
                content = content.replace(
                    'ref.read(appDatabaseProvider)',
                    'ref.read(db.appDatabaseProvider)'
                )
                content = content.replace(
                    'ref.watch(appDatabaseProvider)',
                    'ref.watch(db.appDatabaseProvider)'
                )
                content = content.replace(
                    'container.read(appDatabaseProvider)',
                    'container.read(db.appDatabaseProvider)'
                )
                # Rename 'final db' to 'final database' to avoid shadowing the import alias
                lines = content.split('\n')
                new_lines = []
                for line in lines:
                    if 'final db = ref.read' in line or 'final db = await' in line:
                        line = line.replace('final db =', 'final database =')
                    new_lines.append(line)
                content = '\n'.join(new_lines)

            if content != original:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                fixes_applied += 1
                print(f'FIXED: {os.path.relpath(fp, ROOT)}')

    return fixes_applied

def fix_locale_provider():
    fp = os.path.join(ROOT, 'lib', 'l10n', 'locale_provider.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    if 'flutter_riverpod' not in content:
        content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        print('FIXED: locale_provider.dart')

def fix_app_bootstrap():
    fp = os.path.join(ROOT, 'lib', 'app', 'app_bootstrap.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace("import '../core/database/app_database.dart';",
                              "import '../core/database/app_database.dart' as db;")
    content = content.replace('container.read(appDatabaseProvider)',
                              'container.read(db.appDatabaseProvider)')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('FIXED: app_bootstrap.dart')

if __name__ == '__main__':
    print('Applying TDD fixes...')
    c = fix_all()
    fix_locale_provider()
    fix_app_bootstrap()
    print(f'\nFixed {c} files. Commit and push to verify.')
