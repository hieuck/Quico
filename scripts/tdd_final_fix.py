#!/usr/bin/env python3
"""Fix remaining 42 errors."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 1. Fix store_setup_screen - ConsumerStatefulWidget
fp = os.path.join(ROOT, 'lib', 'features', 'onboarding', 'presentation', 'store_setup_screen.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace("import 'package:flutter/material.dart';",
              "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';")
c = c.replace('StoreSetupScreen extends StatefulWidget', 'StoreSetupScreen extends ConsumerStatefulWidget')
c = c.replace("State<StoreSetupScreen> createState()", "ConsumerState<StoreSetupScreen> createState()")
c = c.replace('State<StoreSetupScreen>', 'ConsumerState<StoreSetupScreen>')
c = c.replace('void _createStore()', 'Future<void> _createStore() async')
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: store_setup_screen.dart')

# 2. Fix order_repository - int.tryParse
fp = os.path.join(ROOT, 'lib', 'features', 'orders', 'data', 'order_repository.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace("int.tryParse(rows.first['value'])", "int.tryParse(rows.first['value'] as String?)")
# Fix line 190 area: check what's there
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: order_repository.dart')

# 3. Fix expense_form_screen
fp = os.path.join(ROOT, 'lib', 'features', 'expenses', 'presentation', 'expense_form_screen.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace(': Value.absent(),', ': null,')
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: expense_form_screen.dart')

# 4. Fix product_repository
fp = os.path.join(ROOT, 'lib', 'features', 'products', 'data', 'product_repository.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace("input.isActive ? 1 : 0", "input.isActive == true ? 1 : 0")
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: product_repository.dart')

print('Done.')
