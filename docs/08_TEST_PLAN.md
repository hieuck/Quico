# 08_TEST_PLAN.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này định nghĩa kế hoạch kiểm thử cho Quico.

Mục tiêu:

* Đảm bảo Quico không chỉ build được mà còn dùng được thật.
* Đảm bảo các nghiệp vụ bán hàng, tồn kho, doanh thu, lợi nhuận và AI order hoạt động chính xác.
* Ngăn agent/developer xóa test hoặc bỏ qua lỗi để build cho xong.
* Cung cấp test scope đủ rõ để triển khai trong Flutter.

---

# Testing Philosophy

Quico là app quản lý bán hàng. Vì vậy test phải ưu tiên:

1. Độ đúng của dữ liệu.
2. Tính ổn định của flow bán hàng.
3. Không mất dữ liệu.
4. Hoạt động offline.
5. Build iOS không vỡ.
6. AI không tự ghi sai dữ liệu.

UI đẹp nhưng dữ liệu sai là thất bại.

---

# Test Pyramid

Quico sử dụng test pyramid như sau:

```txt
Unit Tests
  ↑ nhiều nhất

Repository / Database Tests
  ↑ nhiều

Parser / AI Logic Tests
  ↑ nhiều

Widget Tests
  ↑ vừa đủ

Integration / Smoke Tests
  ↑ ít nhưng bắt buộc

Manual QA Checklist
  ↑ bắt buộc trước release
```

Ưu tiên cao nhất:

* Business logic tests.
* Order calculation tests.
* Inventory tests.
* AI parser tests.
* Database transaction tests.

---

# Required Test Commands

Developer must ensure the following commands pass:

```bash
flutter analyze
flutter test
dart format --set-exit-if-changed .
```

Optional but recommended:

```bash
flutter test --coverage
```

For iOS build validation:

```bash
flutter build ios --release --no-codesign
```

Signed IPA build is covered in:

```txt
09_RELEASE_PLAN.md
10_IOS_SIGNING.md
```

---

# Test Directory Structure

Required structure:

```txt
test/
  core/
    utils/
      currency_formatter_test.dart
      date_range_test.dart
      text_normalizer_test.dart
      validators_test.dart

    ai/
      parser/
        order_text_parser_test.dart
        menu_text_parser_test.dart
      matching/
        product_matching_service_test.dart

    receipt/
      receipt_data_test.dart

  features/
    onboarding/
      onboarding_flow_test.dart

    products/
      product_repository_test.dart
      product_use_cases_test.dart
      product_validation_test.dart

    customers/
      customer_repository_test.dart
      customer_stats_test.dart

    orders/
      order_calculation_service_test.dart
      complete_order_use_case_test.dart
      cancel_order_use_case_test.dart
      edit_completed_order_test.dart
      order_repository_test.dart

    inventory/
      inventory_service_test.dart
      inventory_movement_test.dart

    expenses/
      expense_repository_test.dart
      expense_validation_test.dart

    reports/
      dashboard_summary_test.dart
      revenue_report_test.dart
      profit_report_test.dart
      best_selling_products_test.dart

    ai_order/
      voice_order_flow_test.dart
      text_order_flow_test.dart
      screenshot_order_flow_test.dart
      ai_order_review_test.dart

    backup/
      backup_export_test.dart
      backup_import_test.dart
      backup_validator_test.dart

  widget/
    home_screen_test.dart
    pos_screen_test.dart
    ai_order_review_screen_test.dart
    product_form_test.dart
    receipt_screen_test.dart

  integration/
    app_smoke_test.dart
```

If the developer uses a slightly different structure, the same coverage must still exist.

---

# Test Data Rules

Test data must be deterministic.

Do not rely on:

* Current random time without injection.
* Real network.
* Real cloud account.
* Real Apple signing credentials.
* Real user photos.
* Real microphone input.
* Real OCR result.

Use mocks/fakes for:

* SpeechToTextService.
* OcrService.
* Image picker.
* File storage.
* Permission service.
* Current clock.
* ID generator.

---

# Required Fakes

The test suite must include fake implementations for external/platform services.

## FakeSpeechToTextService

Used for voice-to-order tests.

Example behavior:

```dart
FakeSpeechToTextService(text: '2 cà phê sữa 30k');
```

Must return deterministic transcription.

---

## FakeOcrService

Used for screenshot/menu import tests.

Example behavior:

```dart
FakeOcrService(text: '2 trà đào\n1 bánh mì thịt');
```

Must return deterministic OCR text.

---

## FakePermissionService

Used for permission tests.

Must support:

* granted.
* denied.
* permanently denied if needed.

---

## FakeImageStorageService

Used for product image tests.

Must simulate:

* successful image copy.
* missing image file.
* file copy failure.

---

## FakeClock

Used for date-sensitive tests.

Must make reports deterministic.

Example:

```txt
Now = 2026-06-16 10:00:00 local time
```

---

## FakeIdGenerator

Used for predictable IDs.

Example:

```txt
product-1
order-1
customer-1
```

---

# Unit Test Scope

Unit tests must cover pure business logic.

Unit tests must not require:

* Flutter widget tree.
* Real SQLite unless explicitly testing repository/database.
* Network.
* iOS simulator.
* Device permissions.

---

# Core Utility Tests

## CurrencyFormatter

Must test:

```txt
0 -> 0đ
1000 -> 1.000đ
35000 -> 35.000đ
1250000 -> 1.250.000đ
```

Must reject or handle:

```txt
negative values where not allowed
large values
```

---

## TextNormalizer

Must test:

```txt
"Cà phê sữa đá" -> "ca phe sua da"
"  Trà   Đào  " -> "tra dao"
"Cà-phê_sữa!" -> "ca phe sua"
"CF sữa" -> normalized with abbreviation support where appropriate
```

---

## DateRange

Must test:

* Today range.
* This week range.
* This month range.
* Custom range.
* Start inclusive, end exclusive.
* Week starts Monday.
* Local timezone behavior.

---

## Validators

Must test:

* Product name required.
* Sale price >= 0.
* Cost price >= 0.
* Quantity > 0.
* Expense amount > 0.
* Store name required.
* Customer name required.
* Bank account required fields.

---

# Product Tests

## Create Product

Test cases:

* Create product with required fields.
* Create product with optional SKU.
* Create product with image path.
* Create product with initial stock.
* Create product with cost price.
* Create product with low stock threshold.

Expected:

* Product saved.
* Normalized name generated.
* Initial inventory movement created if initial stock > 0.
* Product appears in active product list.

---

## Product Validation

Test cases:

* Empty name fails.
* Negative sale price fails.
* Negative cost price fails.
* Negative low stock threshold fails.
* Duplicate product name warns but does not necessarily block.

---

## Update Product

Test cases:

* Update name.
* Update sale price.
* Update cost price.
* Update image path.
* Update stock threshold.

Expected:

* Product updated.
* Historical order items remain unchanged.

---

## Product Deactivate / Soft Delete

Test cases:

* Deactivate product.
* Soft delete product.
* Product with historical order is not hard deleted.

Expected:

* Product hidden from POS.
* Product historical order items still display snapshot.

---

## Product Search

Test cases:

```txt
Cà phê sữa
ca phe sua
cafe sua
cf sua
Trà đào
tra dao
```

Expected:

* Search finds normalized Vietnamese names.
* Deleted products excluded.
* Inactive products excluded from POS by default.

---

## Low Stock

Test cases:

```txt
stock_quantity = 5
low_stock_threshold = 5
```

Expected:

* Product is low stock.

```txt
stock_quantity = 6
low_stock_threshold = 5
```

Expected:

* Product is not low stock.

---

# Customer Tests

## Create Customer

Test cases:

* Create customer with name only.
* Create customer with phone.
* Create customer with note.

Expected:

* Customer saved.
* Phone normalized when available.

---

## Customer Validation

Test cases:

* Empty name fails.
* Phone unusual format does not block creation unless invalid beyond usability.

---

## Customer Search

Must search by:

* name.
* phone.
* normalized phone.

---

## Customer Stats

Test cases:

* Complete order with customer updates total_orders and total_spent.
* Cancel order recalculates total_orders and total_spent.
* Changing customer on order recalculates both old and new customers.

---

# Order Calculation Tests

Order calculation is critical.

## Line Total

Input:

```txt
quantity = 2
unit_price = 30000
discount_amount = 5000
```

Expected:

```txt
line_total = 55000
```

---

## Line Profit

Input:

```txt
quantity = 2
unit_price = 30000
cost_price = 12000
discount_amount = 0
```

Expected:

```txt
line_total = 60000
line_profit = 36000
```

---

## Order Subtotal

Input:

```txt
2 x 30000
1 x 35000
```

Expected:

```txt
subtotal = 95000
```

---

## Order Total

Input:

```txt
subtotal = 95000
order_discount = 5000
```

Expected:

```txt
total_amount = 90000
```

---

## Cost Amount

Input:

```txt
2 x cost 12000
1 x cost 15000
```

Expected:

```txt
cost_amount = 39000
```

---

## Gross Profit

Input:

```txt
total_amount = 90000
cost_amount = 39000
```

Expected:

```txt
gross_profit = 51000
```

---

## Invalid Discount

Test cases:

* Line discount greater than line subtotal fails.
* Order discount greater than subtotal fails.

---

# Order Lifecycle Tests

## Draft Order

Test cases:

* Create draft order.
* Draft order has no inventory impact.
* Draft order not counted in revenue.
* Draft order can be deleted.

---

## Complete Paid Order

Test cases:

* Complete order with one product.
* Complete order with multiple products.
* Complete order with customer.
* Complete order with discount.
* Complete order from manual source.
* Complete order from voice source.
* Complete order from text source.
* Complete order from screenshot source.

Expected:

* Order status = paid.
* Payment status = paid.
* Paid amount = total amount.
* Inventory deducted.
* Inventory movement created.
* Revenue updated.
* Receipt can be generated.

---

## Save Unpaid Confirmed Sale

Test cases:

* Save order as unpaid.
* Inventory is deducted because sale is confirmed.
* Revenue includes unpaid confirmed sale.
* Cash collected does not include unpaid amount.

Expected:

* Order status = unpaid.
* Payment status = unpaid.
* Paid amount = 0.
* Inventory deducted.

---

## Partial Payment

Test cases:

* Save partial paid order.
* Paid amount > 0.
* Paid amount < total amount.

Expected:

* Payment status = partial.
* Revenue includes total amount.
* Cash collected includes paid_amount.
* Inventory deducted.

---

## Cancel Order

Test cases:

* Cancel paid order.
* Cancel unpaid confirmed sale.
* Cancel order with multiple items.

Expected:

* Order status = cancelled.
* Inventory restored.
* Refund inventory movements created.
* Revenue excludes cancelled order.
* Customer stats recalculated.

---

## Refund Order

Test cases:

* Refund paid order.
* Refund restores inventory.
* Refunded order excluded from active revenue.

Expected:

* Order status = refunded.
* Inventory restored as appropriate.
* Historical data preserved.

---

## Edit Completed Order

Test cases:

* Edit quantity.
* Add item.
* Remove item.
* Change unit price.
* Change discount.

Expected:

* Totals recalculated.
* Inventory correction movements created.
* Profit recalculated.
* Customer stats recalculated.
* Transaction rollback if any step fails.

---

## Product Snapshot

Test cases:

1. Create product named `Cà phê sữa`, price 30000.
2. Complete order.
3. Rename product to `Cà phê sữa đá`, price 35000.
4. View old order.

Expected:

* Old order item still shows `Cà phê sữa`.
* Old order item still shows 30000.

---

# Inventory Tests

## Initial Stock Movement

Test:

* Create product with stock 10.

Expected:

* Product stock = 10.
* Initial movement exists with quantity_delta = 10.

---

## Sale Movement

Test:

* Product stock = 10.
* Sell quantity 2.

Expected:

* Product stock = 8.
* Movement type = sale.
* quantity_delta = -2.
* quantity_after = 8.

---

## Refund Movement

Test:

* Product stock = 8.
* Cancel order that sold quantity 2.

Expected:

* Product stock = 10.
* Movement type = refund.
* quantity_delta = 2.
* quantity_after = 10.

---

## Manual Increase

Test:

* Product stock = 5.
* Increase by 10.

Expected:

* Product stock = 15.
* Movement type = import or manual_adjustment.
* quantity_delta = 10.

---

## Manual Decrease

Test:

* Product stock = 10.
* Decrease by 3.

Expected:

* Product stock = 7.
* Movement type = manual_adjustment.
* quantity_delta = -3.

---

## Set Actual Quantity

Test:

* Product stock = 10.
* Set actual quantity = 6.

Expected:

* quantity_delta = -4.
* quantity_after = 6.
* Movement type = correction.
* Note required.

---

## Negative Stock Allowed

Default:

```txt
allow_negative_stock = true
```

Test:

* Product stock = 0.
* Sell quantity 2.

Expected:

* Warning shown.
* Sale can proceed after confirmation.
* Product stock = -2.

---

## Negative Stock Disabled

If setting disabled:

* Product stock = 0.
* Sell quantity 2.

Expected:

* Sale blocked unless stock adjusted.

---

# Expense Tests

## Create Expense

Test cases:

* Create expense with category.
* Create expense with note.
* Create expense with custom date.

Expected:

* Expense saved.
* Reports include expense.

---

## Expense Validation

Test cases:

* Empty category fails.
* Amount <= 0 fails.

---

## Soft Delete Expense

Expected:

* Expense hidden from normal list.
* Expense excluded from reports.

---

## Sum Expenses

Test cases:

* Today.
* This week.
* This month.
* Custom range.

Expected:

* Only expenses in date range counted.
* Deleted expenses excluded.

---

# Report Tests

Reports must not hallucinate or estimate data.

All reports must be based on saved local database data.

---

## Dashboard Summary

Must test:

* Revenue today.
* Order count today.
* Gross profit today.
* Low stock count.
* Recent orders.

---

## Revenue Report

Test cases:

* Paid order included.
* Unpaid confirmed sale included.
* Partial order included by total amount.
* Draft excluded.
* Cancelled excluded.
* Refunded excluded.

---

## Cash Collected Report

Test cases:

* Paid order contributes total amount.
* Unpaid order contributes 0.
* Partial order contributes paid_amount.

---

## Gross Profit Report

Test cases:

* Gross profit calculated from saved order.gross_profit.
* Cancelled/refunded excluded.
* Draft excluded.

---

## Net Profit Report

Input:

```txt
gross_profit = 500000
expenses = 200000
```

Expected:

```txt
net_profit = 300000
```

---

## Best-Selling Products

Test cases:

* Product quantity summed across valid orders.
* Cancelled orders excluded.
* Refunded orders excluded.
* Custom items without product_id handled separately or excluded depending implementation.

Expected:

* Products ranked by sold quantity.

---

## Top Customers

Test cases:

* Customer total spent.
* Customer order count.
* Cancelled orders excluded.

---

# AI Parser Tests

AI parser tests are mandatory because Quico requires voice/text/screenshot order in v1.

---

## Basic Quantity Parsing

Input:

```txt
2 cà phê sữa
```

Expected:

```txt
quantity = 2
raw_name = cà phê sữa
```

---

## Vietnamese Number Parsing

Input:

```txt
hai cà phê sữa
```

Expected:

```txt
quantity = 2
```

Input:

```txt
ba trà đào
```

Expected:

```txt
quantity = 3
```

---

## Price With K

Input:

```txt
2 trà đào 35k
```

Expected:

```txt
quantity = 2
unit_price = 35000
raw_name = trà đào
```

---

## Price With Nghìn

Input:

```txt
1 bánh mì 20 nghìn
```

Expected:

```txt
unit_price = 20000
```

---

## Price With Ngàn

Input:

```txt
1 nước cam 25 ngàn
```

Expected:

```txt
unit_price = 25000
```

---

## Full Number Price

Input:

```txt
1 trà sữa 35000
```

Expected:

```txt
unit_price = 35000
```

---

## Multiple Items

Input:

```txt
2 cà phê sữa, 1 trà đào
```

Expected:

* 2 items.
* Item 1 quantity = 2.
* Item 2 quantity = 1.

---

## Plus Separator

Input:

```txt
2 cà phê sữa + 1 trà đào
```

Expected:

* 2 items.

---

## And Separator

Input:

```txt
2 cà phê sữa và 1 trà đào
```

Expected:

* 2 items.

---

## Customer Hint

Input:

```txt
bán cho chị Lan 2 trà đào
```

Expected:

```txt
customer_hint = chị Lan
```

---

## Item Note

Input:

```txt
1 cà phê sữa ít đường
```

Expected:

* Item name detected.
* Note contains `ít đường` if implementation supports item notes.
* If not confident, note may be order note.
* Parser must not fail.

---

## Unknown Product

Input:

```txt
1 món đặc biệt 99k
```

Expected:

* Parsed item exists.
* Product match = unknown.
* Unit price = 99000.
* Completion allowed after review because price exists.

---

## Unknown Product Missing Price

Input:

```txt
1 món đặc biệt
```

Expected:

* Parsed item exists.
* Product match = unknown.
* Unit price = null.
* Blocking warning exists.

---

# Product Matching Tests

## Exact Match

Catalog:

```txt
Cà phê sữa
```

Input:

```txt
Cà phê sữa
```

Expected:

```txt
confidence = exact
```

---

## Normalized Match

Catalog:

```txt
Cà phê sữa
```

Input:

```txt
ca phe sua
```

Expected:

```txt
confidence = exact or high
```

---

## Abbreviation Match

Catalog:

```txt
Cà phê sữa
```

Input:

```txt
cf sữa
```

Expected:

```txt
confidence = high or medium
```

---

## Fuzzy Match

Catalog:

```txt
Trà đào cam sả
```

Input:

```txt
tra dao cam
```

Expected:

```txt
confidence = medium or high
```

---

## Unknown Match

Catalog:

```txt
Cà phê sữa
Trà đào
```

Input:

```txt
bánh tráng trộn
```

Expected:

```txt
confidence = unknown
```

---

# OCR / Screenshot Order Tests

OCR service itself can be mocked.

Test parser behavior on OCR text.

## Multiline Chat

Input OCR text:

```txt
Em lấy:
2 trà đào
1 bánh mì thịt
ship địa chỉ cũ nhé
```

Expected:

* 2 items.
* Order note contains shipping note.
* Source = screenshot.

---

## Noisy OCR

Input:

```txt
E lấy 2 tra dao
1 banh mi thit
```

Expected:

* Parser extracts at least likely items.
* Low confidence warnings if needed.
* Review screen required.

---

## Empty OCR

Input:

```txt
```

Expected:

* No order created.
* User-friendly error.
* Manual/text fallback available.

---

# Menu Import Tests

## Simple Menu

Input:

```txt
Cà phê đen 25k
Cà phê sữa 30k
Trà đào cam sả 35k
Bánh mì thịt 20k
```

Expected:

* 4 products detected.
* Correct prices.

---

## Dot Price

Input:

```txt
Cà phê sữa 30.000
```

Expected:

```txt
sale_price = 30000
```

---

## Comma Price

Input:

```txt
Trà đào 35,000
```

Expected:

```txt
sale_price = 35000
```

---

## Duplicate Product

Existing product:

```txt
Cà phê sữa
```

Menu input:

```txt
Cà phê sữa 30k
```

Expected:

* Duplicate warning.
* Default action = skip duplicate.
* User can choose update/create new if UI supports.

---

## Non-product Lines

Input:

```txt
MENU HÔM NAY
Mua 2 tặng 1
Cà phê sữa 30k
Free ship bán kính 2km
```

Expected:

* Only product line detected.
* Non-product lines ignored or converted to warnings.

---

# AI Order Review Tests

## Exact Match Allows Completion

Given:

* Parsed item matches product with exact confidence.
* Quantity valid.
* Price valid.

Expected:

* Complete button enabled.

---

## Medium Confidence Requires Confirmation

Given:

* Product match confidence = medium.

Expected:

* UI shows `Cần kiểm tra`.
* User must confirm match before completion.

---

## Unknown Product With Price

Given:

* Product unknown.
* Unit price exists.

Expected:

* User can keep as custom item.
* Completion allowed after review confirmation.
* Inventory not affected for custom item.

---

## Unknown Product Without Price

Given:

* Product unknown.
* Unit price missing.

Expected:

* Complete button disabled.
* User must select product, create product, or enter price.

---

## Edit Quantity

Expected:

* User can edit quantity.
* Totals recalculated.

---

## Remove Item

Expected:

* User can remove item.
* If no items remain, completion disabled.

---

# Receipt Tests

## Receipt Data

Given completed order.

Expected receipt includes:

* Store name.
* Order code.
* Date/time.
* Customer optional.
* Items.
* Subtotal.
* Discount.
* Total.
* Payment status.
* Payment method.

---

## Receipt PDF

Expected:

* PDF generated from local data.
* Does not require internet.
* File exists.

---

## Receipt Image

Expected:

* Image generated or shareable screenshot created.
* Does not require internet.
* File exists.

---

# Backup Tests

## JSON Export

Expected exported JSON includes:

* app name.
* version.
* exported_at.
* stores.
* products.
* customers.
* orders.
* order_items.
* inventory_movements.
* expenses.
* bank_accounts.
* settings.

---

## JSON Import Valid Backup

Expected:

* Backup validated.
* Data imported inside transaction.
* App can query imported products/orders.

---

## Invalid Backup

Test cases:

* Missing app field.
* Unsupported version.
* Missing required tables.
* Invalid money values.
* Invalid order items.

Expected:

* Import rejected.
* Existing data unchanged.

---

## Import Rollback

Simulate failure mid-import.

Expected:

* Transaction rollback.
* Existing database state unchanged.

---

# Widget Tests

Widget tests should focus on important UX states.

---

## Home Screen

Must test:

* Shows store name.
* Shows revenue today.
* Shows quick action buttons.
* Shows low stock alert when applicable.
* Shows empty state if no orders.

---

## Product Form

Must test:

* Empty name validation.
* Negative price validation.
* Save button disabled or error shown for invalid input.
* Product image placeholder shown.
* Image selected state shown.

---

## POS Screen

Must test:

* Product list appears.
* Search filters products.
* Tapping product adds to cart.
* Quantity can be increased/decreased.
* Total updates.
* Empty cart cannot complete.
* Complete order button triggers confirmation.

---

## AI Order Review Screen

Must test:

* Shows original input.
* Shows parsed items.
* Shows match status.
* Unknown product blocks completion.
* User can edit quantity.
* User can remove item.

---

## Receipt Screen

Must test:

* Shows order code.
* Shows store name.
* Shows total amount.
* Share/export buttons visible.

---

# Integration / Smoke Tests

Minimum integration smoke test:

```txt
Launch app
↓
Complete onboarding
↓
Create product
↓
Create manual order
↓
Complete order
↓
View receipt
↓
Open reports
↓
Verify revenue updated
```

If full Flutter integration test is too slow, implement at least controller/use-case level smoke tests and document limitation in `BUILD_SPEC.md`.

---

# Manual QA Checklist

Before release, manually verify on iOS simulator or real device.

## Onboarding

* App opens first time.
* Store creation works.
* User reaches Home.

## Products

* Add product.
* Add product image.
* Edit product.
* Deactivate product.
* Search product.

## Manual POS

* Create order.
* Add multiple products.
* Change quantity.
* Apply discount.
* Save as paid.
* Save as unpaid.
* View receipt.

## Voice Order

* Permission request appears.
* Voice input works or fallback appears.
* Recognized text shown.
* Review screen shown.
* Order can be completed after confirmation.

## Text Order

* Paste order text.
* Parser detects items.
* Review screen shown.
* Unknown product handled.

## Screenshot Order

* Pick image.
* OCR text appears.
* User can edit OCR text.
* Parsed order appears.
* Review required.

## Menu Import

* Pick menu image.
* Detected products shown.
* User can edit detected product.
* User can save selected products.
* Duplicates are warned.

## Inventory

* Stock deducted after sale.
* Stock restored after cancel.
* Manual adjustment works.
* Low stock warning appears.

## Expenses

* Add expense.
* Expense appears in list.
* Report net profit changes.

## Reports

* Today report.
* This week report.
* This month report.
* Best-selling products.
* Low stock.

## Receipt

* Receipt preview.
* Export PDF.
* Share image/PDF.

## Backup

* Export backup.
* Import backup.
* Invalid backup rejected.

## Offline

* Turn on airplane mode.
* Create product.
* Create order.
* View report.
* Export receipt.

---

# CI Requirements

GitHub Actions must run:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

CI must fail if:

* Format check fails.
* Analyze fails.
* Any test fails.

CI must not:

* Ignore test failures.
* Disable analyzer.
* Remove tests.
* Require Apple signing secrets for normal test pipeline.

---

# Coverage Requirements

Minimum practical v1 coverage:

```txt
Domain/application critical logic: high coverage
Parser/matching logic: high coverage
Repository/database logic: medium-high coverage
UI widget tests: targeted coverage
```

Do not chase arbitrary percentage if it encourages meaningless tests.

Recommended threshold:

```txt
Overall coverage target: 60%+
Critical business logic: 85%+
```

Critical business logic includes:

* Order calculation.
* Inventory movement.
* Parser.
* Product matching.
* Report calculation.
* Backup validation.

---

# Regression Test Rules

Whenever a bug is fixed:

* Add a test reproducing the bug.
* Confirm the test fails before fix if practical.
* Confirm test passes after fix.
* Do not fix only by changing UI if bug is in business logic.

---

# Test Naming Convention

Use descriptive test names.

Good:

```dart
test('complete paid order deducts inventory and creates sale movement', () async {});
```

Bad:

```dart
test('order test 1', () async {});
```

---

# Test Data Naming

Use readable names:

```txt
store-1
product-coffee
customer-lan
order-paid-1
```

Avoid meaningless IDs in tests unless testing ID generation.

---

# Build Verification Tests

Before considering the app ready:

Required:

```bash
flutter clean
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

If iOS build fails due to signing only, verify:

```bash
flutter build ios --release --no-codesign
```

Signed IPA requirements are defined in:

```txt
09_RELEASE_PLAN.md
10_IOS_SIGNING.md
```

---

# What Must Never Happen

Developer/agent must never:

* Delete failing tests to pass CI.
* Skip parser tests.
* Skip inventory tests.
* Skip order calculation tests.
* Disable analyzer rules to hide errors.
* Mock the entire business layer just to make widget tests pass.
* Treat voice/OCR features as empty placeholder.
* Change business rules without updating tests.
* Hardcode fake sales data into reports.
* Require Internet to run tests.
* Require Apple signing credentials to run unit tests.

---

# Test Completion Criteria

Testing is complete only when:

* `dart format --set-exit-if-changed .` passes.
* `flutter analyze` passes.
* `flutter test` passes.
* Critical business rules have tests.
* Parser has tests.
* Product matching has tests.
* Inventory has tests.
* Reports have tests.
* Backup validation has tests.
* Core UI flows have widget tests.
* Manual QA checklist has been executed at least once before release.
* iOS no-codesign build has been verified.
* Any known testing limitation is recorded in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

---

# Final Instruction For Developer

Implement tests as part of development, not after everything is built.

Do not postpone all tests to the end.

After each major feature:

1. Implement the feature.
2. Add tests for business logic.
3. Run relevant tests.
4. Fix root cause if tests fail.
5. Continue to the next feature.

The project is not ready for release if tests are missing for order calculation, inventory movement, AI parsing, product matching, reports or backup validation.

END OF DOCUMENT
