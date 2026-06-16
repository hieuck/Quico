# 10_IOS_SIGNING.md

Version: 1.0

Status: Approved

---

# Purpose

Tài liệu này định nghĩa chiến lược ký iOS cho Quico.

Mục tiêu:

* Làm rõ điều kiện để tạo file `.ipa` cài được trên iPhone.
* Tách biệt giữa unsigned iOS build và signed IPA.
* Định nghĩa GitHub Secrets cần thiết.
* Định nghĩa cấu hình signing cho GitHub Actions.
* Đảm bảo không commit certificate, provisioning profile hoặc secret vào repository.
* Đảm bảo release pipeline vẫn hoạt động ngay cả khi chưa có Apple signing credentials.

---

# iOS Signing Reality

Một file `.ipa` cài được trên iPhone thật cần Apple signing hợp lệ.

Signed IPA yêu cầu:

* Apple Developer Account.
* iOS signing certificate.
* Provisioning profile.
* Bundle ID khớp với provisioning profile.
* Team ID khớp với certificate/profile.
* Xcode export configuration hợp lệ.

Nếu thiếu các thông tin trên, Quico vẫn phải build được:

```txt
flutter build ios --release --no-codesign
```

nhưng đó là unsigned iOS artifact, không phải IPA cài trực tiếp lên iPhone thật.

---

# Release Output Types

Quico hỗ trợ hai loại iOS output.

---

## 1. Unsigned iOS Artifact

Tên artifact:

```txt
quico-ios-unsigned.zip
```

Nguồn build:

```txt
build/ios/iphoneos/Runner.app
```

Command:

```bash
flutter build ios --release --no-codesign
```

Tính chất:

* Không cần Apple certificate.
* Không cần provisioning profile.
* Có thể dùng để xác nhận project build được cho iOS.
* Không phải file IPA cài trực tiếp trên iPhone thật.

---

## 2. Signed IPA

Tên artifact:

```txt
Quico.ipa
```

Command:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

Tính chất:

* Cần Apple signing credentials.
* Có thể cài lên thiết bị phù hợp với provisioning profile.
* Có thể upload lên GitHub Release.
* Có thể dùng cho internal/ad-hoc/test distribution tùy certificate/profile.

---

# Default Bundle ID

Bundle ID mặc định của Quico:

```txt
dev.hieuck.quico
```

Rules:

* Bundle ID trong Flutter/Xcode project phải khớp với Apple Developer portal.
* Bundle ID trong provisioning profile phải khớp.
* GitHub Secret `IOS_BUNDLE_ID` phải khớp.
* Nếu đổi Bundle ID, phải cập nhật toàn bộ iOS project và GitHub Secrets.

---

# Required Apple Information

Signed IPA cần các thông tin sau:

```txt
Apple Team ID
Bundle ID
Signing Certificate
Provisioning Profile
Certificate Password
Export Method
```

---

# Signing Methods

Quico hỗ trợ hai chiến lược signing.

---

## Option A: Manual Signing

Manual signing là chiến lược mặc định cho v1.

Sử dụng:

* `.p12` certificate.
* `.mobileprovision` provisioning profile.
* GitHub Secrets chứa certificate/profile dạng base64.

Ưu điểm:

* Dễ hiểu.
* Không cần Fastlane Match.
* Phù hợp với repo đơn giản.
* Dễ dùng với GitHub Actions.

Nhược điểm:

* Cần quản lý certificate/profile thủ công.
* Cần cập nhật khi profile hết hạn.

---

## Option B: Fastlane Match

Fastlane Match có thể dùng trong tương lai.

Ưu điểm:

* Quản lý signing chuyên nghiệp hơn.
* Phù hợp team nhiều người.
* Phù hợp App Store/TestFlight pipeline.

Nhược điểm:

* Cần thêm setup.
* Cần repo riêng để lưu encrypted signing assets.
* Không cần thiết cho v1 nếu mục tiêu chỉ là GitHub IPA.

V1 ưu tiên:

```txt
Option A: Manual Signing
```

---

# Required GitHub Secrets For Manual Signing

GitHub repository phải hỗ trợ các secrets sau:

```txt
IOS_CERTIFICATE_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_TEAM_ID
IOS_BUNDLE_ID
IOS_EXPORT_METHOD
IOS_PROVISIONING_PROFILE_NAME
```

---

# Secret: IOS_CERTIFICATE_BASE64

Purpose:

* Chứa nội dung certificate `.p12` ở dạng base64.

Source file:

```txt
certificate.p12
```

Example encode command on macOS:

```bash
base64 -i certificate.p12 | pbcopy
```

Alternative:

```bash
base64 certificate.p12 > certificate.base64.txt
```

Security rule:

* Không commit `.p12`.
* Không commit file `.base64.txt`.
* Chỉ lưu vào GitHub Secrets.

---

# Secret: IOS_CERTIFICATE_PASSWORD

Purpose:

* Password dùng để import `.p12` certificate.

Security rule:

* Không commit password.
* Không ghi password trong README.
* Không ghi password trong docs.
* Chỉ lưu trong GitHub Secrets.

---

# Secret: IOS_PROVISIONING_PROFILE_BASE64

Purpose:

* Chứa nội dung provisioning profile `.mobileprovision` dạng base64.

Source file:

```txt
profile.mobileprovision
```

Example encode command on macOS:

```bash
base64 -i profile.mobileprovision | pbcopy
```

Alternative:

```bash
base64 profile.mobileprovision > profile.base64.txt
```

Security rule:

* Không commit `.mobileprovision`.
* Không commit file `.base64.txt`.
* Chỉ lưu vào GitHub Secrets.

---

# Secret: IOS_TEAM_ID

Purpose:

* Apple Developer Team ID.

Example format:

```txt
ABCDE12345
```

Rules:

* Must match certificate.
* Must match provisioning profile.
* Must match Xcode project signing team.

---

# Secret: IOS_BUNDLE_ID

Purpose:

* Bundle ID của app.

Default value:

```txt
dev.hieuck.quico
```

Rules:

* Must match Xcode project Bundle Identifier.
* Must match provisioning profile App ID.
* Must match export options.

---

# Secret: IOS_EXPORT_METHOD

Purpose:

* Xcode export method.

Allowed common values:

```txt
development
ad-hoc
app-store
enterprise
```

Recommended for direct testing:

```txt
development
```

or:

```txt
ad-hoc
```

Use `app-store` only when preparing for App Store/TestFlight style distribution.

Default for GitHub IPA testing:

```txt
development
```

---

# Secret: IOS_PROVISIONING_PROFILE_NAME

Purpose:

* Name of the provisioning profile used for manual signing/export.

Example:

```txt
Quico Development Profile
```

This value may be needed inside `ExportOptions.plist`.

---

# Optional GitHub Secrets For Future Fastlane/App Store Connect

These are optional for v1.

```txt
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_ISSUER_ID
APP_STORE_CONNECT_API_KEY
MATCH_PASSWORD
MATCH_GIT_URL
```

Do not require these for basic GitHub Release IPA.

---

# iOS Project Configuration

The Flutter iOS project must be configured consistently.

Required locations:

```txt
ios/Runner.xcodeproj
ios/Runner/Info.plist
ios/Runner/Runner.entitlements if needed
ios/ExportOptions.plist
```

---

# Info.plist Requirements

Quico uses:

* Camera.
* Photo library.
* Microphone.
* Speech recognition.

Therefore `ios/Runner/Info.plist` must contain:

```xml
<key>NSCameraUsageDescription</key>
<string>Quico cần quyền camera để chụp ảnh sản phẩm, menu hoặc tin nhắn.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Quico cần quyền ảnh để chọn ảnh sản phẩm, menu hoặc ảnh tin nhắn.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Quico cần quyền micro để tạo đơn bằng giọng nói.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Quico cần quyền nhận dạng giọng nói để chuyển lời nói thành đơn hàng.</string>
```

Rules:

* Permission text must be Vietnamese-friendly.
* Do not request all permissions on first launch.
* Request permissions contextually.

---

# ExportOptions.plist

The repository should include:

```txt
ios/ExportOptions.plist
```

This file controls how Xcode exports the IPA.

Recommended template:

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
    <string>TEAM_ID_PLACEHOLDER</string>

    <key>provisioningProfiles</key>
    <dict>
      <key>dev.hieuck.quico</key>
      <string>PROFILE_NAME_PLACEHOLDER</string>
    </dict>
  </dict>
</plist>
```

During CI, placeholders may be replaced with secrets:

```txt
TEAM_ID_PLACEHOLDER -> IOS_TEAM_ID
PROFILE_NAME_PLACEHOLDER -> IOS_PROVISIONING_PROFILE_NAME
dev.hieuck.quico -> IOS_BUNDLE_ID if Bundle ID changed
```

---

# Export Method Selection

## development

Use when:

* Testing on devices registered in Apple Developer account.
* Using development certificate/profile.

## ad-hoc

Use when:

* Distributing to specific registered devices.
* Using ad-hoc provisioning profile.

## app-store

Use when:

* Preparing for App Store or TestFlight upload.

## enterprise

Use only if the Apple Developer account supports enterprise distribution.

---

# Recommended V1 Signing Strategy

For Quico v1:

```txt
Export method: development or ad-hoc
Distribution: GitHub Release
Artifact: Quico.ipa
```

If the goal is to install directly on a specific iPhone:

* Use development/ad-hoc profile.
* Make sure the device UDID is included in provisioning profile.
* Build signed IPA with matching certificate/profile.

---

# GitHub Actions Signing Flow

The release workflow must perform these steps when signing secrets exist:

```txt
1. Decode certificate from IOS_CERTIFICATE_BASE64
2. Decode provisioning profile from IOS_PROVISIONING_PROFILE_BASE64
3. Create temporary keychain
4. Import certificate into keychain
5. Install provisioning profile
6. Patch ExportOptions.plist if needed
7. Run flutter build ipa
8. Copy generated IPA to release_artifacts/Quico.ipa
9. Upload IPA to GitHub Release
```

---

# Signing Secret Detection

The workflow must detect signing availability.

Signing is available only if all required manual signing secrets exist:

```txt
IOS_CERTIFICATE_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_TEAM_ID
IOS_BUNDLE_ID
IOS_EXPORT_METHOD
IOS_PROVISIONING_PROFILE_NAME
```

If any required secret is missing:

* Do not attempt signed IPA.
* Build unsigned iOS artifact.
* Upload unsigned artifact.
* Release notes must clearly state signed IPA was not generated.

---

# GitHub Actions Signing Script Reference

Reference script:

```bash
set -euo pipefail

SIGNING_DIR="$RUNNER_TEMP/signing"
mkdir -p "$SIGNING_DIR"

echo "$IOS_CERTIFICATE_BASE64" | base64 --decode > "$SIGNING_DIR/certificate.p12"
echo "$IOS_PROVISIONING_PROFILE_BASE64" | base64 --decode > "$SIGNING_DIR/profile.mobileprovision"

KEYCHAIN_PATH="$RUNNER_TEMP/quico-signing.keychain-db"
KEYCHAIN_PASSWORD="$(openssl rand -base64 24)"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

security import "$SIGNING_DIR/certificate.p12" \
  -P "$IOS_CERTIFICATE_PASSWORD" \
  -A \
  -t cert \
  -f pkcs12 \
  -k "$KEYCHAIN_PATH"

security list-keychain -d user -s "$KEYCHAIN_PATH"
security default-keychain -s "$KEYCHAIN_PATH"

mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"

PROFILE_UUID=$(
  security cms -D -i "$SIGNING_DIR/profile.mobileprovision" \
  | /usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin
)

cp "$SIGNING_DIR/profile.mobileprovision" \
  "$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
```

---

# ExportOptions Patch Script Reference

Reference script:

```bash
set -euo pipefail

EXPORT_OPTIONS="ios/ExportOptions.plist"

if [[ ! -f "$EXPORT_OPTIONS" ]]; then
  echo "Missing $EXPORT_OPTIONS"
  exit 1
fi

/usr/libexec/PlistBuddy -c "Set :method $IOS_EXPORT_METHOD" "$EXPORT_OPTIONS" || true
/usr/libexec/PlistBuddy -c "Set :teamID $IOS_TEAM_ID" "$EXPORT_OPTIONS" || true

/usr/libexec/PlistBuddy -c "Delete :provisioningProfiles" "$EXPORT_OPTIONS" || true
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" "$EXPORT_OPTIONS"
/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:$IOS_BUNDLE_ID string $IOS_PROVISIONING_PROFILE_NAME" "$EXPORT_OPTIONS"
```

---

# Build IPA Command

Signed build command:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

After build, IPA should be found in:

```txt
build/ios/ipa/
```

The workflow must copy the final IPA to:

```txt
release_artifacts/Quico.ipa
```

---

# Unsigned Fallback Build

If signing secrets are unavailable, the workflow must run:

```bash
flutter build ios --release --no-codesign
```

Then package:

```txt
build/ios/iphoneos/Runner.app
```

as:

```txt
release_artifacts/quico-ios-unsigned.zip
```

Reference command:

```bash
mkdir -p release_artifacts
ditto -c -k --sequesterRsrc --keepParent \
  build/ios/iphoneos/Runner.app \
  release_artifacts/quico-ios-unsigned.zip
```

---

# Release Notes Requirements

If signed IPA exists, release notes must say:

```txt
This release includes a signed IPA: Quico.ipa.
Installability depends on the provisioning profile used for signing.
```

If signed IPA does not exist, release notes must say:

```txt
This release does not include a signed IPA because Apple signing secrets were not configured.
The unsigned iOS build artifact is included for build verification.
See docs/10_IOS_SIGNING.md for signing requirements.
```

The release must not claim installability unless signed IPA exists.

---

# Local Signing Build

Local signed build may be done from macOS with Xcode and valid Apple account.

Required checks:

```bash
flutter pub get
flutter analyze
flutter test
flutter build ios --release --no-codesign
```

Then signed IPA:

```bash
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

If Xcode project uses automatic signing locally, developer may build through Xcode, but CI must still support manual signing through secrets.

---

# Local No-Codesign Build

Command:

```bash
flutter build ios --release --no-codesign
```

Use this to verify:

* Flutter iOS project compiles.
* iOS dependencies work.
* Native plugin configuration is valid.
* Permission plist is valid enough for compile.

This does not verify installable IPA.

---

# Security Rules

The following files must never be committed:

```txt
*.p12
*.cer
*.mobileprovision
*.base64.txt
AuthKey_*.p8
fastlane/Appfile with secrets
fastlane/Matchfile with private credentials
```

The following must never appear in repository:

```txt
Certificate password
Apple private key
App Store Connect API private key
Provisioning profile raw content
Base64 encoded certificate
Base64 encoded provisioning profile
```

---

# .gitignore Requirements

`.gitignore` must include:

```gitignore
# iOS signing secrets
*.p12
*.cer
*.mobileprovision
*.base64.txt
AuthKey_*.p8

# Release artifacts
*.ipa
release_artifacts/
build/

# Fastlane sensitive files
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
```

Do not ignore required source files such as:

```txt
ios/ExportOptions.plist
```

because the export configuration should be committed without secrets.

---

# Certificate Rotation

If certificate expires or is revoked:

Required action:

1. Generate or export new certificate.
2. Export `.p12`.
3. Encode as base64.
4. Update `IOS_CERTIFICATE_BASE64`.
5. Update `IOS_CERTIFICATE_PASSWORD` if changed.
6. Verify provisioning profile still matches.
7. Re-run release workflow.

---

# Provisioning Profile Rotation

If provisioning profile expires or device list changes:

Required action:

1. Generate updated provisioning profile.
2. Download `.mobileprovision`.
3. Encode as base64.
4. Update `IOS_PROVISIONING_PROFILE_BASE64`.
5. Update `IOS_PROVISIONING_PROFILE_NAME` if changed.
6. Verify Bundle ID and Team ID.
7. Re-run release workflow.

---

# Common Failure Cases

## Failure: No signing certificate found

Likely causes:

* `IOS_CERTIFICATE_BASE64` invalid.
* `.p12` password wrong.
* Certificate import failed.
* Certificate does not contain private key.

Required fix:

* Re-export `.p12` with private key.
* Verify password.
* Update GitHub Secrets.

---

## Failure: Provisioning profile does not match Bundle ID

Likely causes:

* `IOS_BUNDLE_ID` wrong.
* Xcode project Bundle ID different.
* Provisioning profile created for another App ID.

Required fix:

* Align Bundle ID across Xcode project, profile and GitHub Secrets.

---

## Failure: Team ID mismatch

Likely causes:

* Certificate from one Apple team.
* Provisioning profile from another Apple team.
* `IOS_TEAM_ID` wrong.

Required fix:

* Use certificate and profile from same Apple Developer team.
* Update `IOS_TEAM_ID`.

---

## Failure: ExportOptions.plist method mismatch

Likely causes:

* `development` profile used with `app-store` export method.
* `ad-hoc` profile used with wrong export method.

Required fix:

* Set `IOS_EXPORT_METHOD` to match profile type.

---

## Failure: IPA builds but cannot install

Likely causes:

* Device UDID not included in provisioning profile.
* Provisioning profile expired.
* Certificate expired.
* Wrong distribution method.
* Device not trusted.
* iOS blocks unsigned or incorrectly signed app.

Required fix:

* Use correct development/ad-hoc profile.
* Include target device UDID.
* Regenerate profile.
* Rebuild IPA.

---

## Failure: GitHub Release has no IPA

Likely causes:

* Signing secrets missing.
* Signed build skipped.
* `flutter build ipa` failed.
* IPA path changed.

Required fix:

* Check release workflow logs.
* Confirm signing detection.
* Confirm `build/ios/ipa` contains `.ipa`.
* Fix copy command if needed.

---

# Signing Acceptance Criteria

iOS signing setup is complete only when:

* `ios/ExportOptions.plist` exists.
* `IOS_CERTIFICATE_BASE64` is configured.
* `IOS_CERTIFICATE_PASSWORD` is configured.
* `IOS_PROVISIONING_PROFILE_BASE64` is configured.
* `IOS_TEAM_ID` is configured.
* `IOS_BUNDLE_ID` is configured.
* `IOS_EXPORT_METHOD` is configured.
* `IOS_PROVISIONING_PROFILE_NAME` is configured.
* GitHub Actions can import certificate.
* GitHub Actions can install provisioning profile.
* `flutter build ipa` succeeds.
* `Quico.ipa` exists.
* `Quico.ipa` is uploaded to GitHub Release.

---

# Unsigned Fallback Acceptance Criteria

Unsigned fallback is complete only when:

* Release workflow detects missing signing secrets.
* Workflow does not crash only because signing secrets are absent.
* `flutter build ios --release --no-codesign` succeeds.
* `quico-ios-unsigned.zip` is created.
* GitHub Release uploads unsigned artifact.
* Release notes clearly say it is unsigned.

---

# Developer / Agent Rules

Developer/agent must:

* Keep normal CI independent from signing secrets.
* Keep iOS no-codesign build working.
* Attempt signed IPA only when signing secrets are present.
* Never commit signing assets.
* Never claim signed IPA exists unless actual `.ipa` exists.
* Upload best available artifact.
* Record signing-related compromises in `BUILD_SPEC.md` under `Decision Log / Technical Debt`.

Developer/agent must not:

* Disable iOS release workflow to avoid signing errors.
* Hardcode Apple Team ID in multiple random places.
* Commit provisioning profile.
* Commit certificate.
* Commit App Store Connect key.
* Put secrets inside docs.
* Claim unsigned artifact is installable IPA.

---

# Final Definition of Done For iOS Signing

iOS signing work is complete only when one of the following is true.

## Case A: Signing Secrets Available

* Signed build runs.
* `Quico.ipa` is generated.
* `Quico.ipa` is uploaded to GitHub Release.
* Release notes correctly identify it as signed IPA.

## Case B: Signing Secrets Missing

* Unsigned iOS build runs.
* `quico-ios-unsigned.zip` is generated.
* Artifact is uploaded to GitHub Release.
* Release notes clearly say signed IPA requires Apple signing credentials.
* This document explains the exact missing secrets.

In both cases:

* `flutter analyze` passes.
* `flutter test` passes.
* iOS build workflow exists.
* No secrets are committed.
* Documentation remains consistent with the fixed 12-file docs structure.

END OF DOCUMENT
