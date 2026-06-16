#!/usr/bin/env python3
"""Fix ALL files for sqflite migration - remove drift refs."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'): continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        original = content

        content = re.sub(r"import 'package:drift/drift.dart';", '', content)
        content = content.replace('as db;', ';')
        content = content.replace('db.appDatabaseProvider', 'appDatabaseProvider')
        content = content.replace('db.AppDatabase', 'AppDatabase')
        content = content.replace('db.Value(', 'Value(')
        content = content.replace('db.Value.absent()', 'Value.absent()')
        content = content.replace('db.StoresCompanion', 'StoresCompanion')
        content = content.replace('db.ProductsCompanion', 'ProductsCompanion')
        content = content.replace('db.CustomersCompanion', 'CustomersCompanion')
        content = content.replace('db.OrdersCompanion', 'OrdersCompanion')
        content = content.replace('db.OrderItemsCompanion', 'OrderItemsCompanion')
        content = content.replace('db.InventoryMovementsCompanion', 'InventoryMovementsCompanion')
        content = content.replace('db.ExpensesCompanion', 'ExpensesCompanion')
        content = content.replace('db.BankAccountsCompanion', 'BankAccountsCompanion')
        content = content.replace('db.AppSettingsCompanion', 'AppSettingsCompanion')
        content = content.replace('db.OrderingTerm(', 'OrderingTerm(')
        content = content.replace('db.OrderingMode.', 'OrderingMode.')
        content = content.replace("import 'package:drift/drift.dart';", '')

        if content != original:
            with open(fp, 'w', encoding='utf-8') as fh:
                fh.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
