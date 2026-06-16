#!/usr/bin/env python3
"""Fix ALL identified issues automatically."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_const_with_l10n():
    """Remove 'const' from constructors that use context.l10n."""
    count = 0
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            if 'const' not in content or 'context.l10n' not in content:
                continue

            lines = content.split('\n')
            modified = False
            new_lines = []
            for line in lines:
                # Remove 'const' from widget constructors using context.l10n
                # Pattern: `const Text(context.l10n.` -> `Text(context.l10n.`
                # Pattern: `const Center(child: Text(context.l10n.` -> `Center(child: Text(context.l10n.`
                # Pattern: `const EmptyState(` when it contains context.l10n in the same line
                # Pattern: `const InputDecoration(labelText: context.l10n.`
                # Pattern: `const SnackBar(content: Text(context.l10n.`
                if 'context.l10n' in line and 'const ' in line:
                    # Remove const from this line
                    line = re.sub(r'\bconst\s+(?=Text|Center|EmptyState|InputDecoration|SnackBar|Padding|SizedBox|Row|Column|Container|Card|ListTile)', '', line)
                    modified = True
                new_lines.append(line)

            if modified:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write('\n'.join(new_lines))
                count += 1
                print(f'Fixed const: {os.path.relpath(fp, ROOT)}')

    return count


def fix_import_orders():
    """Fix wrong import depths in order files."""
    fixes = {
        'lib/features/orders/presentation/screens/order_detail_screen.dart': {
            '../../../core/database/app_database.dart': '../../../../core/database/app_database.dart',
            '../../../core/utils/currency_formatter.dart': '../../../../core/utils/currency_formatter.dart',
            '../../../shared/widgets/status_badge.dart': '../../../../shared/widgets/status_badge.dart',
            '../../../shared/widgets/confirm_dialog.dart': '../../../../shared/widgets/confirm_dialog.dart',
        },
        'lib/features/orders/presentation/screens/order_list_screen.dart': {
            '../../../core/database/app_database.dart': '../../../../core/database/app_database.dart',
            '../../../core/utils/currency_formatter.dart': '../../../../core/utils/currency_formatter.dart',
            '../../../shared/widgets/empty_state.dart': '../../../../shared/widgets/empty_state.dart',
            '../../../shared/widgets/status_badge.dart': '../../../../shared/widgets/status_badge.dart',
        },
        'lib/features/orders/presentation/screens/pos_screen.dart': {
            '../../../core/database/app_database.dart': '../../../../core/database/app_database.dart',
            '../../../core/utils/currency_formatter.dart': '../../../../core/utils/currency_formatter.dart',
            '../../../shared/widgets/product_image.dart': '../../../../shared/widgets/product_image.dart',
            '../../../shared/widgets/confirm_dialog.dart': '../../../../shared/widgets/confirm_dialog.dart',
            '../../products/data/product_repository.dart': '../../../products/data/product_repository.dart',
            '../../products/domain/product.dart': '../../../products/domain/product.dart',
        },
    }

    count = 0
    for fp, replacements in fixes.items():
        full_path = os.path.join(ROOT, fp)
        if not os.path.exists(full_path):
            print(f'MISSING: {fp}')
            continue
        with open(full_path, encoding='utf-8') as fh:
            content = fh.read()
        modified = False
        for old, new in replacements.items():
            if old in content:
                content = content.replace(old, new)
                modified = True
        if modified:
            with open(full_path, 'w', encoding='utf-8') as fh:
                fh.write(content)
            print(f'Fixed imports: {fp}')
            count += 1

    return count


def fix_const_items_lists():
    """Fix 'items: const [' containing context.l10n values."""
    fixes = {
        'lib/features/orders/presentation/screens/pos_screen.dart': [
            ("            items: const [\n              DropdownMenuItem(value: 'paid', child: Text(context.l10n.paid)),\n              DropdownMenuItem(value: 'unpaid', child: Text(context.l10n.unpaid)),\n            ],",
             "            items: [\n              const DropdownMenuItem(value: 'paid', child: Text(context.l10n.paid)),\n              const DropdownMenuItem(value: 'unpaid', child: Text(context.l10n.unpaid)),\n            ],"),
            ("            items: const [\n              DropdownMenuItem(value: 'cash', child: Text(context.l10n.cash)),\n              DropdownMenuItem(value: 'bank_transfer', child: Text(context.l10n.bankTransfer)),\n            ],",
             "            items: [\n              const DropdownMenuItem(value: 'cash', child: Text(context.l10n.cash)),\n              const DropdownMenuItem(value: 'bank_transfer', child: Text(context.l10n.bankTransfer)),\n            ],"),
        ],
    }

    count = 0
    for fp, replacement_list in fixes.items():
        full_path = os.path.join(ROOT, fp)
        if not os.path.exists(full_path):
            continue
        with open(full_path, encoding='utf-8') as fh:
            content = fh.read()
        modified = False
        for old, new in replacement_list:
            if old in content:
                content = content.replace(old, new)
                modified = True
        if modified:
            with open(full_path, 'w', encoding='utf-8') as fh:
                fh.write(content)
            print(f'Fixed const list: {fp}')
            count += 1

    return count


def add_missing_l10n_keys():
    """Add missing keys to AppLocalizations."""
    fp = os.path.join(ROOT, 'lib', 'l10n', 'app_localizations.dart')
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()

    # Check and add missing getters
    missing = {
        'screenshots': "String get screenshots => _t('screenshots');",
    }

    for key, getter in missing.items():
        if f"_t('{key}')" not in content and f"_t(\"{key}\")" not in content:
            # Add before the closing brace of the class
            last_brace = content.rfind('}')
            if last_brace >= 0:
                content = content[:last_brace] + f'  {getter}\n' + content[last_brace:]
                print(f'Added l10n key: {key}')

    with open(fp, 'w', encoding='utf-8') as fh:
        fh.write(content)


def fix_pos_list_trailing():
    """Fix remaining const list issue in POS screen specifically."""
    fp = os.path.join(ROOT, 'lib', 'features', 'orders', 'presentation', 'screens', 'pos_screen.dart')
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()

    # Fix the paymentStatus dropdown items list
    old_paid = "decoration: const InputDecoration(labelText: context.l10n.paymentStatus, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),"
    new_paid = "decoration: InputDecoration(labelText: context.l10n.paymentStatus, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),"
    content = content.replace(old_paid, new_paid)

    old_method = "decoration: const InputDecoration(labelText: context.l10n.paymentMethod, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),"
    new_method = "decoration: InputDecoration(labelText: context.l10n.paymentMethod, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),"
    content = content.replace(old_method, new_method)

    with open(fp, 'w', encoding='utf-8') as fh:
        fh.write(content)
    print(f'Fixed InputDecoration: {fp}')


if __name__ == '__main__':
    print('=== Fixing All Issues ===\n')

    c1 = fix_const_with_l10n()
    c2 = fix_import_orders()
    c3 = fix_const_items_lists()
    add_missing_l10n_keys()
    fix_pos_list_trailing()

    print(f'\nFixed: {c1} files (const removal), {c2} files (imports)')
    print('Done.')
