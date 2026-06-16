#!/usr/bin/env python3
"""
Purge ALL Vietnamese text from code files.
- Validator messages: move to English (will be localized later)
- UI strings in non-l10n files: replace with English
- Any remaining Vietnamese without diacritics: replace with English
- Currency formatter: keep 'd' suffix as-is (VND convention)
- Parser data: keep Vietnamese WITH diacritics (business data)
- Normalizer data: keep Vietnamese WITH diacritics (lookup tables)
"""
import os, re

def fix_validators():
    fp = 'lib/core/utils/validators.dart'
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    replacements = {
        "return '\$fieldName không được để trống.'": "return '\$fieldName cannot be empty.'",
        "return '\$fieldName phải lớn hơn 0.'": "return '\$fieldName must be greater than 0.'",
        "return '\$fieldName không được âm.'": "return '\$fieldName cannot be negative.'",
        "return 'Tên cửa hàng không được để trống.'": "return 'Store name cannot be empty.'",
        "return 'Tên cửa hàng tối đa 80 ký tự.'": "return 'Store name max 80 characters.'",
        "return 'Tên sản phẩm không được để trống.'": "return 'Product name cannot be empty.'",
        "return 'Tên sản phẩm tối đa 120 ký tự.'": "return 'Product name max 120 characters.'",
        "return 'Giá bán không hợp lệ.'": "return 'Sale price is invalid.'",
        "return 'Giá vốn không hợp lệ.'": "return 'Cost price is invalid.'",
        "return 'Số lượng phải lớn hơn 0.'": "return 'Quantity must be greater than 0.'",
        "return 'Số tiền phải lớn hơn 0.'": "return 'Amount must be greater than 0.'",
    }

    for old, new in replacements.items():
        content = content.replace(old, new)

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: validators.dart')


def fix_parser_messages():
    fp = 'lib/core/ai/parser/rule_based_order_text_parser.dart'
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    replacements = {
        "message: 'Không nhận ra sản phẩm nào.'": "message: 'No products detected.'",
        "message: 'Không nhận diện được sản phẩm.'": "message: 'Could not identify product.'",
    }

    for old, new in replacements.items():
        content = content.replace(old, new)

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: parser messages')


def fix_receipt_pdf():
    fp = 'lib/core/receipt/receipt_pdf_service.dart'
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    replacements = {
        "'Khach: '": "'Customer: '",
        "'Giam gia'": "'Discount'",
        "'Tam tinh'": "'Subtotal'",
        "'Tong cong'": "'Total'",
        "'Thanh toan: '": "'Payment: '",
        "'Phuong thuc: '": "'Method: '",
        "'Ghi chu: '": "'Note: '",
        "'Cam on quy khach!'": "'Thank you!'",
        "'Da thanh toan'": "'Paid'",
        "'Chua thanh toan'": "'Unpaid'",
        "'Thanh toan mot phan'": "'Partial'",
        "'Tien mat'": "'Cash'",
        "'Chuyen khoan'": "'Bank Transfer'",
    }

    for old, new in replacements.items():
        content = content.replace(old, new)

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Fixed: receipt_pdf_service.dart')


def scan_remaining_vn():
    """Find any remaining Vietnamese text in code (outside of parser data)."""
    vn_pattern = re.compile(
        r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩị'
        r'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ]',
        re.IGNORECASE
    )
    issues = []
    skip_files = [
        'text_normalizer.dart',
        'rule_based_order_text_parser.dart',
        'rule_based_menu_text_parser.dart',
    ]
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'):
                continue
            if any(s in f for s in skip_files):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                lines = fh.readlines()
            for i, line in enumerate(lines, 1):
                if vn_pattern.search(line):
                    issues.append(f'  {fp}:{i}: {line.strip()[:100]}')
    return issues


if __name__ == '__main__':
    print('=== Purging Vietnamese from code ===')
    fix_validators()
    fix_parser_messages()
    fix_receipt_pdf()

    print('\n=== Remaining Vietnamese (check if acceptable) ===')
    for issue in scan_remaining_vn():
        print(issue)

    print('\nDone.')
