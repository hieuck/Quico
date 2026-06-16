# 02_USER_STORIES.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả các hành vi mà Quico phải hỗ trợ.

Mục tiêu:

* Xác định nhu cầu thực tế của người dùng.
* Xác định phạm vi chức năng v1.
* Cung cấp acceptance criteria đủ rõ để developer triển khai mà không phải suy đoán.

---

# User Personas

## Persona A – Chủ quán ăn / đồ uống

Đặc điểm:

* Bận rộn trong giờ cao điểm.
* Thường thao tác bằng một tay.
* Không muốn nhập liệu nhiều.

Mục tiêu:

* Tạo đơn thật nhanh.
* Biết doanh thu hôm nay.
* Biết món nào bán chạy.

---

## Persona B – Chủ shop online

Đặc điểm:

* Nhận đơn qua Messenger/Zalo.
* Có nhiều khách quen.
* Theo dõi công nợ đơn giản.

Mục tiêu:

* Biến tin nhắn thành đơn hàng.
* Lưu lịch sử khách hàng.
* Theo dõi thanh toán.

---

## Persona C – Chủ tiệm bán lẻ

Đặc điểm:

* Có nhiều sản phẩm.
* Cần quản lý tồn kho.
* Cần cảnh báo sắp hết hàng.

Mục tiêu:

* Biết còn bao nhiêu hàng.
* Theo dõi doanh thu.
* Chia sẻ hóa đơn.

---

# Primary Journeys

## Journey 1 – Bắt đầu sử dụng Quico

Người dùng:

* Mở ứng dụng lần đầu.
* Nhập tên cửa hàng.
* Chọn loại hình kinh doanh.
* Hoàn tất onboarding.

Kết quả mong muốn:

* Có thể bắt đầu bán hàng ngay.

---

## Journey 2 – Tạo đơn thủ công

Người dùng:

* Chọn sản phẩm.
* Điều chỉnh số lượng.
* Chọn khách hàng (nếu có).
* Chọn phương thức thanh toán.
* Xác nhận.

Kết quả mong muốn:

* Đơn được lưu.
* Hóa đơn được tạo.
* Kho được cập nhật.

---

## Journey 3 – Tạo đơn bằng giọng nói

Người dùng:

* Bấm nút micro.
* Đọc đơn hàng.
* Kiểm tra kết quả.
* Chỉnh sửa nếu cần.
* Xác nhận.

Kết quả mong muốn:

* Đơn được tạo nhanh hơn nhập tay.

---

## Journey 4 – Tạo đơn từ ảnh tin nhắn

Người dùng:

* Chọn ảnh.
* Chờ OCR.
* Kiểm tra kết quả.
* Chỉnh sửa nếu cần.
* Xác nhận.

Kết quả mong muốn:

* Không cần nhập lại đơn.

---

## Journey 5 – Theo dõi kinh doanh

Người dùng:

* Mở báo cáo.
* Xem doanh thu.
* Xem lợi nhuận.
* Xem chi phí.
* Xem sản phẩm bán chạy.

Kết quả mong muốn:

* Biết tình hình kinh doanh ngay.

---

# User Stories

# ONBOARDING

US-001

As a new user,

I want to create my store quickly,

So that I can start selling immediately.

Acceptance Criteria:

* Store name is required.
* Currency defaults to VND.
* User can skip optional fields.
* Onboarding completes within 3 screens.

Priority:

Must.

---

# PRODUCTS

US-002

As a seller,

I want to add products,

So that I can sell them later.

Acceptance Criteria:

* Product name required.
* Sale price required.
* Cost price optional.
* Product image optional.

Priority:

Must.

---

US-003

As a seller,

I want to edit products,

So that information remains accurate.

Acceptance Criteria:

* Changes are saved locally.
* Existing orders remain unchanged.

Priority:

Must.

---

US-004

As a seller,

I want to deactivate products,

So that they are hidden from POS.

Acceptance Criteria:

* Product no longer appears in POS.
* Historical orders are preserved.

Priority:

Must.

---

# POS

US-005

As a seller,

I want to create orders manually,

So that I can sell products normally.

Acceptance Criteria:

* Product search available.
* Quantity editable.
* Discount supported.
* Payment method selectable.

Priority:

Must.

---

US-006

As a seller,

I want to save unpaid orders,

So that I can collect payment later.

Acceptance Criteria:

* Order status stored.
* Inventory rules respected.

Priority:

Must.

---

# VOICE ORDER

US-007

As a seller,

I want to create orders using voice,

So that I can work faster.

Acceptance Criteria:

* Speech converted to text.
* Parsed items displayed.
* Confirmation required before saving.

Priority:

Must.

---

US-008

As a seller,

I want to edit AI-generated orders,

So that incorrect recognition does not affect sales.

Acceptance Criteria:

* User can modify quantity.
* User can modify products.
* User can cancel.

Priority:

Must.

---

# TEXT ORDER

US-009

As a seller,

I want to paste text orders,

So that I can convert them into sales.

Acceptance Criteria:

* Parser extracts products.
* Parser extracts quantities.
* Confirmation required.

Priority:

Must.

---

# SCREENSHOT ORDER

US-010

As a seller,

I want to convert screenshots into orders,

So that I do not have to type them again.

Acceptance Criteria:

* OCR executed.
* Parser executed.
* Confirmation required.

Priority:

Must.

---

# CUSTOMERS

US-011

As a seller,

I want to save customer information,

So that I can track repeat buyers.

Acceptance Criteria:

* Customer name required.
* Phone optional.
* Purchase history displayed.

Priority:

Must.

---

# INVENTORY

US-012

As a seller,

I want stock levels updated automatically,

So that inventory remains accurate.

Acceptance Criteria:

* Inventory deducted after completed sale.
* Inventory restored on refund.

Priority:

Must.

---

US-013

As a seller,

I want low-stock warnings,

So that I can reorder products.

Acceptance Criteria:

* Warning threshold configurable.
* Dashboard indicator displayed.

Priority:

Should.

---

# EXPENSES

US-014

As a seller,

I want to record expenses,

So that I know my true profit.

Acceptance Criteria:

* Expense category required.
* Amount required.
* Included in reports.

Priority:

Must.

---

# REPORTS

US-015

As a seller,

I want daily revenue reports,

So that I know how much I sold.

Acceptance Criteria:

* Revenue displayed.
* Order count displayed.

Priority:

Must.

---

US-016

As a seller,

I want profit reports,

So that I know whether I am earning money.

Acceptance Criteria:

* Gross profit displayed.
* Net profit displayed.

Priority:

Must.

---

US-017

As a seller,

I want best-selling product reports,

So that I know customer preferences.

Acceptance Criteria:

* Top products ranked.
* Date filters supported.

Priority:

Should.

---

# RECEIPTS

US-018

As a seller,

I want to share receipts,

So that customers receive proof of purchase.

Acceptance Criteria:

* Export image supported.
* Export PDF supported.

Priority:

Must.

---

# BACKUP

US-019

As a seller,

I want to export my data,

So that I do not lose business information.

Acceptance Criteria:

* Export supported.
* Import supported.

Priority:

Must.

---

# Priority Matrix

Must:

* Onboarding
* Products
* Manual POS
* Voice Orders
* Text Orders
* Screenshot Orders
* Customers
* Inventory
* Expenses
* Reports
* Receipts
* Backup

Should:

* Low-stock warnings
* Best-selling reports
* Product image enhancements

Could:

* Loyalty programs
* Cloud sync
* Employee roles
* Barcode scanner

Won't (v1):

* Multi-branch management
* ERP features
* Payroll
* Accounting system

---

# Edge Cases

Voice recognition failure.

Expected behavior:

* User can retry.
* User can switch to manual mode.

---

OCR failure.

Expected behavior:

* User informed.
* Manual order creation available.

---

Unknown product detected.

Expected behavior:

* User selects existing product.
* User creates new product.

---

Order edited after payment.

Expected behavior:

* Inventory recalculated.
* Profit recalculated.

---

Application crashes unexpectedly.

Expected behavior:

* Completed transactions preserved.
* Draft recovery attempted.

---

Backup import schema mismatch.

Expected behavior:

* Import rejected.
* User informed.

---

# Story Completion Definition

A user story is complete only if:

* Functional requirements implemented.
* Acceptance criteria satisfied.
* Business rules respected.
* Tests added.
* No critical defects remain.
* Documentation updated if behavior changes.

END OF DOCUMENT
