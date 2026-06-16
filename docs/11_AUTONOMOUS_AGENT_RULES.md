# 11_AUTONOMOUS_AGENT_RULES.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này định nghĩa quy tắc làm việc cho developer agent khi xây dựng Quico.

Mục tiêu:

* Agent làm việc như một full-stack/mobile developer tự chủ.
* Không dừng lại khi gặp lỗi thông thường.
* Không hỏi lại những quyết định có thể tự xử lý bằng tài liệu.
* Không làm demo nửa vời.
* Không xóa chức năng hoặc test để build thành công.
* Không phá cấu trúc tài liệu đã chốt.
* Tiếp tục cho đến khi đạt Definition of Done trong `BUILD_SPEC.md`.

---

# Fixed Documentation Structure

Quico sử dụng đúng cấu trúc tài liệu sau:

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

Agent must not create extra planning/spec files unless explicitly required by the user.

If a decision, workaround, limitation or technical debt must be recorded, write it in:

```txt
docs/BUILD_SPEC.md
```

under:

```txt
Decision Log / Technical Debt
```

Do not create:

```txt
TECH_DEBT.md
DECISIONS.md
ROADMAP.md
PLAN.md
TODO.md
NOTES.md
```

unless explicitly approved.

---

# Agent Mission

The agent's mission is:

```txt
Build Quico from documentation to a working iOS-ready Flutter app with offline-first POS, AI order input, local database, tests, CI, release workflow and IPA/signing-ready artifact.
```

The agent must continue until the project satisfies:

* Product requirements.
* UI requirements.
* Database requirements.
* Architecture requirements.
* AI requirements.
* Business rules.
* Test plan.
* Release plan.
* iOS signing plan.
* Final Definition of Done in `BUILD_SPEC.md`.

---

# Operating Mode

Agent must operate in:

```txt
Autonomous implementation mode
```

Meaning:

* Read relevant docs before coding.
* Plan internally.
* Implement incrementally.
* Run tests frequently.
* Fix root causes.
* Continue after errors.
* Record only meaningful decisions.
* Avoid unnecessary user questions.

---

# Source of Truth Priority

When making implementation decisions, use this priority order:

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

If documents conflict:

1. Prefer `BUILD_SPEC.md`.
2. Prefer business/data correctness over UI convenience.
3. Prefer offline-first behavior.
4. Record the conflict and chosen resolution in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

---

# Non-Negotiable Outcomes

The agent must not stop until these are true or explicitly impossible due to missing external credentials:

* App launches.
* Onboarding works.
* Product management works.
* Product images work.
* Manual POS works.
* Voice-to-order works or has a real platform-backed implementation with safe fallback.
* Text-to-order works.
* Screenshot/chat-to-order works with OCR or stable fallback.
* Menu image import works.
* Customer management works.
* Inventory works.
* Expenses work.
* Reports work.
* Receipt export/share works.
* Backup/export works.
* `flutter analyze` passes.
* `flutter test` passes.
* iOS no-codesign build passes.
* GitHub Actions exist.
* Release workflow exists.
* Signed IPA is generated if signing secrets exist.
* Unsigned artifact is generated if signing secrets are missing.

---

# Autonomous Decision Rules

Agent should not ask the user about low-level decisions.

Use these defaults:

| Area                  | Default Decision                        |
| --------------------- | --------------------------------------- |
| Framework             | Flutter                                 |
| State management      | Riverpod                                |
| Routing               | GoRouter                                |
| Local database        | Drift SQLite                            |
| Money                 | integer VND                             |
| IDs                   | UUID v4                                 |
| Language              | Vietnamese                              |
| Primary platform      | iOS                                     |
| Offline behavior      | Required                                |
| Product image storage | local file path                         |
| OCR                   | local/on-device provider where possible |
| Speech                | device speech service where possible    |
| Parser                | rule-based v1                           |
| Cloud sync            | not required v1                         |
| Signing               | manual signing via GitHub Secrets       |
| Release fallback      | unsigned iOS artifact                   |

If a package fails, choose the simplest stable alternative that preserves the feature.

---

# When Agent May Ask User

Agent may ask the user only when blocked by an external requirement that cannot be inferred or generated.

Examples:

* Apple Developer certificate is missing.
* Provisioning profile is missing.
* GitHub repository permission is unavailable.
* Bundle ID must be changed for a real Apple account.
* User wants a different app name.
* User wants App Store release instead of GitHub IPA.

Agent must not ask about:

* Folder structure.
* Package choice unless all reasonable choices fail.
* Button color.
* Database column names already defined.
* Business rules already defined.
* Whether to write tests.
* Whether to fix build errors.
* Whether to continue after a normal error.
* Whether to use offline-first.
* Whether to implement voice/OCR/text order.

---

# Error Handling Rules For Agent

When an error occurs, agent must follow:

```txt
Observe → Diagnose → Fix Root Cause → Test → Continue
```

Agent must not stop after only describing the error.

---

## Error Response Pattern

For every blocker, agent should determine:

1. What failed?
2. Which command failed?
3. What is the root cause?
4. What file/code/config must change?
5. What test/build command proves the fix?
6. What feature is affected?
7. Whether the decision must be recorded in `BUILD_SPEC.md`.

---

# Build Error Rules

If `flutter pub get` fails:

* Check `pubspec.yaml`.
* Check package names and versions.
* Check Flutter SDK compatibility.
* Replace incompatible packages if needed.
* Run `flutter pub get` again.

If `flutter analyze` fails:

* Fix actual analyzer errors.
* Do not disable analyzer globally.
* Do not silence warnings unless justified.
* Do not remove code to hide the problem.

If `flutter test` fails:

* Identify failing test.
* Fix implementation or test if test is incorrect.
* Do not delete failing tests.
* Do not skip tests without documented reason.

If iOS build fails:

* Inspect native plugin errors.
* Check `Info.plist`.
* Check Pod install issues.
* Check package iOS support.
* Replace incompatible package if required.
* Re-run iOS build.

---

# Package Failure Rules

If a package blocks implementation:

1. Confirm the package is the actual root cause.
2. Search for a stable alternative if needed.
3. Replace only the affected abstraction implementation.
4. Preserve public interface.
5. Update docs only if behavior changes.
6. Record decision in `BUILD_SPEC.md`.

Examples:

* OCR package fails iOS build → replace OCR implementation but keep `OcrService`.
* Speech package unreliable → keep `SpeechToTextService`, add text fallback.
* PDF package incompatible → replace PDF renderer but keep `ReceiptPdfService`.

---

# iOS Signing Blocker Rules

If Apple signing credentials are missing:

Agent must still complete:

* Flutter app.
* Tests.
* iOS no-codesign build.
* Release workflow.
* Unsigned artifact.
* Signing documentation.

Agent must not claim signed IPA exists.

Correct statement:

```txt
Signed IPA requires Apple signing credentials. Unsigned iOS artifact has been produced.
```

Incorrect statement:

```txt
IPA is complete.
```

unless `Quico.ipa` actually exists.

---

# GitHub Actions Rules

Agent must create:

```txt
.github/workflows/flutter-ci.yml
.github/workflows/ios-release.yml
```

CI must:

* Run format check.
* Run analyze.
* Run tests.
* Not require Apple signing secrets.

Release workflow must:

* Run on tag `v*`.
* Build iOS no-codesign artifact.
* Attempt signed IPA only if signing secrets exist.
* Upload artifact to GitHub Release.
* Produce honest release notes.

Agent must not:

* Disable CI because tests fail.
* Remove release workflow because signing is missing.
* Commit secrets.
* Commit certificates.
* Commit provisioning profiles.

---

# Implementation Order

Agent must implement in this order unless blocked by a strong technical reason:

```txt
1. Initialize Flutter project.
2. Create fixed docs structure if missing.
3. Add base app shell.
4. Add routing.
5. Add theme/design system.
6. Add shared widgets.
7. Add Drift database.
8. Add repositories.
9. Add onboarding.
10. Add dashboard.
11. Add products.
12. Add customers.
13. Add manual POS/orders.
14. Add inventory movements.
15. Add expenses.
16. Add reports.
17. Add receipt view/export.
18. Add product image support.
19. Add text-to-order parser.
20. Add product matching.
21. Add voice-to-order.
22. Add screenshot/chat-to-order OCR.
23. Add menu image import.
24. Add backup/export/import.
25. Add settings.
26. Add tests.
27. Fix analyze/test.
28. Add GitHub Actions.
29. Add iOS release workflow.
30. Verify iOS no-codesign build.
31. Prepare signed IPA path if secrets exist.
32. Final cleanup.
```

Do not start with release workflow before app basics exist.

Do not postpone database/business rules until after UI is complete.

---

# Commit Rules

Agent should make meaningful commits.

Recommended commit groups:

```txt
docs: add Quico product documentation
chore: initialize Flutter project
chore: add app architecture and routing
feat: add local database schema
feat: add product management
feat: add manual POS order flow
feat: add inventory movements
feat: add AI text order parser
feat: add voice order flow
feat: add screenshot OCR order flow
feat: add reports
feat: add receipt export
test: add business logic tests
ci: add Flutter CI and iOS release workflow
docs: add release and signing instructions
```

Do not create noisy commits like:

```txt
fix
update
changes
final
final2
try again
```

If the environment does not support committing, still keep the code organized as if commits would be made.

---

# Documentation Update Rules

Agent must update documentation when:

* A non-trivial implementation decision differs from docs.
* A package replacement changes behavior.
* A release limitation exists.
* A signing limitation exists.
* A feature is intentionally deferred.
* A workaround is used.

Record such entries in:

```txt
docs/BUILD_SPEC.md
```

under:

```txt
Decision Log / Technical Debt
```

Do not create new ad-hoc docs.

---

# Decision Log Entry Format

Each decision entry must follow this format:

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

Example:

```md
## Decision: Use rule-based parser for v1

Date: 2026-06-16

Area:
AI Order Parser

Decision:
Implemented a rule-based Vietnamese order parser instead of cloud LLM.

Reason:
V1 must work offline and avoid API dependency.

Risk:
Parser may not understand complex natural language.

Follow-up needed:
Evaluate optional cloud LLM parser after first IPA release.
```

---

# Code Quality Rules

Agent must follow:

* Effective Dart.
* Flutter lints.
* Riverpod best practices.
* Feature-first organization.
* Clear naming.
* Small focused files where practical.
* Testable business logic.
* No business logic in widgets.
* No direct database access from UI.
* No hardcoded fake production data.
* No secrets in repo.

---

# UI Implementation Rules

Agent must implement UI according to:

```txt
03_UI_SPEC.md
```

Required:

* Bottom navigation.
* Home screen.
* Orders screen.
* Products screen.
* Reports screen.
* More/settings area.
* POS screen.
* AI order screen.
* AI review screen.
* Receipt screen.
* Empty/loading/error states.

UI must not be a raw demo.

Minimum acceptable UI:

* Consistent theme.
* Reusable buttons/cards/inputs.
* Clear Vietnamese text.
* Mobile-friendly spacing.
* Usable on iPhone portrait.
* No broken overflow on normal iPhone sizes.

---

# Database Implementation Rules

Agent must implement database according to:

```txt
04_DATABASE_SPEC.md
```

Required:

* Drift SQLite.
* All required tables.
* Required indexes.
* Migrations.
* Repository layer.
* Transactions for critical operations.
* Integer VND money.
* Snapshot order items.
* Inventory movements.

Agent must not:

* Store money as double.
* Hard delete completed orders.
* Update stock without inventory movement.
* Let UI call database directly.
* Skip migrations entirely.

---

# AI Implementation Rules

Agent must implement AI according to:

```txt
06_AI_SPEC.md
```

Required:

* Voice-to-order.
* Text-to-order.
* Screenshot/chat-to-order.
* Menu image import.
* Product matching.
* AI order review.
* User confirmation.

Agent must not:

* Treat AI as empty placeholder.
* Let AI auto-complete orders.
* Make cloud LLM mandatory.
* Remove manual POS because AI exists.
* Store audio files unnecessarily.
* Store image binary in database.

If speech/OCR package fails, keep feature with best available implementation and safe fallback.

---

# Business Rule Implementation Rules

Agent must implement business rules according to:

```txt
07_BUSINESS_RULES.md
```

Critical:

* Draft orders do not affect inventory.
* Confirmed paid/unpaid sales affect inventory.
* Cancelled/refunded orders restore inventory.
* Completed orders are not hard deleted.
* Historical order item snapshots are preserved.
* Revenue excludes draft/cancelled/refunded orders.
* Expenses affect net profit.
* AI-generated orders must go through review.

---

# Testing Rules

Agent must implement tests according to:

```txt
08_TEST_PLAN.md
```

Required:

* Order calculation tests.
* Inventory tests.
* Parser tests.
* Product matching tests.
* Report tests.
* Backup validation tests.
* Repository tests for critical flows.
* Widget/controller tests for core flows where practical.

Agent must not:

* Delete failing tests.
* Skip critical tests.
* Disable analyzer.
* Remove assertions to pass tests.
* Mock the entire business layer and call it tested.

---

# Release Rules

Agent must implement release according to:

```txt
09_RELEASE_PLAN.md
10_IOS_SIGNING.md
```

Required:

* `flutter-ci.yml`.
* `ios-release.yml`.
* no-codesign iOS build.
* signed IPA path if secrets exist.
* unsigned artifact fallback.
* honest release notes.

Agent must not:

* Claim installable IPA without signing.
* Commit signing assets.
* Make CI dependent on Apple secrets.
* Remove release workflow because signing is missing.

---

# Root Cause Fixing Rules

When fixing issues, agent must prefer root-cause fixes.

Bad:

```txt
Delete failing code.
Delete failing test.
Disable lint rule globally.
Comment out feature.
Skip iOS build.
Remove package without replacement.
```

Good:

```txt
Fix invalid API usage.
Replace incompatible package.
Add missing iOS permission.
Correct database transaction.
Fix broken parser logic.
Update test to match documented business rule.
```

---

# Fallback Rules

Fallbacks are allowed only if they preserve user value.

Allowed fallbacks:

* Voice fails → user can edit recognized text or use text order.
* OCR fails → user can edit extracted text or use text order.
* Signed IPA missing → unsigned artifact + signing docs.
* Dark mode incomplete → light mode stable + limitation recorded.
* Chart package fails → list-based reports.

Not allowed fallbacks:

* Remove voice-to-order completely.
* Remove screenshot-to-order completely.
* Remove inventory deduction.
* Remove tests.
* Make all reports fake/static.
* Make app require Internet.
* Skip receipt export.

---

# Security Rules

Agent must never commit:

```txt
*.p12
*.cer
*.mobileprovision
*.base64.txt
AuthKey_*.p8
.env
API keys
Apple private keys
Certificate passwords
Provisioning profile contents
```

Agent must ensure `.gitignore` protects sensitive artifacts.

Agent must not put secrets in docs.

---

# Privacy Rules

Quico stores sensitive small-business data.

Agent must avoid sending data to external services in v1.

Sensitive data includes:

* Sales.
* Customer names.
* Customer phone numbers.
* Bank account info.
* Screenshots of customer messages.
* Product data.

If any package/service may use network for speech/OCR, document the behavior clearly in `BUILD_SPEC.md`.

---

# Offline Rules

Agent must verify core flows work without Internet.

Offline-required flows:

* Onboarding.
* Product creation.
* Manual order.
* Text order.
* Voice order where platform supports local/available recognition or fallback.
* Screenshot order with local OCR or fallback.
* Inventory.
* Expenses.
* Reports.
* Receipt export.
* Backup export/import.

Do not introduce mandatory login in v1.

---

# Performance Rules

Agent must avoid obviously inefficient implementation.

Required:

* Pagination for large lists.
* Indexed queries.
* No loading all orders for reports if aggregate query can be used.
* Reasonable image loading.
* Avoid unnecessary full-screen rebuilds.

Performance targets:

```txt
Product search < 300ms for 5,000 products where practical
Dashboard summary < 500ms where practical
Order completion < 500ms for normal cart where practical
```

If performance target cannot be verified in environment, document limitation.

---

# Accessibility Rules

Agent must implement minimum accessibility:

* Tap targets at least 44x44.
* Text readable on iPhone.
* Buttons have labels.
* Icon-only buttons have semantic labels where practical.
* Do not rely only on color for status.
* Error messages are visible and readable.

---

# Language Rules

Primary UI language:

```txt
Vietnamese
```

Agent must use simple Vietnamese labels.

Good:

```txt
Tạo đơn
Nói đơn
Ảnh tin nhắn
Không đọc được ảnh
Sản phẩm sắp hết hàng
```

Bad:

```txt
Initialize transaction
AI extraction failed
Mutation error
```

Technical code names can remain English.

---

# Anti-Loop Rules

If agent repeats the same failed approach more than twice:

1. Stop repeating.
2. Summarize the failed attempts internally.
3. Identify a new approach.
4. Try the new approach.
5. Record decision if the new approach changes architecture or package choice.

Agent must not loop through:

* Reinstalling same package without change.
* Running same failing command without code changes.
* Rewriting the same file repeatedly.
* Explaining the same error instead of fixing it.

---

# Completion Tracking

Agent must track progress against the fixed docs.

Minimum checklist:

```txt
[ ] 01_PRODUCT_VISION.md read
[ ] 02_USER_STORIES.md read
[ ] 03_UI_SPEC.md read
[ ] 04_DATABASE_SPEC.md read
[ ] 05_ARCHITECTURE.md read
[ ] 06_AI_SPEC.md read
[ ] 07_BUSINESS_RULES.md read
[ ] 08_TEST_PLAN.md read
[ ] 09_RELEASE_PLAN.md read
[ ] 10_IOS_SIGNING.md read
[ ] 11_AUTONOMOUS_AGENT_RULES.md read
[ ] BUILD_SPEC.md read

[ ] Flutter app initialized
[ ] App shell implemented
[ ] Database implemented
[ ] Onboarding implemented
[ ] Products implemented
[ ] Manual POS implemented
[ ] AI text order implemented
[ ] Voice order implemented
[ ] Screenshot order implemented
[ ] Menu import implemented
[ ] Inventory implemented
[ ] Expenses implemented
[ ] Reports implemented
[ ] Receipts implemented
[ ] Backup implemented
[ ] Tests implemented
[ ] CI implemented
[ ] iOS release workflow implemented
[ ] iOS no-codesign build verified
[ ] Signed IPA path verified or unsigned artifact fallback documented
```

This checklist should be included or mirrored in `BUILD_SPEC.md`.

---

# Definition of Autonomous Completion

The agent's work is complete only when:

* All required app features are implemented.
* Critical business logic is tested.
* `flutter analyze` passes.
* `flutter test` passes.
* iOS no-codesign build passes.
* GitHub Actions exist.
* Release workflow exists.
* Release artifact strategy works.
* Signing requirements are documented.
* No release-blocking issue remains.
* Any known limitation is recorded in `BUILD_SPEC.md`.

---

# Final Instruction To Agent

You are responsible for delivering a working Quico codebase, not just producing plans.

Read the docs.

Implement the product.

Run the commands.

Fix the failures.

Preserve offline-first behavior.

Preserve data integrity.

Preserve AI review requirements.

Preserve the fixed 12-file documentation structure.

Do not stop at a partial demo.

END OF DOCUMENT
