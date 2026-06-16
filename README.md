# Quico

> Ban hang de nhu nhan tin.

Ung dung quan ly ban hang mien phi, offline-first, uu tien di dong, danh cho ho kinh doanh nho.

## Tinh nang chinh

- Quan ly san pham co hinh anh
- Tao don hang thu cong
- Tao don bang giong noi
- Tao don bang van ban
- Tao don tu anh tin nhan (OCR)
- Import san pham tu anh menu
- Quan ly khach hang
- Theo doi ton kho
- Ghi chep chi phi
- Bao cao doanh thu va loi nhuan
- Xuat/chia se hoa don
- Sao luu & phuc hoi du lieu
- Hoat dong offline hoan toan

## Tech Stack

| Layer | Cong nghe |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod |
| Routing | GoRouter |
| Database | Drift (SQLite) |
| Speech | speech_to_text |
| OCR | google_mlkit_text_recognition |
| PDF | pdf + printing |
| CI/CD | GitHub Actions |

## Yeu cau

- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0
- macOS (de build iOS)
- Python 3 (de chay code check pre-commit)

## Cai dat pre-commit hook

```bash
git config core.hooksPath .githooks
```

## Chay thu

```bash
flutter pub get
flutter run
```

## Kiem tra code

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Build iOS

```bash
flutter build ios --release --no-codesign
```

## Release

Tao tag de trigger GitHub Actions:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Signed IPA can Apple signing credentials. Xem `docs/10_IOS_SIGNING.md`.

## Tai lieu

Xem thu muc `docs/`:

- [Product Vision](docs/01_PRODUCT_VISION.md)
- [User Stories](docs/02_USER_STORIES.md)
- [UI Spec](docs/03_UI_SPEC.md)
- [Database Spec](docs/04_DATABASE_SPEC.md)
- [Architecture](docs/05_ARCHITECTURE.md)
- [AI Spec](docs/06_AI_SPEC.md)
- [Business Rules](docs/07_BUSINESS_RULES.md)
- [Test Plan](docs/08_TEST_PLAN.md)
- [Release Plan](docs/09_RELEASE_PLAN.md)
- [iOS Signing](docs/10_IOS_SIGNING.md)
- [Agent Rules](docs/11_AUTONOMOUS_AGENT_RULES.md)
- [Build Spec](docs/BUILD_SPEC.md)

## Ghi chu

Ung dung nay hoat dong offline hoan toan, khong can tai khoan hay Internet de ban hang.
