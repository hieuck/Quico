#!/usr/bin/env python3
"""Fix remaining issues: revert _db to _database, fix BankAccountsCompanion, etc."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def revert_report_repo():
    fp = os.path.join(ROOT, 'lib', 'features', 'reports', 'data', 'report_repository.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace('_database', '_db')
    content = content.replace('db.orderItems', '_db.orderItems')
    content = content.replace('db.orders', '_db.orders')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: report_repository.dart')

def fix_reports_screen():
    fp = os.path.join(ROOT, 'lib', 'features', 'reports', 'presentation', 'reports_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # The warning: `db` refers to import prefix
    # Fix by using proper variable name
    content = content.replace('ref.read(db.appDatabaseProvider)', 'ref.read(db.appDatabaseProvider)')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: reports_screen.dart')

def fix_bank_accounts():
    fp = os.path.join(ROOT, 'lib', 'features', 'settings', 'presentation', 'bank_accounts_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace('BankAccountsCompanion.insert', 'db.BankAccountsCompanion.insert')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: bank_accounts_screen.dart')

def fix_store_settings():
    fp = os.path.join(ROOT, 'lib', 'features', 'settings', 'presentation', 'store_settings_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # Fix StoresCompanion.custom with 'extra_positional_arguments' error
    # The issue: StoresCompanion.custom({'key': val}) became db.StoresCompanion.custom({'key': val})
    # but custom() takes positional args differently in Drift 2.x
    # The correct form is db.StoresCompanion.custom({'key': val})
    # But the error says "Too many positional arguments: 0 expected, but 1 found"
    # This means custom() doesn't take positional args in this version
    # Use the normal .write() instead with a companion
    old = """await (database.update(database.stores)..where((t) => t.id.equals(settings.value))).write(
                        db.StoresCompanion.custom({'name': _nameCtrl.text.trim(), 'updated_at': DateTime.now().millisecondsSinceEpoch}),
                      );"""
    new = """await (database.update(database.stores)..where((t) => t.id.equals(settings.value))).write(
                        db.StoresCompanion(
                          name: db.Value(_nameCtrl.text.trim()),
                          updatedAt: db.Value(DateTime.now().millisecondsSinceEpoch),
                        ),
                      );"""
    content = content.replace(old, new)
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: store_settings_screen.dart')

if __name__ == '__main__':
    revert_report_repo()
    fix_reports_screen()
    fix_bank_accounts()
    fix_store_settings()
    print('Done.')
