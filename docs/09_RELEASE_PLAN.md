# 09_RELEASE_PLAN.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này mô tả kế hoạch build, kiểm thử, đóng gói và phát hành Quico.

Mục tiêu cuối cùng:

* Source code sạch trên GitHub.
* Flutter app build được.
* Test pass.
* iOS build pass.
* GitHub Actions chạy được.
* GitHub Release có artifact.
* IPA được tạo nếu có Apple signing credentials.
* Nếu thiếu signing credentials, repository vẫn phải tạo được iOS signing-ready artifact và tài liệu rõ ràng.

---

# Release Goal

Quico v1 được xem là có thể release khi:

* App chạy được trên iOS.
* Người dùng có thể tạo sản phẩm.
* Người dùng có thể tạo đơn thủ công.
* Người dùng có thể tạo đơn bằng giọng nói.
* Người dùng có thể tạo đơn bằng văn bản.
* Người dùng có thể tạo đơn từ ảnh tin nhắn.
* Người dùng có thể import sản phẩm từ ảnh menu.
* Người dùng có thể xem báo cáo.
* Người dùng có thể xuất/chia sẻ hóa đơn.
* Dữ liệu hoạt động offline.
* GitHub Actions chạy analyze/test/build.
* Release artifact được upload.

---

# Release Types

Quico hỗ trợ 3 loại release.

---

## 1. Development Build

Mục đích:

* Dùng để test nội bộ.
* Không cần signing chính thức.
* Có thể chạy trên simulator.

Command:

```bash
flutter run
```

hoặc:

```bash
flutter build ios --debug --no-codesign
```

---

## 2. Unsigned / No-Codesign iOS Build

Mục đích:

* Xác nhận project build được cho iOS.
* Dùng trong CI khi chưa có Apple credentials.
* Không phải IPA cài trực tiếp lên iPhone thật.

Command:

```bash
flutter build ios --release --no-codesign
```

Expected result:

* iOS release build generated.
* Build confirms codebase is iOS-compatible.
* Artifact can be uploaded to GitHub Actions.

---

## 3. Signed IPA Release

Mục đích:

* File `.ipa` cài được trên iPhone nếu signing/profile hợp lệ.
* Upload lên GitHub Release.

Yêu cầu:

* Apple Developer account.
* Valid certificate.
* Valid provisioning profile.
* Bundle ID.
* Team ID.
* GitHub Secrets configured.

Signing details are defined in:

```txt
docs/10_IOS_SIGNING.md
```

---

# Release Channels

V1 release channel:

```txt
GitHub Release
```

Future release channels:

```txt
TestFlight
App Store
Internal distribution
```

V1 không bắt buộc App Store.

---

# Versioning

Use semantic versioning:

```txt
MAJOR.MINOR.PATCH
```

Example:

```txt
1.0.0
1.0.1
1.1.0
```

Git tags must use:

```txt
v1.0.0
v1.0.1
v1.1.0
```

---

# Build Number Strategy

Flutter version format:

```yaml
version: 1.0.0+1
```

Format:

```txt
version_name+build_number
```

Example:

```txt
1.0.0+1
1.0.1+2
1.1.0+3
```

Rules:

* `version_name` follows semantic versioning.
* `build_number` always increases.
* Every release tag must match `version_name`.

---

# Required GitHub Workflows

Repository must include:

```txt
.github/workflows/flutter-ci.yml
.github/workflows/ios-release.yml
```

Do not create extra workflow files unless needed.

---

# Workflow 1: flutter-ci.yml

Purpose:

* Validate code on every push and pull request.
* Run format, analyze, and tests.
* Does not require Apple signing secrets.
* Must be fast and reliable.

Trigger:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

Required jobs:

* Checkout.
* Setup Flutter.
* Install dependencies.
* Format check.
* Analyze.
* Test.

Required commands:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

---

# flutter-ci.yml Reference

```yaml
name: Flutter CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  analyze-and-test:
    name: Analyze and Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Show Flutter version
        run: flutter --version

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test
```

---

# Workflow 2: ios-release.yml

Purpose:

* Build iOS release artifact.
* Create unsigned artifact if signing is unavailable.
* Create signed IPA if signing secrets are available.
* Upload artifact to GitHub Release on tag push.

Trigger:

```yaml
on:
  push:
    tags:
      - 'v*'
```

Required behavior:

* Always run tests before release build.
* Build no-codesign iOS artifact as fallback.
* Attempt signed IPA only when secrets are configured.
* Upload available artifacts.
* Create GitHub Release.

---

# iOS Release Modes

The release workflow must support two modes:

```txt
unsigned
signed
```

---

## Unsigned Mode

Used when signing secrets are missing.

Must run:

```bash
flutter build ios --release --no-codesign
```

Must upload:

```txt
build/ios/iphoneos/Runner.app
```

or archived compressed artifact:

```txt
quico-ios-unsigned.zip
```

Expected GitHub Release note:

```txt
This release contains an unsigned iOS build artifact.
A signed IPA requires Apple signing credentials.
See docs/10_IOS_SIGNING.md.
```

---

## Signed Mode

Used when signing secrets exist.

Must produce:

```txt
Quico.ipa
```

Must upload:

```txt
Quico.ipa
```

Expected GitHub Release note:

```txt
This release contains a signed IPA.
Installability depends on the provisioning profile used for signing.
```

---

# ios-release.yml Reference

This workflow is a reference implementation. Developer may adjust implementation if required by Flutter/iOS signing constraints, but the final behavior must remain the same.

```yaml
name: iOS Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  build-ios:
    name: Build iOS
    runs-on: macos-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Show Flutter version
        run: flutter --version

      - name: Install dependencies
        run: flutter pub get

      - name: Check formatting
        run: dart format --set-exit-if-changed .

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build unsigned iOS app
        run: flutter build ios --release --no-codesign

      - name: Package unsigned iOS artifact
        run: |
          mkdir -p release_artifacts
          ditto -c -k --sequesterRsrc --keepParent build/ios/iphoneos/Runner.app release_artifacts/quico-ios-unsigned.zip

      - name: Check signing secrets
        id: signing
        shell: bash
        run: |
          if [[ -n "${{ secrets.IOS_CERTIFICATE_BASE64 }}" && -n "${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}" && -n "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" && -n "${{ secrets.IOS_TEAM_ID }}" && -n "${{ secrets.IOS_BUNDLE_ID }}" ]]; then
            echo "available=true" >> "$GITHUB_OUTPUT"
          else
            echo "available=false" >> "$GITHUB_OUTPUT"
          fi

      - name: Prepare signing files
        if: steps.signing.outputs.available == 'true'
        shell: bash
        run: |
          mkdir -p "$RUNNER_TEMP/signing"
          echo "${{ secrets.IOS_CERTIFICATE_BASE64 }}" | base64 --decode > "$RUNNER_TEMP/signing/certificate.p12"
          echo "${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}" | base64 --decode > "$RUNNER_TEMP/signing/profile.mobileprovision"

      - name: Install signing certificate
        if: steps.signing.outputs.available == 'true'
        shell: bash
        run: |
          KEYCHAIN_PATH="$RUNNER_TEMP/app-signing.keychain-db"
          KEYCHAIN_PASSWORD="$(openssl rand -base64 24)"

          security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
          security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

          security import "$RUNNER_TEMP/signing/certificate.p12" \
            -P "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" \
            -A \
            -t cert \
            -f pkcs12 \
            -k "$KEYCHAIN_PATH"

          security list-keychain -d user -s "$KEYCHAIN_PATH"
          security default-keychain -s "$KEYCHAIN_PATH"

      - name: Install provisioning profile
        if: steps.signing.outputs.available == 'true'
        shell: bash
        run: |
          mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
          UUID=$(/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< "$(security cms -D -i "$RUNNER_TEMP/signing/profile.mobileprovision")")
          cp "$RUNNER_TEMP/signing/profile.mobileprovision" "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"

      - name: Build signed IPA
        if: steps.signing.outputs.available == 'true'
        shell: bash
        run: |
          flutter build ipa --release \
            --export-options-plist=ios/ExportOptions.plist

          mkdir -p release_artifacts
          find build/ios/ipa -name "*.ipa" -exec cp {} release_artifacts/Quico.ipa \;

      - name: Create release notes
        shell: bash
        run: |
          mkdir -p release_artifacts
          cat > release_artifacts/RELEASE_NOTES.md <<'EOF'
          # Quico Release

          This release was generated by GitHub Actions.

          Artifacts:
          - Quico.ipa if Apple signing secrets were available.
          - quico-ios-unsigned.zip as unsigned fallback artifact.

          If the IPA is missing, configure Apple signing secrets according to docs/10_IOS_SIGNING.md.
          EOF

      - name: Upload GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body_path: release_artifacts/RELEASE_NOTES.md
          files: |
            release_artifacts/*
```

---

# ExportOptions.plist

For signed IPA, the project should include:

```txt
ios/ExportOptions.plist
```

The exact export method depends on the provisioning profile.

Common methods:

```txt
development
ad-hoc
app-store
enterprise
```

For direct IPA installation outside App Store, use:

```txt
development
```

or:

```txt
ad-hoc
```

depending on the certificate/profile.

Example for development/ad-hoc style signing:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>method</key>
    <string>development</string>

    <key>signingStyle</key>
    <string>manual</string>

    <key>stripSwiftSymbols</key>
    <true/>

    <key>compileBitcode</key>
    <false/>

    <key>teamID</key>
    <string>$(IOS_TEAM_ID)</string>
  </dict>
</plist>
```

Developer must adjust this file if Xcode export requires exact provisioning profile mapping.

Any adjustment must be recorded in:

```txt
BUILD_SPEC.md
```

under:

```txt
Decision Log / Technical Debt
```

---

# Release Artifacts

Every GitHub Release should include at least one artifact.

Preferred artifacts:

```txt
Quico.ipa
quico-ios-unsigned.zip
```

Optional artifacts:

```txt
release-notes.md
test-results.zip
coverage-report.zip
```

Required minimum if signing unavailable:

```txt
quico-ios-unsigned.zip
```

Required minimum if signing available:

```txt
Quico.ipa
```

---

# IPA Reality Rules

A `.ipa` that can be installed on a physical iPhone requires valid Apple signing.

The developer/agent must not claim a real installable IPA exists unless:

* Certificate is installed.
* Provisioning profile is installed.
* Bundle ID matches.
* Team ID matches.
* `flutter build ipa` succeeds.
* `.ipa` file exists.
* IPA is uploaded as release artifact.

If signing is missing, the correct output is:

```txt
Signing-ready iOS build artifact
```

not:

```txt
Installable IPA
```

---

# Required GitHub Secrets

The release workflow may use manual signing secrets.

Required for signed IPA:

```txt
IOS_CERTIFICATE_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_TEAM_ID
IOS_BUNDLE_ID
```

Optional if App Store Connect / Fastlane is used:

```txt
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY
MATCH_PASSWORD
```

Exact signing setup is defined in:

```txt
10_IOS_SIGNING.md
```

---

# Bundle ID

Default Bundle ID:

```txt
dev.hieuck.quico
```

Rules:

* Bundle ID must be consistent in Flutter iOS project.
* Bundle ID must match Apple Developer provisioning profile.
* Bundle ID must match GitHub secret `IOS_BUNDLE_ID`.

If changed, update:

```txt
ios/Runner.xcodeproj
ios/Runner/Info.plist if needed
ios/ExportOptions.plist
GitHub Secrets
10_IOS_SIGNING.md
```

---

# Release Branch Strategy

Primary branch:

```txt
main
```

Rules:

* `main` should remain buildable.
* Releases are created from tags on `main`.
* Feature branches are optional.
* Do not tag release from broken branch.

---

# Release Tag Process

Manual release process:

```bash
git checkout main
git pull
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions should then:

* Run release workflow.
* Build iOS.
* Upload artifacts.
* Create GitHub Release.

---

# Pre-Release Checklist

Before creating tag:

## Code Quality

* [ ] `dart format --set-exit-if-changed .` passes.
* [ ] `flutter analyze` passes.
* [ ] `flutter test` passes.
* [ ] No critical warnings.
* [ ] No debug-only fake data in production flow.
* [ ] No hardcoded secrets.

## Product Flows

* [ ] Onboarding works.
* [ ] Product creation works.
* [ ] Product image works.
* [ ] Manual order works.
* [ ] Voice order works.
* [ ] Text order works.
* [ ] Screenshot order works.
* [ ] Menu image import works.
* [ ] Customer management works.
* [ ] Inventory deduction works.
* [ ] Expense tracking works.
* [ ] Reports work.
* [ ] Receipt export works.
* [ ] Backup export/import works.

## Offline

* [ ] App can create product offline.
* [ ] App can create order offline.
* [ ] App can view reports offline.
* [ ] App can export receipt offline.
* [ ] App does not require login.

## iOS

* [ ] iOS permissions are configured.
* [ ] `Info.plist` contains camera permission text.
* [ ] `Info.plist` contains photo permission text.
* [ ] `Info.plist` contains microphone permission text.
* [ ] `Info.plist` contains speech recognition permission text.
* [ ] `flutter build ios --release --no-codesign` passes.
* [ ] Signed IPA build passes if signing secrets are available.

## Documentation

* [ ] README exists.
* [ ] `docs/01_PRODUCT_VISION.md` exists.
* [ ] `docs/02_USER_STORIES.md` exists.
* [ ] `docs/03_UI_SPEC.md` exists.
* [ ] `docs/04_DATABASE_SPEC.md` exists.
* [ ] `docs/05_ARCHITECTURE.md` exists.
* [ ] `docs/06_AI_SPEC.md` exists.
* [ ] `docs/07_BUSINESS_RULES.md` exists.
* [ ] `docs/08_TEST_PLAN.md` exists.
* [ ] `docs/09_RELEASE_PLAN.md` exists.
* [ ] `docs/10_IOS_SIGNING.md` exists.
* [ ] `docs/11_AUTONOMOUS_AGENT_RULES.md` exists.
* [ ] `docs/BUILD_SPEC.md` exists.

---

# Release Notes Format

Each release must include clear notes.

Template:

```md
# Quico vX.Y.Z

## Summary

Short description of this release.

## Features

- Feature 1
- Feature 2
- Feature 3

## Fixes

- Fix 1
- Fix 2

## Artifacts

- Quico.ipa if signing credentials were available.
- quico-ios-unsigned.zip as fallback unsigned iOS artifact.

## Install Notes

Signed IPA requires a valid provisioning profile.

If IPA is missing, configure Apple signing secrets according to docs/10_IOS_SIGNING.md.

## Known Limitations

- Limitation 1
- Limitation 2
```

---

# Known Limitations Policy

Known limitations must be honest.

Allowed:

```txt
Voice recognition depends on device/platform availability.
OCR accuracy depends on screenshot quality.
Signed IPA requires Apple Developer credentials.
```

Not allowed:

```txt
Everything works perfectly.
Production ready without testing.
IPA available when it was not created.
```

If a limitation affects release quality, record it in:

```txt
BUILD_SPEC.md
```

under:

```txt
Decision Log / Technical Debt
```

---

# Release Blocking Issues

The following issues block release:

* App cannot launch.
* Onboarding broken.
* Product creation broken.
* Manual order broken.
* Order calculation incorrect.
* Inventory deduction incorrect.
* Reports show incorrect numbers.
* Receipt cannot be generated.
* `flutter analyze` fails.
* `flutter test` fails.
* iOS no-codesign build fails.
* App requires Internet for core selling flow.
* AI order result can bypass review.
* Completed orders can be hard-deleted.
* Money stored/calculated as floating point.
* Secrets committed to repository.

---

# Release Non-Blocking Issues

The following issues do not block release if documented:

* Full dark mode polish incomplete.
* Advanced charts missing.
* Cloud sync missing.
* App Store/TestFlight not configured.
* Signed IPA missing because Apple credentials are not provided.
* OCR imperfect on low-quality images.
* Voice recognition imperfect in noisy environment.
* Advanced debt tracking incomplete.
* Barcode scanner missing.
* Printer integration missing.

Non-blocking issues must be recorded in:

```txt
BUILD_SPEC.md
```

under:

```txt
Decision Log / Technical Debt
```

---

# Build Verification Commands

Run before release:

```bash
flutter clean
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

If signing is configured:

```bash
flutter build ipa --release
```

If using manual export options:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

---

# Artifact Naming

Use consistent artifact names:

```txt
Quico.ipa
quico-ios-unsigned.zip
quico-test-results.zip
quico-coverage.zip
```

Do not use random names like:

```txt
build.zip
app.zip
Runner.zip
final.zip
```

---

# Release Failure Handling

If release workflow fails:

Developer/agent must:

1. Read the failing step.
2. Identify root cause.
3. Fix the issue.
4. Re-run relevant command locally if possible.
5. Commit fix.
6. Re-tag if needed.
7. Do not disable checks to pass release.

If a tag already exists and release failed:

Preferred process:

```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
git tag v1.0.0
git push origin v1.0.0
```

or create a patch tag:

```bash
git tag v1.0.1
git push origin v1.0.1
```

Use patch tag if release artifact was already published.

---

# GitHub Release Acceptance Criteria

A GitHub Release is valid only when:

* Release is attached to semantic version tag.
* Release notes exist.
* At least one iOS artifact is uploaded.
* Signed IPA is uploaded if signing secrets are configured.
* Unsigned artifact is uploaded if signing secrets are missing.
* CI commands passed before release.
* Release does not make false claims about installability.

---

# IPA Acceptance Criteria

A signed IPA is valid only when:

* `Quico.ipa` exists.
* IPA is produced by `flutter build ipa` or equivalent Xcode archive/export process.
* Bundle ID matches provisioning profile.
* Team ID matches certificate/profile.
* IPA is uploaded to GitHub Release.
* Release notes mention signing/distribution type.
* Installation expectation is accurate.

---

# Unsigned Artifact Acceptance Criteria

Unsigned artifact is valid only when:

* `flutter build ios --release --no-codesign` passes.
* `Runner.app` is packaged.
* Artifact uploaded to GitHub Release or Actions artifact.
* Release notes clearly say it is unsigned.
* Documentation points to `10_IOS_SIGNING.md` for signed IPA.

---

# README Release Section Requirements

README must include:

````md
## Build

```bash
flutter pub get
flutter analyze
flutter test
flutter build ios --release --no-codesign
````

## Release

Create a tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will create a release artifact.

Signed IPA requires Apple signing credentials. See `docs/10_IOS_SIGNING.md`.

```

---

# Developer / Agent Release Rules

The developer/agent must not:

- Claim IPA exists if it was not generated.
- Ignore failed tests.
- Disable GitHub Actions checks.
- Remove features to make release pass.
- Commit Apple certificates directly to repository.
- Commit provisioning profiles directly to repository.
- Commit API keys or secrets.
- Create release from broken code.
- Skip no-codesign iOS build.
- Leave release workflow as placeholder.

The developer/agent must:

- Keep release pipeline functional.
- Keep normal CI independent from signing secrets.
- Document signing requirements.
- Upload the best valid artifact available.
- Be explicit about signed vs unsigned output.
- Preserve the fixed documentation structure.

---

# Final Release Definition of Done

Release work is complete only when:

- `flutter-ci.yml` exists.
- `ios-release.yml` exists.
- `flutter analyze` passes.
- `flutter test` passes.
- `flutter build ios --release --no-codesign` passes.
- Release workflow runs on `v*` tag.
- GitHub Release is created.
- Artifact is uploaded.
- Signed IPA is uploaded if signing credentials exist.
- Unsigned artifact is uploaded if signing credentials are missing.
- Release notes are honest.
- `10_IOS_SIGNING.md` explains how to enable signed IPA.
- No secrets are committed.
- No release-blocking issue remains.

END OF DOCUMENT
```
