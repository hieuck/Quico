#!/usr/bin/env python3
"""Find placeholder strings in Dart code that need ARB keys."""
import os, re

KNOWN = {
    'active_store_id', 'vi', 'manual', 'text', 'voice', 'screenshot',
    'cash', 'bank_transfer', 'other', 'paid', 'unpaid', 'partial',
    'draft', 'cancelled', 'refunded', 'sale', 'refund', 'correction',
    'initial', 'import', 'export', 'order', 'product', 'store',
    'settings', 'home', 'orders', 'products', 'reports', 'more',
    'total', 'discount', 'save', 'edit', 'delete', 'cancel',
    'confirm', 'error', 'loading', 'search', 'customer',
    'inventory', 'expenses', 'receipt', 'start',
}

for root, dirs, files in os.walk('lib'):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        for m in re.finditer(r"'([a-z_]+)'", content):
            word = m.group(1)
            if word in KNOWN or word.startswith('http') or len(word) <= 5:
                continue
            if '_' in word:
                line_num = content[:m.start()].count('\n') + 1
                print(f'{os.path.relpath(fp)}:{line_num}: {m.group()}')
