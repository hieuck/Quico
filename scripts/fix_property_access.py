#!/usr/bin/env python3
"""Fix Drift-style .property access on query results -> map['property'] access."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

PROPERTIES = ['value', 'name', 'phone', 'note', 'id', 'key', 'orderCode',
              'order_code', 'storeId', 'store_id', 'productName', 'product_name',
              'salePrice', 'sale_price', 'costPrice', 'cost_price',
              'stockQuantity', 'stock_quantity', 'imagePath', 'image_path',
              'totalAmount', 'total_amount', 'discountAmount', 'discount_amount',
              'createdAt', 'created_at', 'updatedAt', 'updated_at',
              'completedAt', 'completed_at', 'cancelledAt', 'cancelled_at',
              'totalSpent', 'total_spent', 'totalOrders', 'total_orders',
              'paymentStatus', 'payment_status', 'paymentMethod', 'payment_method',
              'lineTotal', 'line_total', 'lineProfit', 'line_profit',
              'unitPrice', 'unit_price', 'quantity', 'category',
              'stockQuantity', 'lowStockThreshold', 'sku', 'barcode',
              'isActive', 'is_active', 'deletedAt', 'deleted_at',
              'businessType', 'business_type', 'phone', 'address',
              'logoPath', 'logo_path', 'normalizedName', 'normalized_name',
              'customerId', 'customer_id', 'orderCode', 'order_code',
              'status', 'subtotal', 'discount', 'total', 'cost',
              'grossProfit', 'gross_profit', 'paidAmount', 'paid_amount',
              'source', 'originalInput', 'original_input',
              'bankCode', 'bank_name', 'accountNumber', 'account_name',
              'spentAt', 'quantityDelta', 'quantityAfter']

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib', 'features')):
    for f in files:
        if not f.endswith('.dart'): continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        original = content
        
        # Replace settings.value -> settings!['value'] when settings is query result
        # Pattern: `\.value` after a variable that's a query result
        # Common variable names: settings, store, product, customer, order, row, p, r, c, o, item
        
        common_map_vars = ['settings', 'store', 'product', 'customer', 'order', 'row']
        for v in common_map_vars:
            for prop in PROPERTIES:
                old = f'{v}.{prop}'
                new = f"{v}!['{prop}']"
                if old in content:
                    content = content.replace(old, new)
        
        if content != original:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')

if __name__ == '__main__':
    print('Fixing property access patterns...')
