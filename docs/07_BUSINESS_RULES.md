# 07_BUSINESS_RULES.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này định nghĩa toàn bộ quy tắc nghiệp vụ của Quico.

Mục tiêu:

* Đảm bảo app xử lý đơn hàng, tồn kho, doanh thu, chi phí và lợi nhuận chính xác.
* Giảm việc developer/agent phải tự suy đoán.
* Đảm bảo các tính năng AI không làm sai dữ liệu kinh doanh.
* Đảm bảo Quico dùng được thật trong hoạt động bán hàng hằng ngày.

---

# Business Scope

Quico v1 phục vụ:

* Quán ăn / đồ uống.
* Shop online.
* Tiệm tạp hóa / bán lẻ nhỏ.
* Hộ kinh doanh nhỏ.
* Người bán hàng cá nhân.

Quico v1 không phải:

* Hệ thống kế toán đầy đủ.
* ERP.
* Phần mềm quản lý chuỗi cửa hàng.
* Hệ thống bán hàng đa nhân viên phức tạp.
* Hệ thống thuế/hóa đơn điện tử chính thức.

---

# Global Business Principles

## 1. Data Integrity First

Dữ liệu bán hàng không được sai chỉ để UI chạy nhanh hơn.

Các dữ liệu quan trọng phải chính xác:

* Tổng tiền đơn hàng.
* Tồn kho.
* Doanh thu.
* Lợi nhuận.
* Chi phí.
* Trạng thái thanh toán.

---

## 2. Offline First

Mọi nghiệp vụ cốt lõi phải chạy offline:

* Thêm sản phẩm.
* Tạo đơn.
* Thanh toán.
* Lưu khách hàng.
* Trừ kho.
* Ghi chi phí.
* Xem báo cáo.
* Xuất hóa đơn.
* Sao lưu dữ liệu.

---

## 3. User Confirmation Required

Những hành động ảnh hưởng dữ liệu thật phải được người dùng xác nhận.

Bắt buộc xác nhận với:

* Hoàn tất đơn hàng.
* Hủy đơn.
* Hoàn đơn.
* Sửa đơn đã hoàn tất.
* Import sản phẩm từ ảnh menu.
* Import backup.
* Điều chỉnh tồn kho.
* Xóa/ngừng bán sản phẩm.

---

## 4. AI Never Writes Final Data Directly

AI chỉ được tạo dữ liệu nháp.

AI không được tự động:

* Hoàn tất đơn.
* Trừ kho.
* Ghi doanh thu.
* Tạo sản phẩm hàng loạt.
* Sửa sản phẩm.
* Ghi chi phí.
* Xóa dữ liệu.

Tất cả kết quả AI phải qua màn hình review.

---

## 5. Historical Data Must Be Preserved

Dữ liệu lịch sử không được thay đổi ngoài ý muốn.

Ví dụ:

* Nếu sản phẩm đổi tên, đơn hàng cũ vẫn giữ tên sản phẩm tại thời điểm bán.
* Nếu sản phẩm đổi giá, đơn hàng cũ vẫn giữ giá cũ.
* Nếu khách hàng bị xóa mềm, đơn hàng cũ vẫn giữ liên kết hoặc snapshot cần thiết.
* Nếu đơn đã hoàn tất, không được xóa cứng.

---

# Store Rules

## Store Creation

Người dùng phải tạo ít nhất một cửa hàng trước khi dùng app.

Required:

* Store name.

Optional:

* Business type.
* Phone.
* Address.
* Logo.

Default:

```txt
currency = VND
```

---

## Active Store

V1 chỉ cần hỗ trợ một cửa hàng hoạt động chính.

Database có thể hỗ trợ nhiều store để mở rộng sau, nhưng UI v1 không cần multi-store phức tạp.

---

## Store Name Rules

* Store name cannot be empty.
* Store name max length: 80 characters.
* Store name should be trimmed before saving.

---

# Product Rules

## Product Required Fields

A product must have:

* name
* sale_price

Optional:

* cost_price
* stock_quantity
* low_stock_threshold
* image_path
* sku
* barcode

---

## Product Name Rules

* Product name cannot be empty.
* Product name max length: 120 characters.
* Product name should be trimmed.
* Duplicate product names are allowed only with warning.

Reason:

Some shops may sell similar products with variants.

Example:

```txt
Trà sữa size M
Trà sữa size L
```

---

## Product Price Rules

All money values are integer VND.

Rules:

* `sale_price >= 0`
* `cost_price >= 0`
* `sale_price` can be 0 only if user intentionally creates free/custom item.
* `cost_price` defaults to 0 if unknown.

Do not use floating point money.

---

## Product Image Rules

* Product image is optional.
* Image is stored as local file.
* Database stores image path only.
* Missing image file must show placeholder.
* Product image must not block product creation.

---

## Product Status Rules

Product can be:

```txt
active
inactive
deleted_soft
```

Behavior:

* Active products appear in POS.
* Inactive products do not appear in POS by default.
* Soft-deleted products do not appear in normal lists.
* Historical orders must still display product snapshot.

---

## Product Deletion Rules

If product has order history:

* Do not hard delete.
* Soft delete or deactivate.

If product has no order history:

* Soft delete is still preferred.

Reason:

Keeping one deletion strategy reduces risk.

---

## Product Update Rules

When product is updated:

* Future orders use new product data.
* Historical order items remain unchanged.
* Updating sale price does not modify old orders.
* Updating cost price does not modify old profit calculations.

---

## Low Stock Rules

A product is low stock when:

```txt
stock_quantity <= low_stock_threshold
```

Default threshold:

```txt
5
```

Out of stock when:

```txt
stock_quantity <= 0
```

Dashboard should show low-stock count.

---

# Inventory Rules

## Inventory Source of Truth

Current stock is stored in:

```txt
products.stock_quantity
```

Stock history is stored in:

```txt
inventory_movements
```

Every stock-changing action must create an inventory movement.

---

## Inventory Movement Types

Allowed movement types:

```txt
initial
sale
refund
manual_adjustment
import
correction
```

---

## Initial Stock

When product is created with stock quantity > 0:

* Create an `initial` movement.
* `quantity_delta = initial stock`
* `quantity_after = initial stock`

If initial stock = 0:

* Movement is optional.

---

## Sale Deduction

Inventory is deducted when a sale is confirmed.

A sale is confirmed when:

* Order is completed as `paid`, or
* Order is saved as `unpaid` but marked as confirmed sale.

Draft orders do not affect stock.

---

## Negative Stock

Default v1 rule:

```txt
allow_negative_stock = true
```

Behavior:

* User can sell out-of-stock products.
* App must show warning.
* Sale can continue after user confirmation.

Reason:

Small sellers may sell first and update stock later.

---

## Cancel Order Inventory Rule

When a completed order is cancelled:

* Restore stock for each order item with product_id.
* Create `refund` movement.
* Mark order as cancelled.
* Do not delete order.

---

## Edit Completed Order Inventory Rule

When a completed order is edited:

* Calculate old inventory impact.
* Calculate new inventory impact.
* Apply difference as `correction` movements.
* Recalculate order total and profit.

This operation must run in a database transaction.

---

## Manual Stock Adjustment

User can manually adjust stock.

Allowed adjustment types:

```txt
increase
decrease
set_actual_quantity
```

Rules:

* Increase creates positive movement.
* Decrease creates negative movement.
* Set actual quantity creates delta based on current stock.
* Note is required for correction/set actual quantity.

---

# Customer Rules

## Customer Required Fields

A customer must have:

* name

Optional:

* phone
* note

---

## Customer Phone Rules

* Phone is optional.
* Vietnamese phone numbers should be accepted flexibly.
* Do not reject customer creation because phone format is unusual.
* Store normalized phone for search when possible.

---

## Customer Purchase History

Customer detail should show:

* total_orders
* total_spent
* recent_orders

These values should update when:

* Order is completed.
* Order is cancelled.
* Order customer is changed.
* Paid amount changes where relevant.

---

## Customer Deletion

If customer has orders:

* Soft delete only.

If customer has no orders:

* Soft delete is still preferred.

Historical orders must remain visible.

---

# Order Rules

## Order Sources

Allowed sources:

```txt
manual
voice
text
screenshot
```

Menu import creates products, not orders.

---

## Order Statuses

Allowed order statuses:

```txt
draft
unpaid
paid
cancelled
refunded
```

## Order Status State Machine

Only these status + payment_status combinations are valid:

| status     | payment_status | Valid | Notes                              |
|------------|----------------|-------|------------------------------------|
| draft      | unpaid         | ✅    | Temporary, no inventory impact     |
| unpaid     | unpaid         | ✅    | Confirmed sale, unpaid             |
| unpaid     | partial        | ✅    | Confirmed sale, partially paid     |
| paid       | paid           | ✅    | Completed sale                     |
| cancelled  | unpaid         | ✅    | Cancelled before payment           |
| cancelled  | partial        | ✅    | Cancelled after partial payment    |
| cancelled  | paid           | ✅    | Cancelled after full payment       |
| refunded   | paid           | ✅    | Refunded after full payment        |
| draft      | partial        | ❌    | Draft cannot have payment          |
| draft      | paid           | ❌    | Draft cannot be paid               |
| unpaid     | paid           | ❌    | Use status=paid instead            |
| paid       | unpaid         | ❌    | Paid order must have payment       |
| paid       | partial        | ❌    | Paid order must be fully paid      |
| refunded   | unpaid         | ❌    | Refund only valid after paid       |
| refunded   | partial        | ❌    | Refund only valid after paid       |

Draft orders must always have `payment_status = unpaid`.

When transitioning between states, the app must enforce:
- `draft → unpaid` (confirm sale, inventory deducted)
- `draft → cancelled` (no inventory effect)
- `unpaid → paid` (full payment received)
- `unpaid → cancelled` (inventory restored)
- `paid → cancelled` (inventory restored)
- `paid → refunded` (inventory restored if products returned)

Meaning:

## draft

* Temporary order.
* Not counted as revenue.
* Does not affect inventory.
* Can be deleted.
* payment_status must be unpaid.

## unpaid

* Confirmed sale.
* Customer has not fully paid.
* Counted as revenue if seller confirms sale.
* Affects inventory.
* payment_status may be unpaid or partial.

## paid

* Completed sale.
* Counted as revenue.
* Affects inventory.
* payment_status must be paid.

## cancelled

* Order is cancelled.
* Not counted as active revenue.
* Inventory restored if previously deducted.
* Kept for history.

## refunded

* Order was paid but refunded.
* Inventory restored if products returned.
* Kept for history.
* Only valid if previous status was paid.

---

# Payment Rules

## Payment Statuses

Allowed payment statuses:

```txt
unpaid
partial
paid
```

---

## Payment Methods

Allowed payment methods:

```txt
cash
bank_transfer
other
```

---

## Paid Order

An order is paid when:

```txt
payment_status = paid
paid_amount = total_amount
```

---

## Unpaid Order

An unpaid order has:

```txt
payment_status = unpaid
paid_amount = 0
```

But it can still be a confirmed sale if status is `unpaid`.

---

## Partial Payment

A partial payment has:

```txt
payment_status = partial
0 < paid_amount < total_amount
```

V1 can support partial status in database and UI, but advanced debt tracking can remain simple.

---

# Order Creation Rules

## Manual Order

Manual order flow:

1. User selects products.
2. User adjusts quantities.
3. User chooses payment status.
4. User confirms.
5. App saves order.
6. App updates inventory if confirmed sale.
7. App shows receipt.

---

## AI Order

AI order flow:

1. AI creates parsed draft.
2. User reviews items.
3. User fixes unknown/uncertain items.
4. User confirms.
5. App saves order.
6. App updates inventory if confirmed sale.
7. App shows receipt.

AI-generated order must not bypass review.

---

## Empty Order

Cannot complete order with no items.

Error message:

```txt
Đơn hàng chưa có sản phẩm.
```

---

## Invalid Quantity

Quantity must be greater than 0.

Error message:

```txt
Số lượng phải lớn hơn 0.
```

---

## Invalid Price

Unit price must be greater than or equal to 0.

Error message:

```txt
Giá bán không hợp lệ.
```

---

# Order Item Rules

## Snapshot Rule

Each order item must store:

* product_id if matched.
* product_name snapshot.
* quantity.
* unit_price snapshot.
* cost_price snapshot.
* line_total.
* line_profit.

Reason:

Historical orders must remain correct even if product changes later.

---

## Custom Item Rule

If item does not match an existing product, user can still sell it if:

* product_name is provided.
* unit_price is provided.
* quantity is valid.

Custom item:

* Does not affect inventory.
* Can appear on receipt.
* Can be quick-created as product if user chooses.

---

## Duplicate Item Rule

If the same product appears multiple times in one order:

Default behavior:

* Merge items if same product_id and same unit_price and same note.
* Keep separate if price or note differs.

Example:

```txt
2 trà đào ít đá
1 trà đào nhiều đá
```

should remain separate due to different notes.

---

# Order Calculation Rules

## Line Total

```txt
line_total = quantity * unit_price - discount_amount
```

Rules:

* `line_total >= 0`
* `discount_amount >= 0`
* Line discount cannot exceed `quantity * unit_price`

---

## Line Profit

```txt
line_profit = line_total - (quantity * cost_price)
```

Line profit can be negative.

---

## Subtotal

```txt
subtotal = sum(quantity * unit_price)
```

Subtotal is before order-level discount.

---

## Order Total

```txt
total_amount = subtotal - order_discount_amount
```

Rules:

* `total_amount >= 0`
* Order discount cannot exceed subtotal.

---

## Cost Amount

```txt
cost_amount = sum(quantity * cost_price)
```

---

## Gross Profit

```txt
gross_profit = total_amount - cost_amount
```

Gross profit can be negative.

---

## Net Profit

Net profit is calculated in reports:

```txt
net_profit = gross_profit - expenses
```

Expenses are not attached to individual orders in v1.

---

# Discount Rules

V1 supports amount-based discount.

Discount can exist at:

* order level
* line item level

If both exist:

```txt
line discounts are applied first
order discount is applied after subtotal
```

V1 can prioritize order-level discount in UI for simplicity.

Percentage discount can be future feature.

---

# Tax Rules

V1 does not support official tax calculation.

No VAT handling required in v1.

Receipt is a sales receipt, not official tax invoice.

---

# Receipt Rules

Receipt must be generated from saved order data.

Receipt must include:

* Store name.
* Order code.
* Date/time.
* Customer name if available.
* Items.
* Quantity.
* Unit price.
* Line total.
* Discount if any.
* Total amount.
* Payment status.
* Payment method.
* Note if any.

Receipt can be:

* displayed in app.
* exported as image.
* exported as PDF.
* shared through native share sheet.

---

# Receipt Number / Order Code Rules

Order code format:

```txt
DH000001
DH000002
DH000003
```

Rules:

* Unique per store.
* Human-readable.
* Generated when order is saved as confirmed sale.
* Draft orders may have temporary ID but do not need final order code.

---

# Report Rules

## Revenue

Revenue includes:

* paid orders.
* unpaid confirmed sales.
* partial orders based on total sale amount, not only paid amount, unless report explicitly says cash collected.

Revenue excludes:

* draft orders.
* cancelled orders.
* refunded orders.

---

## Cash Collected

Cash collected is based on:

```txt
paid_amount
```

This is different from revenue.

V1 dashboard may show revenue by default.

Future reports can distinguish:

* Revenue.
* Cash collected.
* Unpaid amount.

---

## Gross Profit

Gross profit:

```txt
sum(order.gross_profit)
```

Include:

* paid orders.
* unpaid confirmed sales.
* partial confirmed sales.

Exclude:

* draft.
* cancelled.
* refunded.

---

## Expenses

Expenses are included by `spent_at` date.

Soft-deleted expenses are excluded.

---

## Net Profit

```txt
net_profit = gross_profit - total_expenses
```

---

## Best-Selling Products

Rank by:

```txt
sum(order_items.quantity)
```

Include only:

* paid orders.
* unpaid confirmed sales.
* partial confirmed sales.

Exclude:

* draft.
* cancelled.
* refunded.

---

## Low Stock Report

A product is low stock when:

```txt
stock_quantity <= low_stock_threshold
```

Only include:

* active products.
* non-deleted products.

---

# AI Business Rules

## Voice-to-Order

Voice input must produce a draft order.

Rules:

* Speech result must be shown.
* User can edit recognized text.
* Parsed items must be reviewed.
* Uncertain products must be confirmed.
* Unknown products must be selected, created, or given a price before completion.

---

## Text-to-Order

Text input must produce a draft order.

Rules:

* Parser must not silently drop unclear text.
* Unclear parts should become warnings or notes.
* Missing price is allowed only if product is matched and has sale price.
* Unknown item without price blocks completion.

---

## Screenshot-to-Order

OCR result must be editable before final parsing or before final confirmation.

Rules:

* OCR errors must not directly create final orders.
* User must see extracted text.
* User must confirm parsed items.

---

## Menu Image Import

Menu import creates product drafts, not final products.

Rules:

* No product saved without review.
* Duplicate products must be marked.
* Default duplicate behavior is skip.
* User can edit name and price before saving.

---

## Product Matching

Confidence rules:

```txt
exact/high    -> can proceed
medium        -> requires user confirmation
low/unknown   -> requires select/create product or enter price
```

---

# Backup Rules

## Export Backup

User can export:

* JSON backup.
* SQLite database file.

Export should include:

* stores
* products
* customers
* orders
* order_items
* inventory_movements
* expenses
* bank_accounts
* settings

---

## Import Backup

Import must:

* Validate schema.
* Warn user.
* Run inside transaction.
* Rollback if failure occurs.

Import must not silently overwrite data.

User must explicitly confirm.

---

# Permission Rules

Permissions must be requested contextually.

Do not ask all permissions on first launch.

## Microphone

Ask when user uses voice order.

If denied:

* Offer text order.
* Offer manual order.

## Speech Recognition

Ask when user uses voice order.

If denied:

* Offer text order.
* Offer manual order.

## Camera

Ask when user takes product/menu/screenshot photo.

If denied:

* Offer photo picker if available.
* Offer manual entry.

## Photos

Ask when user chooses image.

If denied:

* Offer manual entry.

---

# Validation Rules

## Product Validation

Required:

* name
* sale_price

Rules:

* name cannot be empty.
* sale_price >= 0.
* cost_price >= 0.
* stock_quantity can be negative only if policy allows.
* low_stock_threshold >= 0.

---

## Customer Validation

Required:

* name

Rules:

* phone optional.
* note optional.

---

## Order Validation

Before completing order:

* order has at least one item.
* all quantities > 0.
* all unit prices >= 0.
* total_amount >= 0.
* no blocking AI warnings.
* unknown items have either selected product or manual name + price.

---

## Expense Validation

Required:

* category
* amount
* spent_at

Rules:

* amount > 0.
* category cannot be empty.

---

## Bank Account Validation

Required:

* bank_code
* bank_name
* account_number
* account_name

Rules:

* only one default bank account per store.

---

# Deletion and Cancellation Rules

## Draft Order

Draft order may be deleted.

No inventory effect.

---

## Completed Order

Completed order must not be hard deleted.

Allowed actions:

* cancel.
* refund.
* edit with correction.

---

## Product

Use soft delete/deactivate.

---

## Customer

Use soft delete.

---

## Expense

Use soft delete.

---

# Error Handling Rules

Errors must be shown in plain Vietnamese.

Do not show raw stack trace.

Examples:

## Save Product Failed

```txt
Không thể lưu sản phẩm. Vui lòng thử lại.
```

## Complete Order Failed

```txt
Không thể hoàn tất đơn hàng. Vui lòng kiểm tra lại và thử lại.
```

## Inventory Failed

```txt
Không thể cập nhật tồn kho. Đơn hàng chưa được lưu.
```

## Backup Failed

```txt
Không thể sao lưu dữ liệu. Vui lòng thử lại.
```

## Import Failed

```txt
Không thể khôi phục dữ liệu từ file này.
```

---

# Transaction Rules

The following operations must be atomic:

* Complete order.
* Save confirmed unpaid order.
* Cancel order.
* Refund order.
* Edit completed order.
* Manual stock adjustment.
* Menu product import.
* Backup import.

If any part fails, rollback all changes.

---

# Data Consistency Rules

The app must preserve these invariants:

## Order Invariant

```txt
order.total_amount = order.subtotal - order.discount_amount
```

## Profit Invariant

```txt
order.gross_profit = order.total_amount - order.cost_amount
```

## Item Invariant

```txt
item.line_total = quantity * unit_price - discount_amount
```

## Stock Invariant

Product stock should equal:

```txt
initial stock + sum(inventory_movements.quantity_delta)
```

If mismatch is detected, app should provide correction path later.

---

# Offline Rules

When offline:

Allowed:

* Create product.
* Create order.
* Create customer.
* Record expense.
* Adjust inventory.
* Export receipt.
* Export backup.
* View reports.

Not required:

* Cloud sync.
* Remote AI.
* App Store services.

---

# Future Sync Rules

Cloud sync is not required in v1.

If implemented later:

* Local database remains source of truth during offline use.
* Sync conflicts must not silently overwrite local sales data.
* Each entity should have updated_at and future sync metadata.
* Conflict resolution must be documented before implementation.

---

# Business Rule Test Requirements

Tests must verify:

* Completing order deducts inventory.
* Draft order does not deduct inventory.
* Cancelling order restores inventory.
* Editing completed order creates correction.
* Product rename does not change old order item.
* Product price change does not change old order item.
* Revenue excludes cancelled orders.
* Gross profit uses cost snapshot.
* Expenses affect net profit.
* Unknown AI product blocks completion if no price.
* Medium confidence AI match requires confirmation.
* Backup import rolls back on invalid data.

---

# Final Acceptance Criteria

Business rules are correctly implemented only when:

* Manual order flow follows all order rules.
* AI order flow follows all review rules.
* Inventory movements are always recorded.
* Reports match saved order/expense data.
* Historical order data is preserved.
* Completed orders are not hard deleted.
* Money values are integer VND.
* Critical operations use database transactions.
* Error handling is user-friendly.
* Tests cover critical business rules.

END OF DOCUMENT
