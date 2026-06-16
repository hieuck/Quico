#!/usr/bin/env python3
"""Audit codebase for remaining issues."""
import os, re

def check_localized_strings():
    issues = []
    vi_pattern = re.compile(
        r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩị'
        r'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ]',
        re.IGNORECASE
    )

    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            if 'context.l10n' in content:
                continue

            lines = content.split('\n')
            for i, line in enumerate(lines, 1):
                s = line.strip()
                if s.startswith('import ') or s.startswith('// '):
                    continue
                if vi_pattern.search(s):
                    issues.append((fp, i, s[:80]))

    return issues

def check_missing_features():
    """Verify features listed in docs exist."""
    features = {
        'onboarding': ['welcome_screen', 'store_setup'],
        'dashboard': ['home_screen'],
        'products': ['product_list', 'product_form', 'product_detail', 'menu_import'],
        'orders': ['pos_screen', 'order_list', 'order_detail'],
        'customers': ['customer_list', 'customer_form', 'customer_detail'],
        'inventory': ['inventory_screen'],
        'expenses': ['expense_list', 'expense_form'],
        'reports': ['reports_screen'],
        'receipts': ['receipt_screen'],
        'settings': ['settings_screen', 'store_settings', 'bank_accounts', 'backup'],
        'ai_order': ['ai_order_screen', 'ai_review_screen'],
    }
    missing = []
    for feat, screens in features.items():
        for screen in screens:
            found = False
            for root, dirs, files in os.walk('lib/features'):
                for f in files:
                    if screen in f:
                        found = True
                        break
            if not found:
                missing.append(f'{feat}: {screen}')
    return missing

def check_const_issues():
    """Find remaining const with runtime values."""
    issues = []
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                lines = fh.readlines()
            for i, line in enumerate(lines, 1):
                if 'const' in line and 'context.l10n' in line:
                    issues.append((fp, i, line.strip()[:80]))
    return issues

if __name__ == '__main__':
    print('=== UNLOCALIZED VIETNAMESE STRINGS ===')
    for fp, line, text in check_localized_strings():
        print(f'  {fp}:{line}: {text}')

    print('\n=== CONST ISSUES ===')
    for fp, line, text in check_const_issues():
        print(f'  {fp}:{line}: {text}')

    print('\n=== MISSING FEATURES ===')
    for m in check_missing_features():
        print(f'  {m}')

    print('\nDone.')
