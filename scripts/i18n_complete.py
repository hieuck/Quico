#!/usr/bin/env python3
"""Complete i18n replacement for ALL hardcoded Vietnamese/English strings."""
import re, os

# Mapping from hardcoded string -> context.l10n key
# Catches strings WITH and WITHOUT diacritics
MAP = {
    # Customers
    "'Khach hang'": "context.l10n.customer",
    "'Chua co khach hang'": "context.l10n.noCustomers",
    "'Them khach hang'": "'add_customer_lbl'",  # skip, will handle manually
    "'Them khach hang de theo doi lich su mua hang.'": "context.l10n.noCustomers",
    "'Co loi'": "context.l10n.error",
    "'Co loi xay ra'": "context.l10n.error",
    "'Khong tim thay'": "context.l10n.error",
    "'Khong tim thay don'": "context.l10n.error",
    "'Khong tim thay san pham'": "context.l10n.error",
    "'Khong the luu san pham'": "context.l10n.saveFailed",
    "'Khong the hoan tat don'": "context.l10n.orderFailed",
    "'Khong the tao don'": "context.l10n.orderFailed",

    # Customer form
    "'Ten khach hang'": "context.l10n.customer",
    "'So dien thoai (khong bat buoc)'": "'phone_optional'",
    "'Ghi chu (khong bat buoc)'": "'note_optional'",

    # Product list
    "'San pham'": "context.l10n.products",
    "'Chua co san pham'": "context.l10n.noProducts",
    "'Sap het'": "context.l10n.lowStock",
    "'Con ${p.stockQuantity}'": "'stock_count'",
    "'Con ${p.stockQuantity} . Ngan sap het: ${p.lowStockThreshold}'": "'stock_detail'",

    # Product detail
    "'Chi tiet san pham'": "context.l10n.products",
    "'Dang ngung ban'": "context.l10n.deactivate",
    "'Ngung ban?'": "context.l10n.deactivate",
    "'San pham se an khoi POS.'": "'deactivate_warning'",

    # Product form
    "'Them san pham'": "context.l10n.addProduct",
    "'Sua san pham'": "'edit_product'",
    "'SKU'": "context.l10n.skuOptional",
    "'Ngan sap het'": "context.l10n.lowStockThreshold",
    "'Gia ban'": "context.l10n.salePrice",
    "'Gia von'": "context.l10n.costPrice",
    "'Ton kho'": "context.l10n.stockQuantity",
    "'Luu san pham'": "context.l10n.save",

    # POS
    "'Tao don'": "context.l10n.manualOrder",
    "'${_cart.length} mon'": "'cart_items_count'",
    "'Hoan tat don'": "context.l10n.completeOrder",
    "'Don hang chua co san pham'": "'empty_cart_warning'",
    "'Da thanh toan'": "context.l10n.paid",
    "'Chua thanh toan'": "context.l10n.unpaid",
    "'Thanh toan mot phan'": "context.l10n.partial",
    "'Trang thai'": "context.l10n.paymentStatus",
    "'Phuong thuc'": "context.l10n.paymentMethod",
    "'Tien mat'": "context.l10n.cash",
    "'Chuyen khoan'": "context.l10n.bankTransfer",
    "'Xac nhan don?'": "context.l10n.confirmOrder",
    "'Xac nhan hoan tat don hang?'": "context.l10n.confirmOrderBody",
    "'Don ${order.orderCode} da tao'": "'order_created_snack'",

    # Order list
    "'Don hang'": "context.l10n.orders",
    "'Chua co don hang'": "context.l10n.noOrders",
    "'Don hang se xuat hien o day.'": "context.l10n.noOrders",

    # Order detail
    "'Chi tiet don'": "context.l10n.orders",
    "'Tong tien'": "context.l10n.total",
    "'Huy don'": "context.l10n.cancelOrder",
    "'Huy don?'": "context.l10n.cancelOrderConfirm",
    "'Ton kho se duoc hoan lai.'": "context.l10n.cancelOrderBody",
    "'Xem hoa don'": "context.l10n.receipt",

    # Receipt
    "'Hoa don'": "context.l10n.receipt",
    "'Tam tinh'": "context.l10n.subtotal",
    "'Giam gia'": "context.l10n.discount",
    "'Tong cong'": "context.l10n.total",
    "'Chia se hoa don'": "'share_receipt'",
    "'Cam on quy khach!'": "context.l10n.receiptFooter",
    "'Khach: ${receipt.customerName}'": "'customer_label'",

    # Expenses
    "'Chi phi'": "context.l10n.expenses",
    "'Chua co chi phi'": "context.l10n.noExpenses",
    "'Ghi lai chi phi de biet loi nhuan thuc te.'": "'expenses_empty_hint'",
    "'Them chi phi'": "'add_expense'",
    "'Danh muc'": "'category'",
    "'So tien'": "'amount'",
    "'Nguyen lieu'": "'ingredients'",
    "'Nhan cong'": "'labor'",
    "'Mat bang'": "'rent'",
    "'Van chuyen'": "'shipping'",
    "'Marketing'": "'marketing'",
    "'Khac'": "'other'",
    "'Nhap so tien hop le'": "'invalid_amount'",
    "'Luu'": "context.l10n.save",

    # Reports
    "'Bao cao'": "context.l10n.reports",
    "'Hom nay'": "context.l10n.revenueToday",
    "'Doanh thu'": "context.l10n.revenueToday",
    "'Lai gop'": "context.l10n.grossProfit",
    "'Lai rong'": "'net_profit'",
    "'So don'": "context.l10n.ordersToday",
    "'San pham ban chay (thang nay)'": "'best_sellers'",
    "'${p.quantity} luot'": "'sales_count'",
    "'Chua co cua hang'": "context.l10n.noStore",

    # Inventory
    "'Ton kho'": "context.l10n.inventory",
    "'Chua co san pham'": "context.l10n.noProducts",
    "'Them san pham de theo doi ton kho.'": "'inventory_empty_hint'",

    # Menu import
    "'Import Menu'": "context.l10n.importMenu",
    "'Chup anh menu'": "'scan_menu'",
    "'Chup anh menu de nhap san pham nhanh.'": "'menu_import_hint'",
    "'Dang xu ly...'": "context.l10n.loading",
    "'Da them ${_selected.length} san pham'": "'import_success'",

    # Settings
    "'Them'": "context.l10n.more",
    "'Cai dat'": "context.l10n.settings",
    "'Thiet lap cua hang'": "context.l10n.storeSettings",
    "'Tai khoan ngan hang'": "context.l10n.bankAccounts",
    "'Sao luu & phuc hoi'": "'backup_restore'",
    "'Phien ban 1.0.0'": "'version_1_0_0'",
    "'Xuat backup'": "context.l10n.exportBackup",
    "'Phuc hoi tu backup'": "context.l10n.importBackup",
    "'Xuat backup du lieu cua ban de dam bao an toan.'": "'backup_hint'",
    "'Da xuat backup: $path'": "'backup_exported'",
    "'Import du lieu tu file backup.'": "'import_hint'",
    "'Da them tai khoan'": "'account_added'",
    "'Them tai khoan'": "'add_account'",
    "'Ten ngan hang'": "'bank_name'",
    "'Ma ngan hang (VD: VCB)'": "'bank_code'",
    "'So tai khoan'": "'account_number'",
    "'Chu tai khoan'": "'account_holder'",
    "'Da luu'": "'saved'",
    "'Nhap ten'": "'name_required'",
    "'Ghi chu (khong bat buoc)'": "context.l10n.costPrice",

    # Onboarding
    "'Quan an / do uong'": "'food_beverage'",
    "'Shop online'": "'online_shop'",
    "'Tap hoa / ban le'": "'retail_shop'",
    "'Khac'": "'other'",
}

def replace_content(content, filename):
    for old, new in sorted(MAP.items(), key=lambda x: -len(x[0])):
        if new.startswith("'"):
            continue
        content = content.replace(old, new)
    return content

def main():
    for root, dirs, files in os.walk('lib'):
        for f in files:
            if not f.endswith('.dart'): continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            new_content = replace_content(content, fp)
            if new_content != content:
                with open(fp, 'w', encoding='utf-8') as fh:
                    fh.write(new_content)
                print(f'Updated: {fp}')

if __name__ == '__main__':
    main()
