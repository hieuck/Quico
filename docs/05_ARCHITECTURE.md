# 05_ARCHITECTURE.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả kiến trúc kỹ thuật của Quico.

Mục tiêu:

* Xây dựng app iOS-first bằng Flutter.
* Hoạt động offline-first.
* Dễ maintain.
* Dễ mở rộng sang Android, Web và cloud sync sau này.
* Không biến codebase thành demo rối rắm.
* Cho phép AI, voice, OCR thay đổi provider mà không ảnh hưởng toàn app.
* Đảm bảo business logic có thể test được.
* Đảm bảo app có thể build thành iOS artifact và IPA khi có signing credentials.

---

# Architecture Summary

Quico sử dụng kiến trúc:

```txt
Flutter App
├─ Presentation Layer
├─ Application Layer
├─ Domain Layer
├─ Data Layer
├─ Local SQLite Database
├─ Local File Storage
└─ Platform Services
```

Nguyên tắc chính:

```txt
UI không gọi database trực tiếp.
UI không chứa business logic quan trọng.
Business logic phải nằm trong service/use case/repository.
AI/OCR/Speech phải được abstract.
App phải chạy được khi không có Internet.
```

---

# Primary Stack

Use:

```txt
Flutter
Dart
Riverpod
GoRouter
Drift SQLite
Local File Storage
Path Provider
Share Plus
PDF/Image Export
Speech Recognition Abstraction
OCR Abstraction
```

Recommended packages:

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  riverpod_annotation:

  go_router:

  drift:
  sqlite3_flutter_libs:
  path:
  path_provider:

  uuid:
  intl:

  image_picker:
  permission_handler:
  share_plus:
  printing:
  pdf:
  screenshot:

  speech_to_text:
  google_mlkit_text_recognition:

dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner:
  drift_dev:
  riverpod_generator:
  riverpod_lint:
  custom_lint:
  flutter_lints:
```

Notes:

* Package choices may change if there are compatibility issues.
* If a package blocks iOS build, replace it with a stable alternative.
* Do not block the project on non-critical package problems.
* All non-trivial replacements must be recorded in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

---

# Platform Target

Primary target:

```txt
iOS
```

Secondary future targets:

```txt
Android
Web Dashboard
```

Architecture must not hardcode iOS-only assumptions into business logic.

Platform-specific code must be isolated.

---

# Architectural Principles

## 1. Offline-first

Local SQLite database is the source of truth.

The app must support the following features without Internet:

* Product management.
* Order creation.
* Inventory tracking.
* Customer management.
* Expense tracking.
* Reports.
* Receipt export.
* Backup export/import.

---

## 2. Feature-first Structure

Code is organized by feature.

Good:

```txt
features/orders/
features/products/
features/reports/
```

Bad:

```txt
screens/
widgets/
controllers/
```

A small shared/core layer is allowed.

---

## 3. Clear Layer Boundaries

Each complex feature should follow:

```txt
presentation
application
domain
data
```

Not every feature needs every folder if the feature is simple, but complex features such as orders, products, AI order, inventory, reports and receipts must use clear layering.

---

## 4. Replaceable Infrastructure

The following must be replaceable through interfaces:

* SQLite implementation.
* OCR provider.
* Speech recognition provider.
* AI parser.
* Backup provider.
* Receipt export provider.
* Future cloud sync provider.

---

## 5. Business Logic Must Be Testable

Critical logic must not depend on Flutter widgets.

Examples:

* Order calculation.
* Inventory movement.
* Product matching.
* Text order parsing.
* Report calculation.
* Backup validation.

These must be testable with unit tests.

---

# Project Structure

Required structure:

```txt
lib/
  main.dart

  app/
    quico_app.dart
    router.dart
    theme.dart
    app_bootstrap.dart
    app_providers.dart

  core/
    constants/
      app_constants.dart
      route_names.dart
      storage_keys.dart

    database/
      app_database.dart
      database_provider.dart
      migrations.dart
      tables/
        stores_table.dart
        products_table.dart
        customers_table.dart
        orders_table.dart
        order_items_table.dart
        inventory_movements_table.dart
        expenses_table.dart
        bank_accounts_table.dart
        app_settings_table.dart
        ai_parse_logs_table.dart

    errors/
      app_exception.dart
      failure.dart
      error_mapper.dart

    result/
      result.dart

    utils/
      currency_formatter.dart
      date_range.dart
      date_time_utils.dart
      id_generator.dart
      text_normalizer.dart
      validators.dart

    local_storage/
      local_file_storage.dart
      image_storage_service.dart
      backup_file_service.dart

    permissions/
      permission_service.dart

    ai/
      speech/
        speech_to_text_service.dart
        device_speech_to_text_service.dart
      ocr/
        ocr_service.dart
        mlkit_ocr_service.dart
      parser/
        order_text_parser.dart
        rule_based_order_text_parser.dart
        menu_text_parser.dart
        parsed_order_models.dart

    receipt/
      receipt_renderer.dart
      receipt_pdf_service.dart
      receipt_image_service.dart

  features/
    onboarding/
      presentation/
      application/
      domain/
      data/

    dashboard/
      presentation/
      application/
      domain/
      data/

    products/
      presentation/
      application/
      domain/
      data/

    customers/
      presentation/
      application/
      domain/
      data/

    orders/
      presentation/
      application/
      domain/
      data/

    ai_order/
      presentation/
      application/
      domain/
      data/

    inventory/
      presentation/
      application/
      domain/
      data/

    expenses/
      presentation/
      application/
      domain/
      data/

    reports/
      presentation/
      application/
      domain/
      data/

    receipts/
      presentation/
      application/
      domain/
      data/

    settings/
      presentation/
      application/
      domain/
      data/

  shared/
    widgets/
      app_button.dart
      app_text_field.dart
      app_card.dart
      money_text.dart
      empty_state.dart
      error_state.dart
      loading_state.dart
      confirm_dialog.dart
      app_bottom_sheet.dart
      status_badge.dart
      product_image.dart

    models/
      money.dart

    formatters/
      money_input_formatter.dart
```

---

# Layer Responsibilities

## 1. Presentation Layer

Contains:

```txt
Screens
Widgets
Controllers
ViewModels
Notifiers
UI state
Form state
```

Responsibilities:

* Render UI.
* Collect user input.
* Show loading, error and empty states.
* Call application layer.
* Never perform direct database operations.
* Never perform critical business calculations.

Allowed:

```dart
ref.watch(productListProvider);
ref.read(createProductControllerProvider.notifier).submit(input);
```

Not allowed:

```dart
database.into(products).insert(...);
```

---

## 2. Application Layer

Contains:

```txt
Use cases
Application services
Feature controllers
Workflow orchestration
```

Responsibilities:

* Coordinate repositories and services.
* Execute user actions.
* Handle transactions through repository/service layer.
* Convert domain errors into user-facing states.

Examples:

```txt
CreateProductUseCase
CompleteOrderUseCase
CancelOrderUseCase
ParseVoiceOrderUseCase
ImportMenuImageUseCase
GenerateReceiptUseCase
```

---

## 3. Domain Layer

Contains:

```txt
Entities
Value objects
Domain services
Business rules
Interfaces
```

Responsibilities:

* Represent business concepts.
* Validate domain rules.
* Calculate totals.
* Define repository contracts if needed.
* Stay independent from Flutter and Drift.

Examples:

```txt
Order
OrderItem
Product
Customer
Money
OrderCalculationService
InventoryPolicy
ProductMatchResult
ParsedOrderDraft
```

---

## 4. Data Layer

Contains:

```txt
Repository implementations
Drift DAOs
Mappers
Local data sources
File storage implementations
```

Responsibilities:

* Read/write SQLite.
* Map database rows to domain models.
* Manage local file paths.
* Implement repository interfaces.

---

# Dependency Direction

Dependencies must point inward:

```txt
Presentation
    ↓
Application
    ↓
Domain
    ↑
Data implements Domain interfaces
```

Practical rule:

* UI depends on providers/use cases.
* Use cases depend on repositories/services.
* Repositories depend on database.
* Domain must not depend on Flutter, Riverpod, Drift, or UI.

---

# State Management

Use Riverpod.

## Read-only Data

Use:

```txt
FutureProvider
StreamProvider
```

Example:

```dart
final productListProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  final storeId = ref.watch(activeStoreIdProvider);
  return repository.watchProducts(storeId);
});
```

## User Actions

Use:

```txt
AsyncNotifier
Notifier
```

Example:

```dart
class CreateProductController extends AsyncNotifier<void> {
  Future<void> submit(CreateProductInput input) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(createProductUseCaseProvider);
      await useCase(input);
    });
  }
}
```

## Form State

Use:

* Local widget state for simple forms.
* Riverpod Notifier for complex forms.
* Do not store every small text-field state globally unless needed.

---

# Routing

Use GoRouter.

Required route groups:

```txt
/onboarding
/home
/orders
/orders/:id
/orders/:id/receipt
/products
/products/new
/products/:id
/products/:id/edit
/products/import-menu
/pos
/ai-order
/ai-order/voice
/ai-order/text
/ai-order/screenshot
/ai-order/review
/customers
/customers/new
/customers/:id
/expenses
/inventory
/reports
/settings
/settings/store
/settings/bank-accounts
/settings/backup
```

Route guards:

* If onboarding is not completed, redirect to `/onboarding`.
* If active store is missing, redirect to store setup.
* Do not require login in v1.

---

# App Startup Flow

Startup sequence:

```txt
main()
↓
ensure Flutter binding
↓
initialize local database
↓
initialize app settings
↓
load active store
↓
check onboarding state
↓
launch QuicoApp
```

Pseudo flow:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = await AppBootstrap.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const QuicoApp(),
    ),
  );
}
```

---

# Offline-first Architecture

The app must not have a mandatory backend.

Data flow:

```txt
User Action
↓
Use Case
↓
Repository
↓
SQLite Transaction
↓
UI updates from local state
```

Future sync flow:

```txt
SQLite
↓
Sync Queue
↓
Cloud API
↓
Conflict Resolver
```

For v1:

* Implement local-first only.
* Design repositories so sync can be added later.
* Do not add unfinished cloud sync that breaks local behavior.

---

# Data Flow Examples

## Manual Order

```txt
POS Screen
↓
Cart Controller
↓
CompleteOrderUseCase
↓
OrderCalculationService
↓
OrderRepository.completeOrder()
↓
InventoryRepository.applySaleMovement()
↓
SQLite transaction
↓
Receipt Screen
```

---

## Voice Order

```txt
Voice Order Screen
↓
SpeechToTextService
↓
OrderTextParser
↓
ProductMatchingService
↓
AI Order Review State
↓
User confirms
↓
CompleteOrderUseCase
↓
SQLite transaction
↓
Receipt Screen
```

---

## Screenshot Order

```txt
Screenshot Order Screen
↓
Image Picker
↓
OcrService
↓
OrderTextParser
↓
ProductMatchingService
↓
AI Order Review Screen
↓
User confirms
↓
CompleteOrderUseCase
```

---

## Menu Import

```txt
Products Screen
↓
Image Picker
↓
OcrService
↓
MenuTextParser
↓
Detected Products Review
↓
CreateProductsUseCase
↓
ProductRepository
```

---

# Domain Models

Domain models must not be Drift row classes.

Use separate domain models.

Example:

```dart
class Product {
  final String id;
  final String storeId;
  final String name;
  final String normalizedName;
  final String? sku;
  final String? barcode;
  final int costPrice;
  final int salePrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? imagePath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.normalizedName,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sku,
    this.barcode,
    this.imagePath,
    this.deletedAt,
  });
}
```

Reason:

* Keeps UI/domain independent from Drift.
* Allows easier testing.
* Allows future backend mapping.

---

# Input DTOs

Use input objects for write operations.

Example:

```dart
class CreateProductInput {
  final String storeId;
  final String name;
  final String? sku;
  final String? barcode;
  final int costPrice;
  final int salePrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? imagePath;

  const CreateProductInput({
    required this.storeId,
    required this.name,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.sku,
    this.barcode,
    this.imagePath,
  });
}
```

Do not pass raw maps between layers unless unavoidable.

---

# Result and Error Handling

Use a consistent error model.

Recommended:

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
```

Failure examples:

```dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class OcrFailure extends Failure {
  const OcrFailure(super.message);
}

class SpeechFailure extends Failure {
  const SpeechFailure(super.message);
}

class ParserFailure extends Failure {
  const ParserFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
```

Rules:

* Do not show raw technical exceptions directly to user.
* Map technical errors to user-facing messages.
* Log useful details internally where appropriate.
* AI/OCR/Speech failures must always offer manual fallback.

---

# Validation Architecture

Validation should exist at multiple levels.

## UI Validation

Purpose:

* Fast user feedback.

Examples:

* Empty product name.
* Invalid price.
* Empty store name.

## Use Case Validation

Purpose:

* Enforce business rules.

Examples:

* Cannot complete empty order.
* Cannot create expense with zero amount.
* Cannot import invalid backup.

## Database Constraints

Purpose:

* Last line of defense.

Examples:

* Required fields.
* Non-null constraints.

---

# Business Logic Placement

Critical logic must be placed in domain/application services.

## Must Not Be In UI

```txt
Order total calculation
Profit calculation
Inventory deduction
Customer stats recalculation
Parser confidence rules
Backup validation
Report aggregation
```

## Allowed In UI

```txt
Button enable/disable state
Simple input formatting
Display formatting
Screen navigation
```

---

# Required Domain/Application Services

## OrderCalculationService

Responsibilities:

* Calculate item total.
* Calculate order subtotal.
* Calculate discount.
* Calculate cost amount.
* Calculate gross profit.
* Validate order totals.

---

## InventoryService

Responsibilities:

* Deduct stock after sale.
* Restore stock after cancellation/refund.
* Create movement records.
* Handle correction movement.
* Enforce negative stock policy.

---

## ProductMatchingService

Responsibilities:

* Match parsed text to existing products.
* Exact match.
* Normalized match.
* Fuzzy match.
* Return confidence level.

---

## OrderTextParser

Responsibilities:

* Parse Vietnamese natural text into order draft.
* Detect quantities.
* Detect prices.
* Detect notes.
* Detect customer hint where possible.

---

## MenuTextParser

Responsibilities:

* Parse OCR text from menu image.
* Detect product names.
* Detect prices.
* Detect duplicates.

---

## ReportService

Responsibilities:

* Calculate dashboard summary.
* Calculate revenue.
* Calculate gross profit.
* Calculate net profit.
* Calculate best-selling products.

---

## ReceiptService

Responsibilities:

* Generate receipt data model.
* Render receipt preview.
* Export image.
* Export PDF.

---

## BackupService

Responsibilities:

* Export JSON backup.
* Export SQLite file.
* Validate backup.
* Import backup transactionally.

---

# AI / OCR / Speech Architecture

AI-related features must be modular.

Required abstractions:

```dart
abstract class SpeechToTextService {
  Future<String> listenAndTranscribe();
}

abstract class OcrService {
  Future<String> extractTextFromImage(String imagePath);
}

abstract class OrderTextParser {
  Future<ParsedOrderDraft> parse(String input);
}

abstract class MenuTextParser {
  Future<List<ParsedMenuProduct>> parse(String input);
}
```

V1 implementation:

```txt
SpeechToTextService -> device speech package
OcrService -> ML Kit text recognition or equivalent
OrderTextParser -> rule-based parser
MenuTextParser -> rule-based parser
```

Rules:

* Do not make cloud LLM mandatory.
* Do not block manual POS if AI fails.
* All AI-generated output must go through review screen.
* Keep original input text for audit/debug.

---

# Product Image Architecture

Product images are stored locally.

Flow:

```txt
User picks/takes image
↓
ImageStorageService copies file to app documents directory
↓
Product.image_path stores local path
↓
UI loads image from local path
```

Rules:

* Do not store image binary in SQLite.
* Store file path only.
* If image is deleted/missing, show placeholder.
* Future cloud sync can upload image and store remote URL separately.

Recommended directory:

```txt
app_documents/
  quico/
    images/
      products/
        {productId}.jpg
```

---

# Receipt Export Architecture

Receipt export should be implemented separately from receipt UI.

Required services:

```dart
abstract class ReceiptPdfService {
  Future<File> generatePdf(ReceiptData receipt);
}

abstract class ReceiptImageService {
  Future<File> generateImage(ReceiptData receipt);
}
```

Rules:

* Receipt generation must not require Internet.
* Receipt data must be created from local order data.
* Exported receipt must be shareable through native share sheet.

---

# Permission Architecture

Use one service to manage permissions.

```dart
abstract class PermissionService {
  Future<bool> requestMicrophone();
  Future<bool> requestSpeechRecognition();
  Future<bool> requestCamera();
  Future<bool> requestPhotos();
}
```

Rules:

* Do not request all permissions on first launch.
* Request permission only when user uses related feature.
* If permission is denied, show explanation and fallback.

Examples:

* Microphone denied → allow text order.
* Camera denied → allow photo picker or manual entry.
* Photo denied → allow manual order.

---

# Settings Architecture

Use `app_settings` table through `SettingsRepository`.

Settings should include:

```txt
active_store_id
allow_negative_stock
theme_mode
language
receipt_footer
backup_last_exported_at
```

Rules:

* Do not scatter settings across random files.
* Do not hardcode user preferences.
* Provide default settings on first launch.

---

# Backup Architecture

Backup must be local-first.

Supported exports:

```txt
JSON backup
SQLite database file
```

Import rules:

* Validate first.
* Show warning.
* Import inside transaction.
* Rollback on failure.
* Preserve or replace based on explicit user choice.

Recommended architecture:

```txt
BackupService
├─ BackupSerializer
├─ BackupValidator
├─ BackupImporter
└─ BackupExporter
```

---

# Reporting Architecture

Reports should use local SQLite queries.

Avoid loading all orders into memory for large datasets.

Report data flow:

```txt
Reports Screen
↓
ReportController
↓
ReportRepository
↓
SQLite aggregate queries
↓
Report DTOs
↓
UI
```

Required report DTOs:

```txt
DashboardSummary
RevenueReport
ProfitReport
ProductSalesSummary
CustomerSalesSummary
LowStockSummary
```

Rules:

* Use date ranges with start inclusive, end exclusive.
* Use local timezone.
* Do not include cancelled orders in revenue.
* Include expenses in net profit.

---

# Inventory Architecture

Inventory must be auditable.

Current stock:

```txt
products.stock_quantity
```

History:

```txt
inventory_movements
```

Rules:

* Every stock change must create inventory movement.
* Sales create negative movement.
* Refund/cancel creates positive movement.
* Manual adjustment creates correction/import movement.
* Do not silently update stock without movement record.

---

# Order Architecture

Order lifecycle:

```txt
draft
↓
unpaid
↓
paid
```

Other transitions:

```txt
paid -> cancelled
paid -> refunded
unpaid -> cancelled
draft -> deleted
```

Rules:

* Draft order does not affect inventory.
* Completed paid/unpaid confirmed sale affects inventory.
* Cancel/refund restores inventory.
* Completed orders are not hard deleted.

---

# Feature Module Structure

Each complex feature should follow:

```txt
features/{feature_name}/
  presentation/
    screens/
    widgets/
    controllers/

  application/
    use_cases/
    providers/

  domain/
    models/
    services/
    repositories/

  data/
    repositories/
    mappers/
    daos/
```

Example:

```txt
features/orders/
  presentation/
    screens/
      pos_screen.dart
      order_list_screen.dart
      order_detail_screen.dart
    widgets/
      cart_item_tile.dart
      payment_method_selector.dart
    controllers/
      cart_controller.dart
      order_list_controller.dart

  application/
    use_cases/
      complete_order_use_case.dart
      cancel_order_use_case.dart
      update_completed_order_use_case.dart

  domain/
    models/
      order.dart
      order_item.dart
      cart.dart
    services/
      order_calculation_service.dart
    repositories/
      order_repository.dart

  data/
    repositories/
      drift_order_repository.dart
    mappers/
      order_mapper.dart
```

---

# Dependency Injection

Use Riverpod providers.

Provider examples:

```dart
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DriftProductRepository(database);
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
});
```

Rules:

* Do not instantiate repositories directly inside widgets.
* Do not instantiate database multiple times.
* Centralize provider definitions by feature or app layer.

---

# App Theme Architecture

Theme defined in:

```txt
lib/app/theme.dart
```

Must include:

* Light theme.
* Dark theme if feasible.
* Color scheme.
* Text theme.
* Button styles.
* Input styles.
* Card styles.
* Bottom sheet styles.

Rules:

* Do not hardcode colors directly in every widget.
* Use theme tokens.
* Use shared widgets for common UI.

---

# Shared Widgets

Use shared components to keep UI consistent.

Required shared widgets:

```txt
AppButton
AppTextField
AppCard
MoneyText
EmptyState
ErrorState
LoadingState
ConfirmDialog
AppBottomSheet
StatusBadge
ProductImage
```

Rules:

* Shared widgets should be generic.
* Feature-specific widgets stay inside feature folders.
* Avoid giant shared widgets with too many options.

---

# Formatting Utilities

Required utilities:

```txt
CurrencyFormatter
DateTimeFormatter
VietnameseTextNormalizer
PhoneNormalizer
IdGenerator
```

Rules:

* Money formatting centralized.
* Date formatting centralized.
* Text normalization centralized.

---

# Internationalization

V1 language:

```txt
Vietnamese
```

Architecture should allow future i18n.

Minimum:

* Do not hardcode repeated text in deep business logic.
* UI text can be Vietnamese strings in v1.
* If convenient, add Flutter localization later.

Do not block v1 on full i18n.

---

# Logging

V1 logging:

* Use debug logs during development.
* Do not expose raw logs to user.
* Do not log sensitive business data unnecessarily.

AI parse logs may be stored in local database if implemented.

Rules:

* No remote analytics required in v1.
* No crash reporting required in v1.
* If analytics/crash reporting is added later, user data privacy must be documented.

---

# Security Architecture

V1 local security:

* Data stored in app sandbox.
* No secrets in repository.
* No hardcoded API keys.
* No mandatory cloud API.

Sensitive data:

* Sales data.
* Customer phone numbers.
* Bank account information.

Rules:

* Do not send sensitive data to external services unless user explicitly enables a feature requiring it.
* If external service is used for OCR/AI later, document clearly.

---

# iOS-specific Architecture

Required iOS integrations:

```txt
Camera permission
Photo permission
Microphone permission
Speech recognition permission
Share sheet
File export
```

iOS permissions must be declared in:

```txt
ios/Runner/Info.plist
```

Required descriptions:

```txt
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
NSMicrophoneUsageDescription
NSSpeechRecognitionUsageDescription
```

Do not request permissions on first launch.

Request them contextually.

---

# Build Architecture

Flutter build targets:

```txt
flutter analyze
flutter test
flutter build ios
```

Release pipeline details are defined in:

```txt
09_RELEASE_PLAN.md
10_IOS_SIGNING.md
```

Architecture requirement:

* App must build without cloud secrets.
* App must run with local database only.
* Signing credentials are only needed for signed IPA.

---

# Testing Architecture

Test types:

```txt
Unit tests
Repository tests
Parser tests
Widget tests
Integration smoke tests
```

Critical unit tests:

```txt
OrderCalculationService
InventoryService
OrderTextParser
ProductMatchingService
ReportService
BackupValidator
```

Rules:

* Business logic tests are mandatory.
* Do not delete failing tests to pass CI.
* UI tests can be limited in v1, but core flows must be covered.

---

# Error Recovery Architecture

The app must recover gracefully from common failures.

## Database Error

Show:

```txt
Không thể lưu dữ liệu. Vui lòng thử lại.
```

Developer action:

* Catch error.
* Return Failure.
* Do not crash UI.

## OCR Error

Show:

```txt
Không đọc được ảnh. Bạn có thể thử ảnh khác hoặc nhập thủ công.
```

Fallback:

* Text order.
* Manual order.

## Speech Error

Show:

```txt
Không nhận được giọng nói. Bạn có thể thử lại hoặc nhập bằng văn bản.
```

Fallback:

* Text order.
* Manual order.

## Permission Denied

Show explanation.

Provide:

* Retry.
* Open Settings if appropriate.
* Manual fallback.

---

# Performance Architecture

Rules:

* Use pagination for large lists.
* Use indexed database queries.
* Avoid loading all records into memory.
* Avoid rebuilding entire screens unnecessarily.
* Use Riverpod selectors or scoped providers where useful.
* Keep image loading efficient.

Targets:

```txt
App startup: < 2 seconds after cold launch where practical
Product search: < 300ms for 5,000 products
Dashboard summary: < 500ms
Order completion transaction: < 500ms for normal cart
Report monthly query: < 1s
```

---

# Concurrency Rules

Order completion must be safe.

Because v1 is single-device local-first, concurrency risk is low, but transactions are still required.

Use transactions for:

* Complete order.
* Cancel order.
* Edit completed order.
* Import backup.
* Bulk product import.
* Menu image product import.

Do not perform multi-step financial or inventory writes outside a transaction.

---

# Cloud Sync Future Compatibility

Do not implement full cloud sync in v1 unless explicitly required.

But architecture should prepare for it.

Future fields may include:

```txt
sync_status
last_synced_at
remote_id
device_id
version
```

Do not add incomplete sync complexity if it slows v1.

If added, record the decision in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

---

# Code Style

Use:

```txt
Effective Dart
Flutter lints
Riverpod lint
```

Rules:

* Prefer immutable models.
* Use clear names.
* Avoid giant files.
* Avoid giant widgets.
* Avoid business logic in build methods.
* Avoid magic strings where enums/constants are better.
* Avoid duplicated calculation logic.

---

# Enum Strategy

Use enums in Dart for controlled values.

Examples:

```dart
enum OrderStatus {
  draft,
  unpaid,
  paid,
  cancelled,
  refunded,
}

enum PaymentStatus {
  unpaid,
  partial,
  paid,
}

enum PaymentMethod {
  cash,
  bankTransfer,
  other,
}

enum OrderSource {
  manual,
  voice,
  text,
  screenshot,
}
```

Database stores enum values as strings.

Use mappers:

```dart
OrderStatus orderStatusFromDb(String value);
String orderStatusToDb(OrderStatus status);
```

Do not scatter raw status strings across code.

---

# Date/Time Strategy

Use local time for display and reports.

Store timestamps as Unix milliseconds.

Rules:

* Store `created_at`, `updated_at`, etc. as integer millis.
* Convert to local DateTime for UI.
* Date range queries use start inclusive and end exclusive.
* Week starts Monday.

---

# Money Strategy

Use integer VND.

Rules:

* No float/double for money.
* All calculations use int.
* Format money only in UI/shared formatter.
* Store discounts as integer amount.
* Percentage discounts can be future feature.

---

# File Storage Architecture

Use app documents directory.

Recommended structure:

```txt
quico/
  images/
    products/
    store/
  receipts/
    pdf/
    images/
  backups/
```

Rules:

* SQLite stores paths, not binary blobs.
* File operations handled by `LocalFileStorage`.
* Missing files should not crash UI.
* On product delete, image cleanup can be best-effort.

---

# Feature Completion Requirements

A feature is architecturally complete only when:

* Presentation layer exists.
* Application/use case layer exists where needed.
* Repository/service layer exists.
* Data persistence works.
* Error handling exists.
* Loading/empty states exist.
* Tests exist for critical logic.
* No direct database access from UI.
* No duplicated business logic in widgets.

---

# Decision Log / Technical Debt Policy

The fixed documentation structure for Quico is:

```txt
docs/
├─ 01_PRODUCT_VISION.md
├─ 02_USER_STORIES.md
├─ 03_UI_SPEC.md
├─ 04_DATABASE_SPEC.md
├─ 05_ARCHITECTURE.md
├─ 06_AI_SPEC.md
├─ 07_BUSINESS_RULES.md
├─ 08_TEST_PLAN.md
├─ 09_RELEASE_PLAN.md
├─ 10_IOS_SIGNING.md
├─ 11_AUTONOMOUS_AGENT_RULES.md
└─ BUILD_SPEC.md
```

Do not create extra documentation files unless explicitly approved.

All implementation decisions, compromises, temporary workarounds, technical debt items, and future revisit notes must be recorded in:

```txt
docs/BUILD_SPEC.md
```

under the section:

```txt
Decision Log / Technical Debt
```

Each entry must include:

```txt
Date
Area
Decision
Reason
Risk
Follow-up needed
```

Example:

```md
## Decision: Replace OCR package

Date: 2026-06-16

Area: AI / OCR

Decision:
Replaced package A with package B because package A blocked iOS build.

Reason:
Package A caused iOS build failure on macOS runner.

Risk:
OCR accuracy may differ from the original package.

Follow-up needed:
Re-evaluate OCR accuracy after the first usable IPA.
```

---

# Architecture Acceptance Criteria

Architecture is acceptable only if:

* App runs offline.
* Flutter project builds.
* Feature-first structure exists.
* Drift database is isolated in data/core layer.
* Repository pattern is used.
* Business logic is testable.
* AI/OCR/Speech are abstracted.
* UI does not call database directly.
* Transactions protect order/inventory operations.
* Money uses integer VND.
* Product images use local file path storage.
* Receipts can be generated from local data.
* GitHub Actions can run analyze/test without secrets.
* iOS build does not require cloud backend.
* Non-trivial technical decisions are recorded in `BUILD_SPEC.md`.

---

# Final Instruction For Developer

Implement the architecture as specified.

If a detail is missing:

1. Choose the simplest stable option.
2. Keep offline-first behavior.
3. Preserve clean separation of layers.
4. Record non-trivial decisions in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

Do not compromise:

* Order accuracy.
* Inventory consistency.
* Data integrity.
* Offline capability.
* Build stability.

END OF DOCUMENT
