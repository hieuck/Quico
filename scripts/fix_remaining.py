#!/usr/bin/env python3
"""Fix remaining i18n issues after batch replacement."""
import os, re

def fix_broken_placeholders():
    """Replace placeholder keys with proper l10n calls."""
    replacements = {
        "'phone_optional'": "context.l10n.noCustomers",
        "'note_optional'": "context.l10n.noData",
        "'deactivate_warning'": "context.l10n.confirmDelete",
        "'add_customer_lbl'": "context.l10n.customer",
        "'stock_count'": "'Stock: ${p.stockQuantity}'",
        "'edit_product'": "context.l10n.edit",
        "'cart_items_count'": "'${_cart.length} items'",
        "'empty_cart_warning'": "'Order has no products'",
        "'order_created_snack'": "context.l10n.orderCreated",
        "'share_receipt'": "'Share Receipt'",
        "'customer_label'": "'Customer: ${receipt.customerName}'",
        "'expenses_empty_hint'": "'Record expenses to know true profit.'",
        "'add_expense'": "'Add Expense'",
        "'category'": "'Category'",
        "'amount'": "'Amount'",
        "'ingredients'": "'Ingredients'",
        "'labor'": "'Labor'",
        "'rent'": "'Rent'",
        "'shipping'": "'Shipping'",
        "'marketing'": "'Marketing'",
        "'other'": "'Other'",
        "'invalid_amount'": "'Invalid amount'",
        "'net_profit'": "'Net Profit'",
        "'best_sellers'": "'Best Sellers'",
        "'sales_count'": "'${p.quantity} sales'",
        "'inventory_empty_hint'": "'Add products to track inventory.'",
        "'scan_menu'": "'Scan Menu'",
        "'menu_import_hint'": "'Take menu photo to import products quickly.'",
        "'import_success'": "'Added ${_selected.length} products'",
        "'backup_restore'": "'Backup & Restore'",
        "'version_1_0_0'": "'Version 1.0.0'",
        "'backup_hint'": "'Export your data to keep it safe.'",
        "'backup_exported'": "'Exported to: \$path'",
        "'import_hint'": "'Import data from backup file.'",
        "'account_added'": "'Account added'",
        "'add_account'": "'Add Account'",
        "'bank_name'": "'Bank Name'",
        "'bank_code'": "'Bank Code (e.g. VCB)'",
        "'account_number'": "'Account Number'",
        "'account_holder'": "'Account Holder'",
        "'saved'": "'Saved'",
        "'name_required'": "'Name is required'",
        "'food_beverage'": "'Food & Beverage'",
        "'online_shop'": "'Online Shop'",
        "'retail_shop'": "'Retail Shop'",
    }

    count = 0
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            modified = False
            for old, new in sorted(replacements.items(), key=lambda x: -len(x[0])):
                if old in content:
                    content = content.replace(old, new)
                    modified = True

            if modified:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(content)
                print(f'Fixed: {fp}')
                count += 1

    return count


def add_missing_imports():
    """Add l10n extension import to files using context.l10n."""
    count = 0
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                lines = fh.readlines()

            content = ''.join(lines)
            if 'context.l10n' not in content:
                continue
            if 'l10n_extension.dart' in content:
                continue

            rel = os.path.relpath('lib/l10n/l10n_extension.dart', os.path.dirname(fp)).replace('\\', '/')
            import_line = f"import '{rel}';\n"

            last_import = -1
            for i, line in enumerate(lines):
                if line.startswith('import ') or line.startswith('export '):
                    last_import = i

            if last_import >= 0:
                lines.insert(last_import + 1, import_line)
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.writelines(lines)
                print(f'Import: {fp}')
                count += 1

    return count


def fix_receipt_pdf():
    """Fix receipt_pdf_service.dart which may have broken strings."""
    fp = 'lib/core/receipt/receipt_pdf_service.dart'
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()
    content = content.replace("context.l10n.customer", "'Customer'")
    with open(fp, 'w', encoding='utf-8') as fh:
        fh.write(content)
    print(f'Fixed: {fp}')


def fix_app_constants():
    """Revert app_constants.dart if broken."""
    fp = 'lib/core/constants/app_constants.dart'
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()
    if 'context.l10n' in content:
        content = """class AppConstants {
  static const String appName = 'Quico';
  static const String tagline = 'Ban hang de nhu nhan tin.';
  static const String defaultCurrency = 'VND';
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
  static const int defaultLowStockThreshold = 5;
  static const int storeNameMaxLength = 80;
  static const int productNameMaxLength = 120;
  static const String defaultReceiptFooter = 'Cam on quy khach!';
  static const String defaultBundleId = 'dev.hieuck.quico';
}
"""
        with open(fp, 'w', encoding='utf-8') as fh:
            fh.write(content)
        print(f'Restored: {fp}')


def fix_status_badge():
    """Fix status_badge.dart to use proper English labels."""
    fp = 'lib/shared/widgets/status_badge.dart'
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()
    content = content.replace("'Da thanh toan'", "'Paid'")
    content = content.replace("'Chua thanh toan'", "'Unpaid'")
    content = content.replace("'Thanh toan mot phan'", "'Partial'")
    content = content.replace("'Nhap'", "'Draft'")
    content = content.replace("'Da huy'", "'Cancelled'")
    content = content.replace("'Da hoan'", "'Refunded'")
    with open(fp, 'w', encoding='utf-8') as fh:
        fh.write(content)
    print(f'Fixed: {fp}')


def fix_store_setup():
    """Fix store_setup_screen.dart to use English strings."""
    fp = 'lib/features/onboarding/presentation/store_setup_screen.dart'
    with open(fp, encoding='utf-8') as fh:
        content = fh.read()
    content = content.replace("'food_beverage'", "'Food & Beverage'")
    content = content.replace("'online_shop'", "'Online Shop'")
    content = content.replace("'retail_shop'", "'Retail Shop'")
    content = content.replace("'other'", "'Other'")
    with open(fp, 'w', encoding='utf-8') as fh:
        fh.write(content)
    print(f'Fixed: {fp}')


if __name__ == '__main__':
    print('=== Fixing remaining i18n issues ===')
    fix_app_constants()
    fix_receipt_pdf()
    fix_status_badge()
    fix_store_setup()
    c1 = fix_broken_placeholders()
    c2 = add_missing_imports()
    print(f'\nFixed {c1} files with placeholders.')
    print(f'Added imports to {c2} files.')
    print('Done.')
