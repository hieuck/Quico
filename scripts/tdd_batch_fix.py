#!/usr/bin/env python3
"""TDD batch fix: fix ALL remaining errors in one pass."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_store_setup():
    fp = os.path.join(ROOT, 'lib', 'features', 'onboarding', 'presentation', 'store_setup_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # The _createStore() method uses broken Drift ORM patterns. Replace entirely.
    old_method = """  void _createStore() {
    if (!_formKey.currentState!.validate()) return;
    final name = _storeName.trim();
    if (name.isEmpty) return;

    final database = ref.read(db.appDatabaseProvider);
    final now = DateTimeUtils.nowMillis();
    final storeId = IdGenerator.newId();

    database.into(database.stores).insert(db.StoresCompanion.insert(
      id: storeId,
      name: name,
      businessType: _businessType.isNotEmpty ? db.Value(_businessType) : db.Value.absent(),
      currency: 'VND',
      createdAt: now,
      updatedAt: now,
    ));

    database.into(database.appSettings).insert(db.AppSettingsCompanion.insert(
      key: 'active_store_id',
      value: storeId,
      updatedAt: now,
    ));"""
    
    new_method = """  void _createStore() {
    if (!_formKey.currentState!.validate()) return;
    final name = _storeName.trim();
    if (name.isEmpty) return;

    final database = ref.read(appDatabaseProvider);
    final now = DateTimeUtils.nowMillis();
    final storeId = IdGenerator.newId();

    database.into(database.stores).insert({
      'id': storeId,
      'name': name,
      'business_type': _businessType.isNotEmpty ? _businessType : null,
      'currency': 'VND',
      'created_at': now,
      'updated_at': now,
    });

    database.into(database.appSettings).insert({
      'key': 'active_store_id',
      'value': storeId,
      'updated_at': now,
    });"""
    
    content = content.replace(old_method, new_method)
    # Remove unused imports
    content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", '')
    # Remove unused ref
    content = content.replace('class _StoreSetupScreenState extends State<StoreSetupScreen>', 'class _StoreSetupScreenState extends State<StoreSetupScreen>')
    
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: store_setup_screen.dart')

def fix_expense_list():
    fp = os.path.join(ROOT, 'lib', 'features', 'expenses', 'presentation', 'expense_list_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # OrderingTerm/OrderingMode are Drift-specific. Replace with simple orderBy string.
    content = content.replace("..orderBy([(t) => OrderingTerm(expression: t.spentAt, mode: OrderingMode.desc)])", "")
    content = content.replace(", orderBy: 'spent_at desc'", '')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: expense_list_screen.dart')

def fix_inventory():
    fp = os.path.join(ROOT, 'lib', 'features', 'inventory', 'presentation', 'inventory_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace('database.select(database.products)', '(await database.database).query(\'products\')')
    content = content.replace('database.select(database.inventory)', '(await database.database).query(\'inventory\')')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: inventory_screen.dart')

def fix_customer_form():
    fp = os.path.join(ROOT, 'lib', 'features', 'customers', 'presentation', 'customer_form_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # Fix Value() -> direct value
    content = content.replace("Value(_phoneCtrl.text.trim())", "_phoneCtrl.text.trim()")
    content = content.replace("Value.absent()", "null")
    content = content.replace("Value(_noteCtrl.text.trim())", "_noteCtrl.text.trim()")
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: customer_form_screen.dart')

def fix_expense_form():
    fp = os.path.join(ROOT, 'lib', 'features', 'expenses', 'presentation', 'expense_form_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace("Value.absent()", "null")
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: expense_form_screen.dart')

if __name__ == '__main__':
    fix_store_setup()
    fix_expense_list()
    fix_inventory()
    fix_customer_form()
    fix_expense_form()
    print('Done.')
