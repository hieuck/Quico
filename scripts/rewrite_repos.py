#!/usr/bin/env python3
"""Rewrite repository files to use sqflite raw SQL."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def rewrite_order_repo():
    fp = os.path.join(ROOT, 'lib', 'features', 'orders', 'data', 'order_repository.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    
    # Replace imports
    content = content.replace("import 'package:drift/drift.dart';", '')
    content = content.replace("import '../../../core/database/app_database.dart' as db;",
                              "import '../../../core/database/app_database.dart';")
    
    # Fix class to use raw SQL
    content = content.replace(
        'class OrderRepository {\n  final AppDatabase _db;\n\n  OrderRepository(this._db);',
        'class OrderRepository {\n  final AppDatabase _db;\n\n  OrderRepository(this._db);\n\n  Database get _d => throw UnimplementedError();'
    )
    
    # Fix select/into/update calls
    # Replace _db.select(table) pattern
    # This is tricky because _db is alias for import AND the field
    
    # For now, just fix the import issue
    content = content.replace(
        "import '../../../core/database/app_database.dart' as db;",
        "import '../../../core/database/app_database.dart';"
    )
    
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: order_repository.dart')

if __name__ == '__main__':
    rewrite_order_repo()
