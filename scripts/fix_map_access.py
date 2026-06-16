#!/usr/bin/env python3
"""Replace .property access on map variables with ['property'] syntax.
Only replaces on variables that are known to be query result maps."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Known map variables from query results
MAP_VARS = ['settings', 'store', 'row', 'r']

# Known properties from Drift models
PROPS = ['value', 'name', 'phone', 'note', 'id', 'orderCode', 'type',
         'status', 'price', 'total', 'count', 'date', 'key', 'category',
         'amount', 'costPrice', 'salePrice', 'stockQuantity',
         'lowStockThreshold', 'imagePath', 'sku', 'barcode',
         'isActive', 'businessType', 'logoPath',
         'normalizedName', 'storeId', 'customerId',
         'orderCode', 'paymentStatus', 'paymentMethod',
         'subtotal', 'discountAmount', 'totalAmount', 'costAmount',
         'grossProfit', 'paidAmount', 'source', 'originalInput',
         'createdAt', 'updatedAt', 'completedAt', 'cancelledAt',
         'totalSpent', 'totalOrders',
         'unitPrice', 'lineTotal', 'lineProfit',
         'productName', 'productId', 'referenceType', 'referenceId',
         'quantityDelta', 'quantityAfter',
         'bankCode', 'bankName', 'accountNumber', 'accountName',
         'isDefault', 'spentAt', 'errorMessage', 'parsedJson',
         'inputText', 'success']

def fix_file(fp):
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    original = content

    # For each known map variable, replace .property access
    for var in MAP_VARS:
        for prop in PROPS:
            old = f'{var}.{prop}'
            new = f"{var}['{prop}']"
            content = content.replace(old, new)

    if content != original:
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

count = 0
for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'): continue
        fp = os.path.join(root, f)
        if fix_file(fp):
            count += 1
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
print(f'\nFixed {count} files.')
