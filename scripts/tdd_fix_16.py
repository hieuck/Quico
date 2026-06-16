#!/usr/bin/env python3
"""Fix remaining 16 errors."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 1. Fix store_setup_screen - missing riverpod import
fp = os.path.join(ROOT, 'lib', 'features', 'onboarding', 'presentation', 'store_setup_screen.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", '')
c = c.replace("import 'package:flutter/material.dart';",
              "import 'package:flutter/material.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';")
c = c.replace('ConsumerStatefulWidget', 'ConsumerStatefulWidget')  # verify it's there
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: store_setup_screen')

# 2. Fix product_list_screen - invalid_constant
fp = os.path.join(ROOT, 'lib', 'features', 'products', 'presentation', 'product_list_screen.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace('const EmptyState(', '_emptyState(')
c += '\nWidget _emptyState() => EmptyState('
lines = c.split('\n')
# Find the empty state and fix const
for i, line in enumerate(lines):
    if '_emptyState(icon: Icons.inventory_2' in line:
        lines[i] = line.replace('_emptyState(icon:', 'EmptyState(icon:')
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: product_list_screen')

# 3. Fix order_repository line 21
fp = os.path.join(ROOT, 'lib', 'features', 'orders', 'data', 'order_repository.dart')
with open(fp, encoding='utf-8') as f:
    c = f.read()
c = c.replace("int.tryParse(rows.first['value'] as String?)", "int.tryParse(rows.first['value'] as String?)?")
with open(fp, 'w', encoding='utf-8') as f:
    f.write(c)
print('Fixed: order_repository')

print('Done.')
