# BUILD_SPEC.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này là tài liệu điều phối triển khai cuối cùng cho Quico.

Nó tổng hợp:

* Product scope.
* Required features.
* Implementation order.
* Definition of Done.
* Build requirements.
* Release requirements.
* Agent execution rules.
* Decision Log / Technical Debt.

Developer/agent phải đọc file này cùng toàn bộ tài liệu trong thư mục `docs/` trước khi bắt đầu code.

---

# Project Name

**Quico**

Tagline:

> Bán hàng dễ như nhắn tin.

---

# Mission

Build Quico into a working iOS-first Flutter application for small sellers.

Quico must support:

* Offline-first sales management.
* Product catalog with images.
* Manual POS order creation.
* Voice-to-order.
* Text-to-order.
* Screenshot/chat-to-order.
* Menu image import.
* Customer management.
* Inventory tracking.
* Expense tracking.
* Revenue/profit reports.
* Receipt export/share.
* Backup/export/import.
* GitHub CI.
* iOS release workflow.
* Signed IPA if Apple signing secrets exist.
* Unsigned iOS artifact if signing secrets are missing.

---

# Fixed Documentation Structure

The project documentation must use exactly this structure:

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

Do not create extra planning/spec files unless explicitly approved.

Do not create:

```txt
TECH_DEBT.md
DECISIONS.md
ROADMAP.md
PLAN.md
TODO.md
NOTES.md
```

Decision logs, limitations, workarounds and technical debt must be recorded in this file under:

```txt
Decision Log / Technical Debt
```

---

# Source of Truth Priority

When documents conflict, use this priority order:

```txt
1. BUILD_SPEC.md
2. 07_BUSINESS_RULES.md
3. 04_DATABASE_SPEC.md
4. 05_ARCHITECTURE.md
5. 06_AI_SPEC.md
6. 03_UI_SPEC.md
7. 08_TEST_PLAN.md
8. 09_RELEASE_PLAN.md
9. 10_IOS_SIGNING.md
10. 02_USER_STORIES.md
11. 01_PRODUCT_VISION.md
12. 11_AUTONOMOUS_AGENT_RULES.md
```

If a conflict is found:

1. Choose the option that protects data integrity.
2. Preserve offline-first behavior.
3. Preserve app build stability.
4. Record the decision in this file under `Decision Log / Technical Debt`.

---

# Product Scope

Quico v1 is an iOS-first offline AI POS app for small sellers.

Target users:

* Food and drink sellers.
* Online sellers.
* Small retail shops.
* Household businesses.
* Solo sellers.

Quico v1 must be usable for real daily selling.

It must not be a fake demo.

---



# Non-Goals For V1

Quico v1 will not implement:

* Full ERP.
* Full accounting system.
* Tax invoice system.
* Multi-branch management.
* Complex employee roles.
* Payroll.
* App Store release as a hard requirement.
* Mandatory cloud sync.
* Mandatory cloud AI.
* Barcode scanner as a hard requirement.
* Printer integration as a hard requirement.

These can be future features.

---

# Required Tech Stack

Use:

```txt
Flutter
Dart
Riverpod
GoRouter
Drift SQLite
Local file storage
Image picker
Permission handler
Speech-to-text abstraction
OCR abstraction
Rule-based parser
PDF/image receipt export
GitHub Actions
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

If any package blocks iOS build, replace it with a stable alternative while preserving the abstraction and feature behavior.

Record the decision in `Decision Log / Technical Debt`.

---

# Required Repository Structure

The final repository must contain:

```txt
README.md
pubspec.yaml
lib/
test/
ios/
docs/
.github/
  workflows/
    flutter-ci.yml
    ios-release.yml
```

Required docs:

```txt
docs/01_PRODUCT_VISION.md
docs/02_USER_STORIES.md
docs/03_UI_SPEC.md
docs/04_DATABASE_SPEC.md
docs/05_ARCHITECTURE.md
docs/06_AI_SPEC.md
docs/07_BUSINESS_RULES.md
docs/08_TEST_PLAN.md
docs/09_RELEASE_PLAN.md
docs/10_IOS_SIGNING.md
docs/11_AUTONOMOUS_AGENT_RULES.md
docs/BUILD_SPEC.md
```

---

# Required Flutter Structure

Use feature-first architecture:

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
    database/
    errors/
    result/
    utils/
    local_storage/
    permissions/
    ai/
    receipt/

  features/
    onboarding/
    dashboard/
    products/
    customers/
    orders/
    ai_order/
    inventory/
    expenses/
    reports/
    receipts/
    settings/

  shared/
    widgets/
    models/
    formatters/
```

Business logic must not live inside UI widgets.

UI must not call Drift/database tables directly.

---

# Required App Features

## 1. Onboarding

Required:

* Welcome screen.
* Store setup screen.
* Store name required.
* Business type optional.
* Currency fixed to VND.
* No login required.
* User can start selling after onboarding.

Acceptance:

* First launch opens onboarding.
* Store is saved locally.
* App navigates to Home after setup.

---

## 2. Dashboard / Home

Required:

* Store name.
* Offline/ready status.
* Revenue today.
* Orders today.
* Gross profit today.
* Low stock count.
* Recent orders.
* Quick actions:

  * Manual order.
  * Voice order.
  * Text order.
  * Screenshot order.
  * Add product.
  * Add expense.

Acceptance:

* Dashboard reads from local SQLite.
* Empty state works when no data exists.
* Dashboard does not require Internet.

---

## 3. Product Management

Required:

* Product list.
* Product search.
* Add product.
* Edit product.
* Deactivate/soft delete product.
* Product image.
* SKU optional.
* Barcode optional.
* Sale price.
* Cost price.
* Stock quantity.
* Low stock threshold.
* Active/inactive status.

Acceptance:

* Product appears in POS after creation.
* Product image displays if available.
* Product can be hidden from POS.
* Historical orders preserve product snapshots.

---

## 4. Manual POS / Orders

Required:

* Product search/list.
* Add product to cart.
* Quantity stepper.
* Remove cart item.
* Discount support.
* Customer selection optional.
* Payment status:

  * unpaid.
  * partial.
  * paid.
* Payment method:

  * cash.
  * bank_transfer.
  * other.
* Complete order.
* Save unpaid confirmed sale.
* Receipt after completion.

Acceptance:

* Cannot complete empty order.
* Totals calculate correctly.
* Inventory deducts on confirmed sale.
* Receipt is generated from saved order data.
* Draft orders do not affect inventory.

---

## 5. Voice-to-Order

Required:

* Microphone action.
* Permission request only when needed.
* Speech recognition abstraction.
* Vietnamese speech support where platform allows.
* Recognized text display.
* Parsed order draft.
* Product matching.
* Review screen.
* User confirmation before save.
* Fallback to text/manual order.

Acceptance:

* Voice flow is implemented, not an empty placeholder.
* AI result never directly completes order.
* Failure state gives retry/manual fallback.

---

## 6. Text-to-Order

Required:

* Multiline text input.
* Vietnamese parser.
* Quantity detection.
* Price detection.
* Product name detection.
* Customer hint where obvious.
* Notes where obvious.
* Product matching.
* Review screen.

Supported examples:

```txt
2 cà phê sữa
hai cà phê sữa
2 trà đào 35k
1 bánh mì 20 nghìn
2 cafe sua + 1 tra dao
bán cho chị Lan 2 trà đào
```

Acceptance:

* Common Vietnamese order patterns parse correctly.
* Missing price handled.
* Unknown products handled.
* Review required.

---

## 7. Screenshot / Chat-to-Order

Required:

* Select image from photo library.
* Take photo if camera available.
* OCR abstraction.
* OCR text preview.
* User can edit extracted text.
* Parse edited OCR text.
* Product matching.
* Review screen.

Acceptance:

* OCR failure does not block manual/text order.
* User sees extracted text before final save.
* Screenshot-created order source is stored.

---

## 8. Menu Image Import

Required:

* Choose/take menu photo.
* OCR menu text.
* Parse product names and prices.
* Review detected products.
* Edit detected product.
* Detect duplicates.
* Save selected products only after confirmation.

Acceptance:

* No product is saved automatically without review.
* Duplicate product default action is skip.
* Imported products appear in product list/POS.

---

## 9. Customers

Required:

* Customer list.
* Search customer.
* Add/edit customer.
* Name required.
* Phone optional.
* Note optional.
* Customer detail.
* Purchase history.
* Total spent.
* Total orders.

Acceptance:

* Customer stats update after order completion/cancellation.
* Customer soft delete preserves history.

---

## 10. Inventory

Required:

* Current stock display.
* Low stock filter.
* Inventory movement history.
* Manual stock adjustment.
* Stock deduction on sale.
* Stock restoration on cancel/refund.
* Negative stock allowed by default with warning.

Acceptance:

* Every stock change creates inventory movement.
* Draft order does not affect stock.
* Completed order affects stock.
* Cancelled order restores stock.

---

## 11. Expenses

Required:

* Expense list.
* Add/edit expense.
* Soft delete expense.
* Category.
* Amount.
* Date.
* Note optional.

Default categories:

```txt
Nguyên liệu
Nhân công
Mặt bằng
Vận chuyển
Marketing
Khác
```

Acceptance:

* Expenses affect net profit report.
* Deleted expenses excluded from reports.

---

## 12. Reports

Required:

* Today.
* This week.
* This month.
* Custom range if practical.
* Revenue.
* Cash collected if practical.
* Gross profit.
* Expenses.
* Net profit.
* Order count.
* Best-selling products.
* Low-stock products.
* Top customers if practical.

Acceptance:

* Reports are based on local database.
* Cancelled/refunded/draft orders excluded according to business rules.
* Reports do not use fake/static data.

---

## 13. Receipts

Required:

* Receipt screen.
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
* Note optional.
* Export/share as image.
* Export/share as PDF.

Acceptance:

* Receipt generation works offline.
* Receipt is generated from saved order data.
* Receipt export creates a real file or shareable output.

---

## 14. Settings / More

Required:

* Store settings.
* Bank accounts.
* Backup & restore.
* App info.
* Access to customers.
* Access to expenses.
* Access to inventory.

Acceptance:

* Settings persist locally.
* Bank account info stored locally.
* Backup/export actions available.

---

## 15. Backup / Restore

Required:

* Export JSON backup.
* Export SQLite database file if practical.
* Import JSON backup.
* Validate backup before import.
* Warn before overwrite.
* Import inside transaction.

Acceptance:

* Invalid backup rejected.
* Import failure rolls back.
* Existing data not silently destroyed.

---

# Database Requirements

Implement SQLite using Drift.

Required tables:

```txt
stores
products
customers
orders
order_items
inventory_movements
expenses
bank_accounts
app_settings
ai_parse_logs
```

Critical database requirements:

* Use UUID string IDs.
* Store timestamps as Unix milliseconds.
* Store money as integer VND.
* Use soft delete for products/customers/expenses.
* Preserve product snapshots in order_items.
* Use transactions for critical writes.
* Add indexes defined in `04_DATABASE_SPEC.md`.

---

# Required Repositories

Implement repository layer.

Required repositories:

```txt
StoreRepository
ProductRepository
CustomerRepository
OrderRepository
InventoryRepository
ExpenseRepository
ReportRepository
SettingsRepository
BackupRepository/BackupService
```

UI must not call database directly.

---

# Required Domain/Application Services

Implement these services or equivalent use cases:

```txt
OrderCalculationService
InventoryService
ProductMatchingService
OrderTextParser
MenuTextParser
ReportService
ReceiptService
BackupService
PermissionService
SpeechToTextService
OcrService
ImageStorageService
```

---

# Business Rules Summary

Critical rules:

* Money is integer VND.
* Draft orders do not affect inventory.
* Paid/unpaid confirmed sales affect inventory.
* Cancelled/refunded orders restore inventory.
* Completed orders are not hard deleted.
* Product changes do not alter old order item snapshots.
* Revenue excludes draft/cancelled/refunded orders.
* Expenses affect net profit.
* AI-generated orders must go through review.
* Unknown AI item without price blocks completion.
* Medium confidence AI match requires confirmation.
* Every stock change creates inventory movement.
* Import backup must be transactional.

---

# UI Requirements Summary

Follow `03_UI_SPEC.md`.

Required navigation:

```txt
Bottom tabs:
1. Home
2. Orders
3. Products
4. Reports
5. More
```

Required quick action sheet:

```txt
Manual Order
Voice Order
Text Order
Screenshot Order
```

Required states:

* Loading.
* Empty.
* Error.
* Permission denied.
* OCR failed.
* Speech failed.
* Parser uncertainty.
* Unknown product.
* Missing price.

Minimum UI quality:

* Must look like a usable mobile app, not raw demo.
* Vietnamese labels.
* Clear buttons.
* Consistent spacing.
* Product images.
* Mobile portrait friendly.

---

# AI Requirements Summary

AI flow rule:

```txt
Recognize → Parse → Match → Review → Confirm → Save
```

Required AI features:

* Voice-to-order.
* Text-to-order.
* Screenshot/chat-to-order.
* Menu image import.
* Product matching.
* AI review screen.
* Rule-based business assistant if practical.

AI must not:

* Auto-complete orders.
* Auto-deduct inventory without confirmation.
* Make cloud mandatory.
* Break manual POS.
* Store audio files unnecessarily.
* Store image binary in SQLite.

---

# Testing Requirements Summary

Required commands must pass:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Required iOS build check:

```bash
flutter build ios --release --no-codesign
```

Required test areas:

* Product validation.
* Product search.
* Order calculation.
* Order lifecycle.
* Inventory movements.
* Expense reports.
* Revenue reports.
* Profit reports.
* Text parser.
* Menu parser.
* Product matching.
* AI review blocking rules.
* Backup validation/import rollback.
* Receipt data.

Critical tests must not be skipped.

Do not delete failing tests to pass CI.

---

# GitHub Actions Requirements

Create:

```txt
.github/workflows/flutter-ci.yml
.github/workflows/ios-release.yml
```

---

# flutter-ci.yml Requirements

Must run on:

```txt
push to main
pull_request to main
```

Must execute:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Must not require Apple signing secrets.

---

# ios-release.yml Requirements

Must run on:

```txt
tag push v*
```

Must:

* Checkout repo.
* Setup Flutter.
* Install dependencies.
* Run format/analyze/test.
* Build iOS no-codesign.
* Package unsigned artifact.
* Detect signing secrets.
* Build signed IPA if signing secrets exist.
* Upload artifact to GitHub Release.
* Write honest release notes.

---

# iOS Signing Requirements

Default Bundle ID:

```txt
dev.hieuck.quico
```

Signed IPA requires these GitHub Secrets:

```txt
IOS_CERTIFICATE_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_TEAM_ID
IOS_BUNDLE_ID
IOS_EXPORT_METHOD
IOS_PROVISIONING_PROFILE_NAME
```

If any signing secret is missing:

* Do not fail the whole project only because signing is absent.
* Build unsigned artifact.
* Upload unsigned artifact.
* Release notes must say signed IPA was not generated.

Do not commit signing assets.

Never commit:

```txt
*.p12
*.cer
*.mobileprovision
*.base64.txt
AuthKey_*.p8
.env
```

---

# Required iOS Permissions

Add to `ios/Runner/Info.plist`:

```txt
NSCameraUsageDescription
NSPhotoLibraryUsageDescription
NSMicrophoneUsageDescription
NSSpeechRecognitionUsageDescription
```

Vietnamese copy:

```txt
Quico cần quyền camera để chụp ảnh sản phẩm, menu hoặc tin nhắn.
Quico cần quyền ảnh để chọn ảnh sản phẩm, menu hoặc ảnh tin nhắn.
Quico cần quyền micro để tạo đơn bằng giọng nói.
Quico cần quyền nhận dạng giọng nói để chuyển lời nói thành đơn hàng.
```

---

# Required .gitignore Entries

`.gitignore` must include:

```gitignore
# iOS signing secrets
*.p12
*.cer
*.mobileprovision
*.base64.txt
AuthKey_*.p8

# Env/secrets
.env
.env.*
!.env.example

# Release artifacts
*.ipa
release_artifacts/

# Flutter build
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# Fastlane sensitive output
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
```

Do not ignore:

```txt
ios/ExportOptions.plist
.github/workflows/
docs/
```

---

# README Requirements

`README.md` must include:

```txt
Product description
Core features
Tech stack
How to run
How to test
How to build iOS no-codesign
How to create release tag
Signing note
Documentation links
Known limitations
```

Minimum commands:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

Release command:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Signing note:

```txt
Signed IPA requires Apple signing credentials. See docs/10_IOS_SIGNING.md.
```

---

# Implementation Order

Developer/agent must implement in this order unless a strong technical reason requires adjustment.

## Phase 0: Repository and Docs

* Verify docs structure.
* Ensure all required docs exist.
* Ensure README exists or create draft README.
* Ensure `.gitignore` protects signing secrets.

Deliverable:

* Clean repo structure.
* Docs present.

---

## Phase 1: Flutter App Foundation

Tasks:

1. Initialize Flutter project if missing.
2. Configure app name Quico.
3. Configure bundle ID `dev.hieuck.quico`.
4. Add dependencies.
5. Add app shell.
6. Add theme.
7. Add GoRouter.
8. Add bottom navigation.
9. Add shared widgets.

Deliverable:

* App launches.
* Navigation works.
* Basic Home shell exists.

Verification:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

---

## Phase 2: Local Database Foundation

Tasks:

1. Add Drift database.
2. Create required tables.
3. Add migrations.
4. Add database provider.
5. Add settings repository.
6. Add store repository.
7. Add ID/time utilities.
8. Add text normalization utility.
9. Add currency formatter.

Deliverable:

* SQLite database initializes.
* Store can be created.
* Settings persist.

Verification:

* Database tests pass.
* App launches after database init.

---

## Phase 3: Onboarding and Store Setup

Tasks:

1. Welcome screen.
2. Store setup screen.
3. Onboarding completion.
4. Active store handling.
5. Route guard.

Deliverable:

* First launch goes to onboarding.
* User creates store.
* User reaches Home.

Tests:

* Store name required.
* Store saved.
* Route guard works.

---

## Phase 4: Product Management

Tasks:

1. Product repository.
2. Product list.
3. Product search.
4. Add/edit product.
5. Product image storage.
6. Deactivate/soft delete product.
7. Low stock query.
8. Initial stock movement.

Deliverable:

* User can manage products.
* Product images work.
* Products appear in POS.

Tests:

* Create product.
* Edit product.
* Product search normalized Vietnamese.
* Low stock.
* Initial inventory movement.

---

## Phase 5: Customers

Tasks:

1. Customer repository.
2. Customer list.
3. Add/edit customer.
4. Customer detail.
5. Purchase stats.

Deliverable:

* User can manage customers.
* Customer can be attached to order later.

Tests:

* Create customer.
* Search customer.
* Customer stats recalculation.

---

## Phase 6: Manual POS and Orders

Tasks:

1. Cart model/controller.
2. Order calculation service.
3. Order repository.
4. Manual POS screen.
5. Complete order use case.
6. Save unpaid order.
7. Order list.
8. Order detail.
9. Order code generation.
10. Payment status/method.

Deliverable:

* Manual selling works end-to-end.

Tests:

* Order calculation.
* Complete paid order.
* Save unpaid order.
* Product snapshot.
* Empty order blocked.

---

## Phase 7: Inventory

Tasks:

1. Inventory service.
2. Inventory repository.
3. Sale movements.
4. Refund/cancel movements.
5. Manual adjustment.
6. Inventory screen.
7. Low stock warning.

Deliverable:

* Stock changes are correct and auditable.

Tests:

* Sale deducts stock.
* Cancel restores stock.
* Manual adjustment.
* Negative stock policy.

---

## Phase 8: Expenses

Tasks:

1. Expense repository.
2. Expense list.
3. Add/edit expense.
4. Soft delete expense.
5. Expense filters.

Deliverable:

* Expenses can be recorded and used in reports.

Tests:

* Create expense.
* Sum expenses by date range.
* Deleted expense excluded.

---

## Phase 9: Reports

Tasks:

1. Report repository.
2. Dashboard summary.
3. Revenue report.
4. Profit report.
5. Best-selling products.
6. Low-stock report.
7. Report screen filters.

Deliverable:

* User can see business performance.

Tests:

* Revenue excludes cancelled/draft/refunded.
* Gross profit.
* Net profit.
* Best-selling products.

---

## Phase 10: Receipts

Tasks:

1. Receipt data model.
2. Receipt screen.
3. PDF export.
4. Image export/share.
5. Share sheet integration.

Deliverable:

* User can view/share receipt.

Tests:

* Receipt data includes required fields.
* PDF/image generation creates file or shareable output.

---

## Phase 11: AI Text Order and Product Matching

Tasks:

1. Text normalizer.
2. Rule-based order parser.
3. Product matching service.
4. AI order review screen.
5. Unknown product handling.
6. Missing price handling.
7. Quick-create product from review.
8. Complete order from reviewed AI draft.

Deliverable:

* Text-to-order works.

Tests:

* Vietnamese quantity parsing.
* Price parsing.
* Product matching.
* Review blocking rules.

---

## Phase 12: Voice-to-Order

Tasks:

1. SpeechToTextService abstraction.
2. Device speech implementation.
3. Permission handling.
4. Voice order screen.
5. Recognized text preview.
6. Parse recognized text.
7. Review flow.
8. Fallback to text/manual order.

Deliverable:

* Voice-to-order implemented with real platform-backed path or stable fallback.

Tests:

* Fake speech service.
* Voice result flows into parser.
* Permission denied fallback.

---

## Phase 13: Screenshot / Chat-to-Order

Tasks:

1. OcrService abstraction.
2. OCR implementation.
3. Image picker.
4. Camera/photo permission.
5. OCR text preview.
6. Editable OCR text.
7. Parse OCR text.
8. Review flow.

Deliverable:

* Screenshot-to-order works.

Tests:

* Fake OCR service.
* Multi-line chat parser.
* OCR failure fallback.

---

## Phase 14: Menu Image Import

Tasks:

1. MenuTextParser.
2. Menu import screen.
3. OCR integration.
4. Detected products review.
5. Duplicate detection.
6. Bulk save selected products.

Deliverable:

* User can import products from menu image.

Tests:

* Menu parser.
* Duplicate detection.
* No auto-save without confirmation.

---

## Phase 15: Backup / Restore

Tasks:

1. Backup serializer.
2. Backup validator.
3. JSON export.
4. SQLite export if practical.
5. Import flow.
6. Transactional restore.
7. User warning.

Deliverable:

* User can backup/restore data safely.

Tests:

* Export valid JSON.
* Import valid backup.
* Reject invalid backup.
* Rollback on failure.

---

## Phase 16: Settings / More

Tasks:

1. More screen.
2. Store settings.
3. Bank accounts.
4. Backup entry.
5. App info.
6. Settings persistence.

Deliverable:

* Settings area complete.

Tests:

* Store settings update.
* Bank account validation.
* Settings persist.

---

## Phase 17: CI and Release

Tasks:

1. Add `flutter-ci.yml`.
2. Add `ios-release.yml`.
3. Add `ios/ExportOptions.plist`.
4. Verify no signing secrets committed.
5. Verify format/analyze/test.
6. Verify iOS no-codesign build.
7. Add release notes generation.

Deliverable:

* GitHub CI and release workflow exist.

Verification:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

---

## Phase 18: Final QA

Tasks:

1. Run all tests.
2. Run manual QA checklist.
3. Verify app launch.
4. Verify manual order.
5. Verify AI order.
6. Verify screenshot OCR flow.
7. Verify menu import.
8. Verify reports.
9. Verify receipt.
10. Verify backup.
11. Verify iOS build.
12. Update Decision Log / Technical Debt.

Deliverable:

* Release-ready codebase.

---

# Required Commands Before Final Completion

Run:

```bash
flutter clean
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

If signing secrets are available:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

If any command fails:

* Diagnose root cause.
* Fix code/config.
* Re-run command.
* Do not disable checks to pass.

---

# Release Definition of Done

Release is complete when:

* App launches.
* Onboarding works.
* Product management works.
* Product images work.
* Manual POS works.
* Voice-to-order works or has real implementation with safe fallback.
* Text-to-order works.
* Screenshot/chat-to-order works.
* Menu image import works.
* Customer management works.
* Inventory works.
* Expenses work.
* Reports work.
* Receipts work.
* Backup/export/import works.
* Settings work.
* `dart format --set-exit-if-changed .` passes.
* `flutter analyze` passes.
* `flutter test` passes.
* `flutter build ios --release --no-codesign` passes.
* `flutter-ci.yml` exists.
* `ios-release.yml` exists.
* `ios/ExportOptions.plist` exists.
* README exists.
* All docs exist.
* No secrets are committed.
* Release workflow uploads artifact.
* Signed IPA is produced if signing secrets exist.
* Unsigned artifact is produced if signing secrets are missing.
* Release notes are honest.

---

# Release Blocking Issues

The following block release:

* App cannot launch.
* Onboarding broken.
* Product creation broken.
* Manual order broken.
* Order calculation incorrect.
* Inventory deduction incorrect.
* Reports incorrect.
* Receipt export broken.
* `flutter analyze` fails.
* `flutter test` fails.
* iOS no-codesign build fails.
* App requires Internet for core selling.
* AI order bypasses review.
* Completed orders can be hard deleted.
* Money stored as float/double.
* Secrets committed.
* GitHub Actions missing.
* Release workflow missing.
* No artifact strategy.

---

# Release Non-Blocking Issues

The following do not block release if documented:

* Signed IPA missing because Apple signing secrets are not configured.
* Full dark mode polish incomplete.
* Advanced charts missing.
* Cloud sync missing.
* App Store/TestFlight not configured.
* OCR imperfect on poor image quality.
* Speech recognition imperfect in noisy environment.
* Barcode scanner missing.
* Printer integration missing.
* Advanced customer debt management incomplete.

Record non-blocking issues in `Decision Log / Technical Debt`.

---

# Manual QA Checklist

Before tagging release, verify:

## App

* [ ] App launches.
* [ ] App does not crash on startup.
* [ ] App works after restart.

## Onboarding

* [ ] First launch shows onboarding.
* [ ] Store name validation works.
* [ ] Store is created.
* [ ] User reaches Home.

## Products

* [ ] Add product.
* [ ] Add product image.
* [ ] Edit product.
* [ ] Search product.
* [ ] Deactivate product.
* [ ] Low stock indicator works.

## Manual POS

* [ ] Create order.
* [ ] Add multiple products.
* [ ] Change quantity.
* [ ] Remove item.
* [ ] Apply discount.
* [ ] Save as paid.
* [ ] Save as unpaid.
* [ ] Receipt appears.

## AI Text Order

* [ ] Input `2 cà phê sữa 30k`.
* [ ] Parser detects product, quantity, price.
* [ ] Review screen appears.
* [ ] User can edit item.
* [ ] Order completes after confirmation.

## Voice Order

* [ ] Microphone permission appears.
* [ ] Voice input records/transcribes or fallback works.
* [ ] Recognized text appears.
* [ ] Review screen appears.
* [ ] Order completes after confirmation.

## Screenshot Order

* [ ] User selects image.
* [ ] OCR extracts text or fallback appears.
* [ ] User can edit OCR text.
* [ ] Review screen appears.
* [ ] Order completes after confirmation.

## Menu Import

* [ ] User selects menu image.
* [ ] OCR extracts text or fallback appears.
* [ ] Products detected.
* [ ] User can edit detected products.
* [ ] User confirms save.
* [ ] Products appear in product list.

## Customers

* [ ] Add customer.
* [ ] Search customer.
* [ ] Attach customer to order.
* [ ] Customer stats update.

## Inventory

* [ ] Sale deducts stock.
* [ ] Cancel restores stock.
* [ ] Manual adjustment works.
* [ ] Movement history shown.
* [ ] Low stock warning shown.

## Expenses

* [ ] Add expense.
* [ ] Edit expense.
* [ ] Delete expense.
* [ ] Expense affects net profit.

## Reports

* [ ] Today report.
* [ ] This week report.
* [ ] This month report.
* [ ] Revenue correct.
* [ ] Profit correct.
* [ ] Best-selling products correct.

## Receipts

* [ ] Receipt screen shows correct data.
* [ ] PDF export works.
* [ ] Image/share works.

## Backup

* [ ] Export backup.
* [ ] Import valid backup.
* [ ] Reject invalid backup.
* [ ] Import warning appears.

## Offline

* [ ] Enable airplane mode.
* [ ] Create product.
* [ ] Create order.
* [ ] View report.
* [ ] Export receipt.
* [ ] App does not require login.

## iOS

* [ ] Permissions text exists.
* [ ] No-codesign build passes.
* [ ] Signed IPA builds if credentials exist.

---

# Agent Execution Rules

Developer/agent must:

* Read all docs.
* Follow implementation order.
* Keep app buildable.
* Run tests frequently.
* Fix root causes.
* Avoid asking low-level questions.
* Preserve offline-first behavior.
* Preserve data integrity.
* Preserve AI review flow.
* Preserve fixed docs structure.
* Record decisions in this file.

Developer/agent must not:

* Stop after describing an error.
* Delete failing tests.
* Disable analyzer to hide issues.
* Remove required features.
* Turn required AI features into empty placeholders.
* Commit secrets.
* Make cloud mandatory.
* Make manual POS depend on AI.
* Claim signed IPA exists without actual `.ipa`.

---

# Decision Log / Technical Debt

Use this section to record implementation decisions, compromises, package replacements, known limitations, and future revisit items.

Do not create a separate tech debt file.

Each entry must use this format:

```md
## Decision: <short title>

Date: YYYY-MM-DD

Area:
<Feature/architecture/release/testing/signing/etc.>

Decision:
<What was decided.>

Reason:
<Why this decision was made.>

Risk:
<What could go wrong or what limitation remains.>

Follow-up needed:
<What should be revisited later.>
```

---

## Decision: Use rule-based parser for v1

Date: 2026-06-16

Area:
AI Order Parser

Decision:
Use a rule-based Vietnamese order parser for v1 instead of requiring a cloud LLM.

Reason:
Quico v1 must work offline and avoid API cost/dependency.

Risk:
The parser may not understand complex natural language orders.

Follow-up needed:
Evaluate optional cloud LLM parser after first usable IPA release.

---

## Decision: Local SQLite is source of truth

Date: 2026-06-16

Area:
Data Architecture

Decision:
Use local SQLite via Drift as the primary source of truth.

Reason:
Quico must be offline-first and usable without login or Internet.

Risk:
Multi-device sync is not available in v1.

Follow-up needed:
Design sync layer after v1 if multi-device support becomes required.

---

## Decision: Use normalized token overlap for product matching

Date: 2026-06-16

Area:
Product Matching / AI

Decision:
Use normalized token overlap scoring (Jaccard-like) with abbreviation expansion instead of an external fuzzy string library.

Reason:
Predictable, testable, offline-capable, no dependency risk. External fuzzy libraries add complexity without clear benefit for Vietnamese product names which are typically short (2-4 tokens).

Risk:
May not handle typos as gracefully as Levenshtein-based approaches. Long product names with many tokens may have lower scores.

Follow-up needed:
If matching quality is insufficient with real data, consider adding Levenshtein or trigram similarity as a fallback step.

---

## Decision: Order status state machine enforced

Date: 2026-06-16

Area:
Business Rules / Database

Decision:
Added explicit valid (status, payment_status) combinations table and transition rules to `07_BUSINESS_RULES.md`. The application layer must enforce these combinations; invalid states must be rejected before database write.

Reason:
Prevents data inconsistency where an order could be `paid` with `payment_status = unpaid`. The state machine makes business intent explicit.

Risk:
Adds validation logic complexity in the order service layer.

Follow-up needed:
Consider adding database-level CHECK constraints if SQLite/Drift supports them for this version.

---

## Decision: Conservative parser ambiguity strategy

Date: 2026-06-16

Area:
AI Order Parser

Decision:
Parser over-includes uncertain text into product names rather than dropping it. Unparsed text becomes order notes or warnings. No text is silently discarded.

Reason:
Produces editable drafts rather than losing data. User can fix on the review screen.

Risk:
May produce overly long product names that need manual editing.

Follow-up needed:
None for v1. Revisit if user feedback shows excessive editing is needed.

---

## Decision: Signed IPA depends on external Apple credentials

Date: 2026-06-16

Area:
iOS Release

Decision:
The release workflow must produce unsigned artifact by default and signed IPA only when Apple signing secrets are configured.

Reason:
Apple signing credentials cannot be generated automatically inside the codebase.

Risk:
Without signing secrets, release will not include installable IPA.

Follow-up needed:
Configure GitHub Secrets listed in `10_IOS_SIGNING.md` when signed IPA is required.

---

# Final Developer Instruction

Start implementation from the current repository state.

If no Flutter project exists, create it.

Then implement Quico according to this document and all docs in `docs/`.

Continue until the Release Definition of Done is satisfied.

If blocked by missing Apple signing credentials, still complete the app, tests, CI, no-codesign iOS build, unsigned artifact, release workflow and signing documentation.

Do not stop at a partial demo.

END OF DOCUMENT
