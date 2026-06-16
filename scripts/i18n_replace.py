#!/usr/bin/env python3
"""Replace hardcoded UI strings with AppLocalizations calls."""

import re
import os
import sys

# Mapping: Vietnamese/English hardcoded string -> localization key
STRINGS = {
    # Navigation & Tabs
    "'Trang chủ'": "context.l10n.home",
    "'Đơn hàng'": "context.l10n.orders",
    "'Sản phẩm'": "context.l10n.products",
    "'Báo cáo'": "context.l10n.reports",
    "'Thêm'": "context.l10n.more",
    "'Tạo đơn hàng'": "context.l10n.newOrder",
    "'Tạo đơn'": "context.l10n.manualOrder",
    "'Nói đơn'": "context.l10n.voiceOrder",
    "'Nhập text'": "context.l10n.textOrder",
    "'Ảnh tin nhắn'": "context.l10n.screenshotOrder",
    "'Chọn sản phẩm thủ công'": "context.l10n.selectProducts",
    "'Tạo đơn bằng giọng nói'": "context.l10n.orderByVoice",
    "'Dán nội dung đơn hàng'": "context.l10n.pasteOrder",
    "'Chụp màn hình tin nhắn'": "context.l10n.chatScreenshot",

    # Onboarding
    "'Quico'": "context.l10n.appName",
    "'Bán hàng dễ như nhắn tin.'": "context.l10n.tagline",
    "'Quản lý đơn hàng, sản phẩm, doanh thu và tồn kho ngay trên điện thoại.'": "context.l10n.appDescription",
    "'Bắt đầu'": "context.l10n.start",
    "'Tạo cửa hàng'": "context.l10n.createStore",
    "'Thông tin cửa hàng'": "context.l10n.storeInfo",
    "'Tên cửa hàng'": "context.l10n.storeName",
    "'Loại hình kinh doanh (không bắt buộc)'": "context.l10n.businessTypeOptional",
    "'Đơn vị tiền: VND'": "context.l10n.currencyVND",
    "'Cửa hàng đã sẵn sàng!'": "context.l10n.storeReady",

    # Home
    "'Sẵn sàng bán hàng'": "context.l10n.readyToSell",
    "'Doanh thu hôm nay'": "context.l10n.revenueToday",
    "'Số đơn'": "context.l10n.ordersToday",
    "'Lãi gộp'": "context.l10n.grossProfit",
    "'Tạo nhanh'": "context.l10n.quickActions",
    "'Sản phẩm sắp hết hàng'": "context.l10n.lowStock",
    "'Đơn gần đây'": "context.l10n.recentOrders",
    "'Chưa có sản phẩm nào.'": "context.l10n.noProductsYet",
    "'Chưa có đơn hàng nào.'": "context.l10n.noOrdersYet",
    "'Chưa có cửa hàng'": "context.l10n.noStore",

    # Products
    "'Sản phẩm'": "context.l10n.products",
    "'Thêm sản phẩm'": "context.l10n.addProduct",
    "'Tên sản phẩm'": "context.l10n.productName",
    "'Giá bán'": "context.l10n.salePrice",
    "'Giá vốn'": "context.l10n.costPrice",
    "'Tồn kho'": "context.l10n.stockQuantity",
    "'Cảnh báo tồn kho tối thiểu'": "context.l10n.lowStockThreshold",
    "'Mã SKU (không bắt buộc)'": "context.l10n.skuOptional",
    "'Thêm ảnh'": "context.l10n.addPhoto",
    "'Lưu'": "context.l10n.save",
    "'Sửa'": "context.l10n.edit",
    "'Ngừng bán'": "context.l10n.deactivate",

    # Orders
    "'Hoàn tất đơn'": "context.l10n.completeOrder",
    "'Tổng cộng'": "context.l10n.total",
    "'Tạm tính'": "context.l10n.subtotal",
    "'Giảm giá'": "context.l10n.discount",
    "'Xác nhận'": "context.l10n.confirm",
    "'Hủy'": "context.l10n.cancel",
    "'Xóa'": "context.l10n.delete",
    "'Trạng thái'": "context.l10n.paymentStatus",
    "'Phương thức'": "context.l10n.paymentMethod",
    "'Đã thanh toán'": "context.l10n.paid",
    "'Chưa thanh toán'": "context.l10n.unpaid",
    "'Thanh toán một phần'": "context.l10n.partial",
    "'Tiền mặt'": "context.l10n.cash",
    "'Chuyển khoản'": "context.l10n.bankTransfer",
    "'Hủy đơn'": "context.l10n.cancelOrder",
    "'Đã hủy'": "context.l10n.cancelled",
    "'Đã hoàn'": "context.l10n.refunded",
    "'Nháp'": "context.l10n.draft",

    # AI Order
    "'AI Order'": "context.l10n.aiOrder",
    "'Giọng nói'": "context.l10n.voice",
    "'Văn bản'": "context.l10n.text",
    "'Ảnh tin nhắn'": "context.l10n.screenshots",
    "'Kiểm tra đơn hàng'": "context.l10n.orderReview",
    "'Đã khớp'": "context.l10n.matched",
    "'Cần kiểm tra'": "context.l10n.needsReview",
    "'Sản phẩm mới'": "context.l10n.newProduct",
    "'Chọn ảnh'": "context.l10n.photoLibrary",
    "'Chụp ảnh'": "context.l10n.takePhoto",

    # Expenses
    "'Chi phí'": "context.l10n.expenses",
    "'Thêm chi phí'": "'expense' context (skip)",

    # Settings
    "'Cài đặt'": "context.l10n.settings",
    "'Thiết lập cửa hàng'": "context.l10n.storeSettings",
    "'Tài khoản ngân hàng'": "context.l10n.bankAccounts",
    "'Tồn kho'": "context.l10n.inventory",
    "'Hóa đơn'": "context.l10n.receipt",
    "'Export'": "'export' context (skip)",

    # Common
    "'Không có dữ liệu'": "context.l10n.noData",
    "'Lỗi'": "context.l10n.error",
    "'Đang tải...'": "context.l10n.loading",
    "'Thử lại'": "context.l10n.retry",
    "'Xác nhận đơn?'": "context.l10n.confirmOrder",
    "'Xác nhận hoàn tất đơn hàng này?'": "context.l10n.confirmOrderBody",
    "'Hủy đơn?'": "context.l10n.cancelOrderConfirm",
    "'Tồn kho sẽ được hoàn lại.'": "context.l10n.cancelOrderBody",
    "'Đơn hàng đã tạo!'": "context.l10n.orderCreated",
    "'Không thể tạo đơn hàng'": "context.l10n.orderFailed",
    "'Không thể lưu'": "context.l10n.saveFailed",
    "'Chưa có sản phẩm'": "context.l10n.noProducts",
    "'Chưa có khách hàng'": "context.l10n.noCustomers",
    "'Chưa có chi phí'": "context.l10n.noExpenses",
    "'Không tìm thấy'": "context.l10n.error",
    "'Cảm ơn quý khách!'": "context.l10n.receiptFooter",
    "'Phiên bản'": "context.l10n.version",
}

def replace_in_file(filepath):
    with open(filepath, encoding='utf-8') as f:
        content = f.read()

    modified = False
    # Sort by length (longest first) to avoid partial replacements
    for old, new in sorted(STRINGS.items(), key=lambda x: -len(x[0])):
        if new == "'expense' context (skip)" or new == "'export' context (skip)":
            continue
        if old in content:
            content = content.replace(old, new)
            modified = True

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False


def main():
    dart_files = []
    for root, dirs, files in os.walk('lib'):
        dirs[:] = [d for d in dirs if d not in ('.dart_tool', 'build', '.pub')]
        for f in files:
            if f.endswith('.dart'):
                dart_files.append(os.path.join(root, f))

    count = 0
    for fp in dart_files:
        if replace_in_file(fp):
            count += 1

    print(f"Updated {count} files with localized strings.")


if __name__ == '__main__':
    main()
