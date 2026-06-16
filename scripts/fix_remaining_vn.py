#!/usr/bin/env python3
"""Replace ALL remaining Vietnamese text strings with English."""
import os, re

REPLACEMENTS = {
    "'Khong co du lieu don.'": "'No order data.'",
    "'Da khop'": "'Matched'",
    "'Them khach hang'": "'Add Customer'",
    "'Chua co san pham nao.'": "'No products yet.'",
    "'Chua co don hang nao.'": "'No orders yet.'",
    "'Them chi phi'": "'Add Expense'",
    "'Them san pham de theo doi ton kho.'": "'Add products to track inventory.'",
    "'Con ${p.stockQuantity} . Ngan sap het: ${p.lowStockThreshold}'": "'Stock: ${p.stockQuantity}. Low threshold: ${p.lowStockThreshold}'",
    "'Con ${p.stockQuantity}'": "'Stock: ${p.stockQuantity}'",
    "'Da them ${_selected.length} san pham'": "'Added ${_selected.length} products'",
    "'Luu ${_selected.length} san pham'": "'Save ${_selected.length} products'",
    "'Sua san pham'": "'Edit Product'",
    "'Them anh'": "'Add Photo'",
    "'Them san pham dau tien de bat dau ban hang.'": "'Add your first product to start selling.'",
    "'Da xuat backup: $path'": "'Backup exported: $path'",
    "'Khong the xuat backup'": "'Cannot export backup'",
    "'Da them tai khoan'": "'Account added'",
    "'Chu tai khoan'": "'Account Holder'",
    "'Them tai khoan'": "'Add Account'",
    "'Da luu'": "'Saved'",
    "'Con ${p.stockQuantity} . Ngan sap het:'": "'Stock: ${p.stockQuantity}. Low:'",
}

def fix_file(fp):
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()

    modified = False
    for old, new in sorted(REPLACEMENTS.items(), key=lambda x: -len(x[0])):
        if old in content:
            content = content.replace(old, new)
            modified = True

    if modified:
        with open(fp, 'w', encoding='utf-8') as fh:
            fh.write(content)
        return True
    return False

if __name__ == '__main__':
    count = 0
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            if fix_file(fp):
                print(f'Fixed: {os.path.relpath(fp)}')
                count += 1
    print(f'\nFixed {count} files.')
