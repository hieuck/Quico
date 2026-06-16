# 04_DATABASE_SPEC.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả thiết kế database cho Quico.

Mục tiêu:

* Hỗ trợ app hoạt động offline-first.
* Lưu trữ dữ liệu bán hàng an toàn trên thiết bị.
* Đảm bảo các nghiệp vụ đơn hàng, tồn kho, chi phí, báo cáo hoạt động chính xác.
* Đủ chi tiết để developer triển khai trực tiếp bằng SQLite + Drift trong Flutter.
* Dễ mở rộng sang cloud sync trong tương lai.

---

# Database Strategy

Quico v1 sử dụng:

```txt
SQLite local database
Drift ORM
Offline-first architecture
```

Database local là nguồn dữ liệu chính.

Cloud sync nếu có trong tương lai chỉ là lớp bổ sung, không phải điều kiện để app hoạt động.

---

# Core Rules

## 1. Offline-first

App phải hoạt động đầy đủ khi không có Internet.

Các chức năng sau không được phụ thuộc cloud:

* Tạo sản phẩm.
* Tạo đơn hàng.
* Tạo khách hàng.
* Ghi chi phí.
* Xem báo cáo.
* Xuất hóa đơn.
* Điều chỉnh tồn kho.
* Backup dữ liệu.

---

## 2. Money as Integer

Tất cả giá trị tiền tệ phải lưu bằng integer VND.

Không dùng float/double cho tiền.

Ví dụ:

```txt
35.000đ => 35000
1.250.000đ => 1250000
```

---

## 3. Soft Delete

Các bảng nghiệp vụ quan trọng không được xóa cứng nếu đã có liên kết lịch sử.

Dùng `deleted_at` nullable.

Áp dụng cho:

* products
* customers
* expenses

Không soft delete:

* order_items
* inventory_movements

Đơn hàng hoàn tất không được xóa cứng.

---

## 4. Historical Integrity

Khi sản phẩm thay đổi giá hoặc tên, đơn hàng cũ không được thay đổi.

Vì vậy `order_items` phải lưu snapshot:

* product_name
* unit_price
* cost_price

Không chỉ dựa vào bảng `products`.

---

## 5. Local IDs

ID phải được tạo ở app layer.

Recommended:

```txt
UUID v4
```

Lý do:

* Dễ sync sau này.
* Không phụ thuộc autoincrement.
* Tránh conflict khi đồng bộ nhiều thiết bị.

---

## 6. Timestamps

Các bảng chính phải có:

```txt
created_at
updated_at
```

Các bảng soft delete có thêm:

```txt
deleted_at
```

Format lưu:

```txt
Unix milliseconds integer
```

Không lưu timestamp dạng text nếu không cần thiết.

---

# Database Engine

Use Drift with SQLite.

Suggested packages:

```yaml
dependencies:
  drift:
  sqlite3_flutter_libs:
  path_provider:
  path:
  uuid:

dev_dependencies:
  drift_dev:
  build_runner:
```

---

# Naming Conventions

Table names:

```txt
snake_case plural
```

Column names:

```txt
snake_case
```

Dart data classes:

```txt
PascalCase
```

Examples:

```txt
products       -> Product
order_items    -> OrderItem
bank_accounts  -> BankAccount
```

---

# Entity Relationship Overview

```txt
stores
  ├── products
  ├── customers
  ├── orders
  │     └── order_items
  ├── expenses
  ├── inventory_movements
  └── bank_accounts

products
  ├── order_items
  └── inventory_movements

customers
  └── orders
```

---

# ER Diagram

```txt
┌────────────┐
│  stores    │
└─────┬──────┘
      │
      ├──────────────┐
      │              │
┌─────▼──────┐  ┌────▼────────┐
│ products   │  │ customers   │
└─────┬──────┘  └────┬────────┘
      │              │
      │              │
┌─────▼──────────────▼─────┐
│          orders           │
└───────────┬──────────────┘
            │
     ┌──────▼───────┐
     │ order_items  │
     └──────────────┘

products ─── inventory_movements

stores ───── expenses
stores ───── bank_accounts
stores ───── app_settings
```

---

# Tables

---

# 1. stores

Stores represent seller businesses.

V1 supports one active store, but database must allow multiple stores for future expansion.

## Columns

| Column        | Type    | Required | Default | Notes                       |
| ------------- | ------- | -------: | ------- | --------------------------- |
| id            | text    |      yes | -       | UUID                        |
| name          | text    |      yes | -       | Store name                  |
| business_type | text    |       no | null    | food, online, retail, other |
| currency      | text    |      yes | VND     | V1 fixed VND                |
| phone         | text    |       no | null    | Store phone                 |
| address       | text    |       no | null    | Store address               |
| logo_path     | text    |       no | null    | Local image path            |
| created_at    | integer |      yes | now     | Unix ms                     |
| updated_at    | integer |      yes | now     | Unix ms                     |

## Constraints

* `name` cannot be empty.
* `currency` defaults to `VND`.

## Indexes

```sql
CREATE INDEX idx_stores_name ON stores(name);
```

---

# 2. products

Products represent sellable items.

## Columns

| Column              | Type    | Required | Default | Notes               |
| ------------------- | ------- | -------: | ------- | ------------------- |
| id                  | text    |      yes | -       | UUID                |
| store_id            | text    |      yes | -       | FK stores.id        |
| name                | text    |      yes | -       | Display name        |
| normalized_name     | text    |      yes | -       | For search/matching |
| sku                 | text    |       no | null    | Optional            |
| barcode             | text    |       no | null    | Optional            |
| cost_price          | integer |      yes | 0       | VND                 |
| sale_price          | integer |      yes | 0       | VND                 |
| stock_quantity      | integer |      yes | 0       | Current stock       |
| low_stock_threshold | integer |      yes | 5       | Warning threshold   |
| image_path          | text    |       no | null    | Local file path     |
| is_active           | integer |      yes | 1       | Boolean 0/1         |
| created_at          | integer |      yes | now     | Unix ms             |
| updated_at          | integer |      yes | now     | Unix ms             |
| deleted_at          | integer |       no | null    | Soft delete         |

## Constraints

* `name` cannot be empty.
* `sale_price >= 0`.
* `cost_price >= 0`.
* `stock_quantity` may be negative only if business rule allows.
* Default v1 allows negative stock with warning.
* `low_stock_threshold >= 0`.

## Indexes

```sql
CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_products_normalized_name ON products(normalized_name);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_deleted_at ON products(deleted_at);
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity);
```

## Notes

`normalized_name` should remove Vietnamese accents, lowercase text, trim spaces, and collapse duplicate whitespace.

Example:

```txt
"Cà phê sữa đá" -> "ca phe sua da"
```

This field is required for:

* Fast search.
* Fuzzy product matching.
* Voice/text order parsing.

---

# 3. customers

Customers represent buyers.

## Columns

| Column           | Type    | Required | Default | Notes         |
| ---------------- | ------- | -------: | ------- | ------------- |
| id               | text    |      yes | -       | UUID          |
| store_id         | text    |      yes | -       | FK stores.id  |
| name             | text    |      yes | -       | Customer name |
| phone            | text    |       no | null    | Phone number  |
| normalized_phone | text    |       no | null    | Digits only   |
| note             | text    |       no | null    | Seller note   |
| total_spent      | integer |      yes | 0       | Denormalized  |
| total_orders     | integer |      yes | 0       | Denormalized  |
| created_at       | integer |      yes | now     | Unix ms       |
| updated_at       | integer |      yes | now     | Unix ms       |
| deleted_at       | integer |       no | null    | Soft delete   |

## Constraints

* `name` cannot be empty.
* Phone format should not be too strict.
* `total_spent >= 0`.
* `total_orders >= 0`.

## Indexes

```sql
CREATE INDEX idx_customers_store_id ON customers(store_id);
CREATE INDEX idx_customers_name ON customers(name);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_normalized_phone ON customers(normalized_phone);
CREATE INDEX idx_customers_deleted_at ON customers(deleted_at);
```

## Notes

`total_spent` and `total_orders` are denormalized for performance.

They must be recalculated when:

* Order is completed.
* Order is cancelled/refunded.
* Customer is attached/detached from order.

---

# 4. orders

Orders represent sale transactions.

## Columns

| Column          | Type    | Required | Default | Notes                                |
| --------------- | ------- | -------: | ------- | ------------------------------------ |
| id              | text    |      yes | -       | UUID                                 |
| store_id        | text    |      yes | -       | FK stores.id                         |
| customer_id     | text    |       no | null    | FK customers.id                      |
| order_code      | text    |      yes | -       | Human readable                       |
| status          | text    |      yes | draft   | draft/unpaid/paid/cancelled/refunded |
| payment_status  | text    |      yes | unpaid  | unpaid/partial/paid                  |
| payment_method  | text    |       no | null    | cash/bank_transfer/other             |
| subtotal        | integer |      yes | 0       | Before order discount                |
| discount_amount | integer |      yes | 0       | Order-level discount                 |
| total_amount    | integer |      yes | 0       | Final amount                         |
| cost_amount     | integer |      yes | 0       | Total cost                           |
| gross_profit    | integer |      yes | 0       | total_amount - cost_amount           |
| paid_amount     | integer |      yes | 0       | Amount paid                          |
| note            | text    |       no | null    | Order note                           |
| source          | text    |      yes | manual  | manual/voice/text/screenshot         |
| original_input  | text    |       no | null    | AI/OCR original text                 |
| created_at      | integer |      yes | now     | Unix ms                              |
| updated_at      | integer |      yes | now     | Unix ms                              |
| completed_at    | integer |       no | null    | When confirmed                       |
| cancelled_at    | integer |       no | null    | When cancelled                       |

## Allowed status

```txt
draft
unpaid
paid
cancelled
refunded
```

## Allowed payment_status

```txt
unpaid
partial
paid
```

## Allowed payment_method

```txt
cash
bank_transfer
other
```

## Allowed source

```txt
manual
voice
text
screenshot
```

`menu_import` is not an order source. Menu import creates products, not completed orders.

## Constraints

* `subtotal >= 0`.
* `discount_amount >= 0`.
* `total_amount >= 0`.
* `cost_amount >= 0`.
* `paid_amount >= 0`.
* `gross_profit` can be negative.
* `order_code` unique per store.
* Completed orders must have `completed_at`.

## Indexes

```sql
CREATE INDEX idx_orders_store_id ON orders(store_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_code ON orders(order_code);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_completed_at ON orders(completed_at);
CREATE INDEX idx_orders_source ON orders(source);
```

## Notes

`original_input` is used for AI-generated orders.

Examples:

* Voice recognized text.
* Pasted text order.
* OCR extracted text.

Do not store image binary in `orders`.

---

# 5. order_items

Order items represent product lines inside an order.

## Columns

| Column          | Type    | Required | Default | Notes                            |
| --------------- | ------- | -------: | ------- | -------------------------------- |
| id              | text    |      yes | -       | UUID                             |
| order_id        | text    |      yes | -       | FK orders.id                     |
| product_id      | text    |       no | null    | FK products.id nullable          |
| product_name    | text    |      yes | -       | Snapshot                         |
| quantity        | integer |      yes | 1       | Quantity                         |
| unit_price      | integer |      yes | 0       | Sale price snapshot              |
| cost_price      | integer |      yes | 0       | Cost price snapshot              |
| discount_amount | integer |      yes | 0       | Line discount                    |
| line_total      | integer |      yes | 0       | quantity * unit_price - discount |
| line_profit     | integer |      yes | 0       | line_total - cost                |
| note            | text    |       no | null    | Optional                         |
| created_at      | integer |      yes | now     | Unix ms                          |
| updated_at      | integer |      yes | now     | Unix ms                          |

## Constraints

* `quantity > 0`.
* `unit_price >= 0`.
* `cost_price >= 0`.
* `discount_amount >= 0`.
* `line_total >= 0`.
* `line_profit` can be negative.

## Indexes

```sql
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

## Snapshot Rule

Order item must keep product snapshot.

If product is later renamed or repriced, historical order item remains unchanged.

---

# 6. inventory_movements

Inventory movements represent all stock changes.

Never update stock silently without a movement record.

## Columns

| Column         | Type    | Required | Default | Notes                |
| -------------- | ------- | -------: | ------- | -------------------- |
| id             | text    |      yes | -       | UUID                 |
| store_id       | text    |      yes | -       | FK stores.id         |
| product_id     | text    |      yes | -       | FK products.id       |
| type           | text    |      yes | -       | Movement type        |
| quantity_delta | integer |      yes | -       | Positive or negative |
| quantity_after | integer |      yes | -       | Stock after movement |
| reference_type | text    |       no | null    | order/manual/import  |
| reference_id   | text    |       no | null    | Linked entity id     |
| note           | text    |       no | null    | Optional note        |
| created_at     | integer |      yes | now     | Unix ms              |

## Allowed type

```txt
initial
sale
refund
manual_adjustment
import
correction
```

## Quantity Rules

Sale:

```txt
quantity_delta < 0
```

Refund:

```txt
quantity_delta > 0
```

Manual import:

```txt
quantity_delta > 0
```

Correction:

```txt
quantity_delta can be positive or negative
```

## Indexes

```sql
CREATE INDEX idx_inventory_movements_store_id ON inventory_movements(store_id);
CREATE INDEX idx_inventory_movements_product_id ON inventory_movements(product_id);
CREATE INDEX idx_inventory_movements_type ON inventory_movements(type);
CREATE INDEX idx_inventory_movements_reference ON inventory_movements(reference_type, reference_id);
CREATE INDEX idx_inventory_movements_created_at ON inventory_movements(created_at);
```

## Notes

`products.stock_quantity` stores current stock for fast reads.

`inventory_movements` stores history for auditing.

---

# 7. expenses

Expenses represent business costs.

## Columns

| Column     | Type    | Required | Default | Notes                 |
| ---------- | ------- | -------: | ------- | --------------------- |
| id         | text    |      yes | -       | UUID                  |
| store_id   | text    |      yes | -       | FK stores.id          |
| category   | text    |      yes | -       | Expense category      |
| amount     | integer |      yes | -       | VND                   |
| note       | text    |       no | null    | Optional              |
| spent_at   | integer |      yes | now     | When expense happened |
| created_at | integer |      yes | now     | Unix ms               |
| updated_at | integer |      yes | now     | Unix ms               |
| deleted_at | integer |       no | null    | Soft delete           |

## Default Categories

```txt
Nguyên liệu
Nhân công
Mặt bằng
Vận chuyển
Marketing
Khác
```

## Constraints

* `amount > 0`.
* `category` cannot be empty.

## Indexes

```sql
CREATE INDEX idx_expenses_store_id ON expenses(store_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_spent_at ON expenses(spent_at);
CREATE INDEX idx_expenses_deleted_at ON expenses(deleted_at);
```

---

# 8. bank_accounts

Bank accounts are used for bank transfer payment info and future VietQR support.

## Columns

| Column         | Type    | Required | Default | Notes               |
| -------------- | ------- | -------: | ------- | ------------------- |
| id             | text    |      yes | -       | UUID                |
| store_id       | text    |      yes | -       | FK stores.id        |
| bank_code      | text    |      yes | -       | VietQR bank code    |
| bank_name      | text    |      yes | -       | Display name        |
| account_number | text    |      yes | -       | Bank account number |
| account_name   | text    |      yes | -       | Owner name          |
| is_default     | integer |      yes | 0       | Boolean 0/1         |
| created_at     | integer |      yes | now     | Unix ms             |
| updated_at     | integer |      yes | now     | Unix ms             |
| deleted_at     | integer |       no | null    | Soft delete         |

## Constraints

* `bank_code` cannot be empty.
* `account_number` cannot be empty.
* `account_name` cannot be empty.
* Only one default bank account per store.

## Indexes

```sql
CREATE INDEX idx_bank_accounts_store_id ON bank_accounts(store_id);
CREATE INDEX idx_bank_accounts_is_default ON bank_accounts(is_default);
CREATE INDEX idx_bank_accounts_deleted_at ON bank_accounts(deleted_at);
```

---

# 9. app_settings

App settings are key-value records.

## Columns

| Column     | Type    | Required | Default | Notes             |
| ---------- | ------- | -------: | ------- | ----------------- |
| key        | text    |      yes | -       | Primary key       |
| value      | text    |      yes | -       | String/json value |
| updated_at | integer |      yes | now     | Unix ms           |

## Suggested Keys

```txt
active_store_id
schema_version
allow_negative_stock
receipt_footer
theme_mode
language
backup_last_exported_at
```

## Notes

Values can be stored as:

* Plain string.
* JSON string.
* Boolean represented as `true` / `false`.

---

# 10. ai_parse_logs

Optional but recommended for debugging AI parsing.

This table helps improve parser behavior without storing sensitive images.

## Columns

| Column        | Type    | Required | Default | Notes                            |
| ------------- | ------- | -------: | ------- | -------------------------------- |
| id            | text    |      yes | -       | UUID                             |
| store_id      | text    |      yes | -       | FK stores.id                     |
| source        | text    |      yes | -       | voice/text/screenshot/menu_image |
| input_text    | text    |      yes | -       | Transcribed/OCR text             |
| parsed_json   | text    |       no | null    | Parser output                    |
| success       | integer |      yes | 0       | Boolean                          |
| error_message | text    |       no | null    | Error                            |
| created_at    | integer |      yes | now     | Unix ms                          |

## Indexes

```sql
CREATE INDEX idx_ai_parse_logs_store_id ON ai_parse_logs(store_id);
CREATE INDEX idx_ai_parse_logs_source ON ai_parse_logs(source);
CREATE INDEX idx_ai_parse_logs_success ON ai_parse_logs(success);
CREATE INDEX idx_ai_parse_logs_created_at ON ai_parse_logs(created_at);
```

## Privacy Rule

Do not store original images in this table.

Only store extracted text and parser result.

If user disables diagnostic logs later, this table can be skipped.

---

# Drift Table Mapping

Example Drift style:

```dart
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
  IntColumn get salePrice => integer().withDefault(const Constant(0))();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

Use Drift `BoolColumn` where convenient, but remember SQLite stores boolean as integer.

---

# Required DAOs / Repositories

Developer must implement repository layer.

UI must never call Drift tables directly.

---

## StoreRepository

Required methods:

```dart
Future<Store?> getActiveStore();
Future<Store> createStore(CreateStoreInput input);
Future<void> updateStore(UpdateStoreInput input);
Future<void> setActiveStore(String storeId);
```

---

## ProductRepository

Required methods:

```dart
Future<List<Product>> listProducts(String storeId);
Future<List<Product>> searchProducts(String storeId, String query);
Future<List<Product>> listActiveProducts(String storeId);
Future<List<Product>> listLowStockProducts(String storeId);
Future<Product?> getProductById(String id);
Future<Product> createProduct(CreateProductInput input);
Future<Product> updateProduct(UpdateProductInput input);
Future<void> deactivateProduct(String id);
Future<void> softDeleteProduct(String id);
Future<Product?> findBestMatch(String storeId, String productName);
```

---

## CustomerRepository

Required methods:

```dart
Future<List<Customer>> listCustomers(String storeId);
Future<List<Customer>> searchCustomers(String storeId, String query);
Future<Customer?> getCustomerById(String id);
Future<Customer> createCustomer(CreateCustomerInput input);
Future<Customer> updateCustomer(UpdateCustomerInput input);
Future<void> softDeleteCustomer(String id);
Future<void> recalculateCustomerStats(String customerId);
```

---

## OrderRepository

Required methods:

```dart
Future<OrderDraft> createDraftOrder(CreateOrderDraftInput input);
Future<Order> completeOrder(CompleteOrderInput input);
Future<Order> saveUnpaidOrder(SaveUnpaidOrderInput input);
Future<Order?> getOrderById(String id);
Future<OrderWithItems?> getOrderWithItems(String id);
Future<List<Order>> listOrders(OrderFilter filter);
Future<void> cancelOrder(String orderId, String reason);
Future<Order> updateCompletedOrder(UpdateCompletedOrderInput input);
Future<String> generateNextOrderCode(String storeId);
```

Important:

* `completeOrder`, `cancelOrder`, and `updateCompletedOrder` must run inside database transactions.

---

## InventoryRepository

Required methods:

```dart
Future<void> applySaleMovement({
  required String storeId,
  required String productId,
  required String orderId,
  required int quantitySold,
});

Future<void> applyRefundMovement({
  required String storeId,
  required String productId,
  required String orderId,
  required int quantityRestored,
});

Future<void> adjustStock(AdjustStockInput input);

Future<List<InventoryMovement>> listMovementsForProduct(String productId);

Future<int> getCurrentStock(String productId);
```

---

## ExpenseRepository

Required methods:

```dart
Future<List<Expense>> listExpenses(ExpenseFilter filter);
Future<Expense> createExpense(CreateExpenseInput input);
Future<Expense> updateExpense(UpdateExpenseInput input);
Future<void> softDeleteExpense(String id);
Future<int> sumExpenses(String storeId, DateRange range);
```

---

## ReportRepository

Required methods:

```dart
Future<DashboardSummary> getDashboardSummary(String storeId);
Future<RevenueReport> getRevenueReport(String storeId, DateRange range);
Future<ProfitReport> getProfitReport(String storeId, DateRange range);
Future<List<ProductSalesSummary>> getBestSellingProducts(String storeId, DateRange range);
Future<List<CustomerSalesSummary>> getTopCustomers(String storeId, DateRange range);
Future<List<Product>> getLowStockProducts(String storeId);
```

---

## SettingsRepository

Required methods:

```dart
Future<String?> getValue(String key);
Future<void> setValue(String key, String value);
Future<bool> getBool(String key, {required bool defaultValue});
Future<void> setBool(String key, bool value);
```

---

# Transactions

The following operations must be atomic.

---

## Complete Order Transaction

Steps:

1. Validate order/cart.
2. Insert order or update draft order.
3. Insert order items.
4. Calculate totals.
5. Update order totals.
6. Deduct product stock.
7. Insert inventory movements.
8. Update customer stats if customer exists.
9. Commit transaction.

If any step fails, rollback everything.

---

## Cancel Order Transaction

Steps:

1. Load order with items.
2. Check order can be cancelled.
3. Restore inventory for each item with product_id.
4. Insert refund inventory movements.
5. Update order status to cancelled.
6. Update customer stats if customer exists.
7. Commit transaction.

---

## Edit Completed Order Transaction

Steps:

1. Load old order with old items.
2. Compare old items and new items.
3. Reverse old inventory impact.
4. Apply new inventory impact.
5. Recalculate totals.
6. Replace/update order items.
7. Update customer stats.
8. Commit transaction.

---

# Order Code Generation

Order code format:

```txt
DH000001
DH000002
DH000003
```

Rules:

* Unique per store.
* Human-readable.
* Increment based on latest order number.
* Must be generated inside transaction to avoid duplicates.

Recommended implementation:

* Store next sequence in `app_settings` using key:

```txt
order_sequence:{storeId}
```

or derive from latest order code.

Preferred for v1:

```txt
app_settings sequence key
```

Because it is faster and safer.

---

# Date Range Rules

Reports must use local device timezone.

Date ranges:

## Today

```txt
start: local start of day
end: local end of day
```

## This week

Use Monday as start of week.

## This month

From first day of current month to first day of next month exclusive.

Recommended query style:

```sql
created_at >= startMillis AND created_at < endMillis
```

Avoid inclusive end-of-day bugs.

---

# Search Rules

## Product Search

Search by:

* name
* normalized_name
* sku
* barcode

Search should:

* Trim input.
* Normalize Vietnamese accents.
* Case-insensitive.
* Exclude deleted products.
* Exclude inactive products in POS by default.

---

## Customer Search

Search by:

* name
* phone
* normalized_phone

---

## Order Search

Search by:

* order_code
* customer name
* note

---

# Normalization Rules

Implement text normalization utility:

```dart
String normalizeVietnameseText(String input);
```

It must:

* Lowercase.
* Trim.
* Remove Vietnamese diacritics.
* Replace multiple spaces with one.
* Remove common punctuation for matching.

Example:

```txt
"Trà Đào Cam Sả" -> "tra dao cam sa"
"Cà-phê sữa đá" -> "ca phe sua da"
```

---

# Backup and Restore

## Export

Support:

* SQLite database file export.
* JSON backup export.

JSON backup should include:

```json
{
  "app": "Quico",
  "version": 1,
  "exported_at": 1710000000000,
  "stores": [],
  "products": [],
  "customers": [],
  "orders": [],
  "order_items": [],
  "inventory_movements": [],
  "expenses": [],
  "bank_accounts": [],
  "settings": []
}
```

## Import

Rules:

* Validate backup version.
* Validate required fields.
* Show warning before overwrite.
* Import inside transaction.
* Never silently delete current data.
* If import fails, rollback.

---

# Migration Strategy

Use Drift migrations.

Database schema version starts at:

```txt
1
```

## Version 1

Includes:

* stores
* products
* customers
* orders
* order_items
* inventory_movements
* expenses
* bank_accounts
* app_settings
* ai_parse_logs

## Migration Rules

Every future migration must:

* Be deterministic.
* Preserve user data.
* Have fallback if possible.
* Be documented in this file.
* Be tested with at least one old schema sample where practical.

Do not reset database silently.

Do not drop tables without backup.

---

# Seed Data

Quico should not hardcode fake demo data into production logic.

Allowed seed data:

* Default expense categories.
* Default app settings.
* Default receipt footer.

Default settings:

```txt
currency = VND
allow_negative_stock = true
theme_mode = system
language = vi
receipt_footer = Cảm ơn quý khách!
```

Do not create fake products or fake orders by default.

---

# Performance Requirements

Database must handle at least:

```txt
5,000 products
100,000 orders
300,000 order_items
100,000 inventory_movements
20,000 expenses
```

Expected performance:

* Product search under 300ms for 5,000 products.
* Dashboard summary under 500ms.
* Order list first page under 500ms.
* Report monthly query under 1s.

Use indexes for all common filters.

Use pagination for large lists.

---

# Pagination

Required for:

* orders
* products
* customers
* expenses
* inventory movements

Default page size:

```txt
30
```

Maximum page size:

```txt
100
```

---

# Data Validation

Validation must happen before database write.

Database layer should still protect obvious invalid values where possible.

Examples:

* Product name cannot be empty.
* Price cannot be negative.
* Order must have at least one item before completion.
* Expense amount must be greater than zero.
* Quantity must be greater than zero.

---

# Data Privacy

All data is stored locally on device.

Do not send any business data to external services unless user explicitly enables sync or AI cloud features in future versions.

For v1:

* Voice recognition may use platform service depending on OS behavior.
* OCR should be local if possible.
* If any external AI/OCR service is used, it must be clearly abstracted and documented.

---

# Deletion Rules

## Products

If product has no order history:

* Soft delete is still acceptable.

If product has order history:

* Must soft delete.
* Historical order items remain.

## Customers

If customer has orders:

* Soft delete only.

## Orders

Completed orders:

* Do not delete.
* Allow cancel/refund instead.

Draft orders:

* May be hard deleted if never completed.

## Expenses

Soft delete.

---

# Data Consistency Checks

Developer should implement diagnostic checks where useful:

* Order total equals sum of item totals minus discount.
* Product stock equals initial stock plus movements.
* Customer total_spent equals completed paid order total.
* No order item with quantity <= 0.
* No expense with amount <= 0.

These checks can be used in tests and future debug tools.

---

# Required Tests

Database-related tests must cover:

## Product

* Create product.
* Update product.
* Soft delete product.
* Search by normalized Vietnamese name.
* Low stock query.

## Customer

* Create customer.
* Update customer.
* Search by phone.
* Recalculate stats.

## Order

* Create manual order.
* Complete order.
* Generate order code.
* Save unpaid order.
* Cancel completed order.
* Edit completed order.
* Preserve product snapshot.

## Inventory

* Deduct stock on sale.
* Restore stock on cancel/refund.
* Manual adjustment.
* Movement history.

## Expenses

* Create expense.
* Sum expenses by date range.
* Soft delete expense.

## Reports

* Revenue today.
* Revenue this month.
* Gross profit.
* Net profit.
* Best-selling products.
* Low-stock products.

## Backup

* Export JSON.
* Import JSON.
* Reject invalid schema.

---

# Implementation Notes For Developer

Use repository methods and transactions carefully.

Do not put business logic inside UI widgets.

Do not calculate critical totals only in UI.

Critical calculations must live in service/domain layer and be tested.

Recommended services:

```txt
OrderCalculationService
InventoryService
ReportQueryService
ProductSearchService
BackupService
```

---

# Example Order Calculation

Input:

```txt
2 x Cà phê sữa
unit_price = 30000
cost_price = 12000

1 x Trà đào
unit_price = 35000
cost_price = 15000

order_discount = 5000
```

Calculation:

```txt
subtotal = 2 * 30000 + 1 * 35000
subtotal = 95000

total_amount = 95000 - 5000
total_amount = 90000

cost_amount = 2 * 12000 + 1 * 15000
cost_amount = 39000

gross_profit = 90000 - 39000
gross_profit = 51000
```

---

# Example Inventory Movement

Before sale:

```txt
Cà phê sữa stock = 20
```

Sale:

```txt
quantity sold = 2
quantity_delta = -2
quantity_after = 18
```

Movement:

```txt
type = sale
reference_type = order
reference_id = order_id
```

---

# Final Database Acceptance Criteria

Database implementation is complete only when:

* All required tables exist.
* Required indexes exist.
* Drift database builds successfully.
* Repositories are implemented.
* Critical write operations use transactions.
* Order totals are calculated correctly.
* Inventory movements are recorded correctly.
* Reports query correct data.
* Backup/export works.
* Tests cover critical business logic.
* No UI directly accesses database tables.
* No money values are stored as floating point.
* No completed order is hard deleted.
* App works fully offline.

END OF DOCUMENT
