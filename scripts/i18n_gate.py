#!/usr/bin/env python3
"""
i18n Commit Gate: blocks commits that risk breaking localization.

Checks:
1. Hardcoded user-facing strings in Dart code (strings outside ARB)
2. Mojibake / encoding corruption in any source file
3. Missing translation keys (key in app_en.arb but not app_vi.arb, or vice versa)
4. Locale files out of sync (en vs vi key mismatch)
5. Vietnamese diacritics in non-string Dart code (identifiers, comments)
6. ARB file validity (must be valid JSON)
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Vietnamese character patterns
VIETNAMESE_DIACRITICS = re.compile(
    r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩị'
    r'òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ]',
    re.IGNORECASE
)

# Must be in ARB, not hardcoded in Dart (common UI words)
FORBIDDEN_HARDCODED = re.compile(
    r"'(Trang chủ|Đơn hàng|Sản phẩm|Báo cáo|Thêm|Tạo đơn|Nói đơn|Nhập text"
    r"|Ảnh tin nhắn|Bắt đầu|Tạo cửa hàng|Cửa hàng|Hủy|Lưu|Sửa|Xóa|Xác nhận"
    r"|Hoàn tất|Đã thanh toán|Chưa thanh toán|Thanh toán một phần|Tiền mặt"
    r"|Chuyển khoản|Giảm giá|Tổng cộng|Tạm tính|Giá bán|Giá vốn|Tên sản phẩm"
    r"|Chi phí|Khách hàng|Tồn kho|Hóa đơn|Cài đặt|Báo cáo|Trang chủ"
    r"|Đang tải|Thử lại|Cảm ơn|Phiên bản|Tìm kiếm)"
    r"'",
    re.UNICODE
)

MOJIBAKE_PATTERNS = re.compile(
    r'[\\]u[0-9a-fA-F]{4}|Ã¡|Ã |áº£|Ã£|áº¡|á»Ÿ|á»“|á»‘|á»™|á»—|Ä‘|Äƒ|Ä‚'
)

SKIP_DIRS = {'.git', 'build', '.dart_tool', '.pub', '__pycache__', 'node_modules', 'coverage', 'ios/Pods', '.githooks'}


def check_arb_validity():
    """Check ARB files are valid JSON and have matching keys."""
    errors = []
    arb_dir = os.path.join(ROOT, 'lib', 'l10n')
    arb_files = [f for f in os.listdir(arb_dir) if f.endswith('.arb')]
    if not arb_files:
        return ["No ARB files found in lib/l10n/"]

    arb_data = {}
    for f in arb_files:
        fp = os.path.join(arb_dir, f)
        try:
            with open(fp, encoding='utf-8') as fh:
                data = json.load(fh)
            arb_data[f] = data
        except json.JSONDecodeError as e:
            errors.append(f"INVALID ARB: {f} - {e}")
        except Exception as e:
            errors.append(f"ERROR: {f} - {e}")

    if errors:
        return errors

    # Compare keys across locale files
    base_file = 'app_en.arb'
    if base_file not in arb_data:
        base_file = sorted(arb_data.keys())[0]

    if not arb_data:
        return errors

    base_keys = set(arb_data[base_file].keys())
    # Remove metadata keys
    base_keys = {k for k in base_keys if not k.startswith('@')}

    for f, data in arb_data.items():
        if f == base_file:
            continue
        file_keys = {k for k in data.keys() if not k.startswith('@')}
        missing = base_keys - file_keys
        extra = file_keys - base_keys
        if missing:
            errors.append(f"KEYS_MISSING: {f} missing {len(missing)} keys from {base_file}: {sorted(missing)[:10]}")
        if extra:
            errors.append(f"KEYS_EXTRA: {f} has {len(extra)} extra keys not in {base_file}: {sorted(extra)[:5]}")

    return errors


def check_mojibake():
    """Scan source files for encoding corruption."""
    errors = []
    for root, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if not f.endswith(('.dart', '.arb', '.yaml', '.md', '.json')):
                continue
            fp = os.path.join(root, f)
            try:
                with open(fp, 'rb') as fh:
                    raw = fh.read()
                raw.decode('utf-8')  # Try UTF-8
            except UnicodeDecodeError:
                errors.append(f"MOJIBAKE: {os.path.relpath(fp, ROOT)} - NOT UTF-8!")
                continue

            try:
                with open(fp, encoding='utf-8') as fh:
                    content = fh.read()
            except:
                continue

            for m in MOJIBAKE_PATTERNS.finditer(content):
                line_num = content[:m.start()].count('\n') + 1
                ctx = content[max(0, m.start()-15):m.end()+15].replace('\n', ' ')
                errors.append(f"MOJIBAKE: {os.path.relpath(fp, ROOT)}:{line_num} {ctx[:80]}")
                break

    return errors


def check_hardcoded_strings():
    """Find user-facing strings hardcoded in Dart files."""
    errors = []
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            # Check every line individually, even in files that use context.l10n
            for line_num, line in enumerate(content.split('\n'), 1):
                stripped = line.strip()
                if stripped.startswith('import ') or stripped.startswith('// '):
                    continue
                for m in FORBIDDEN_HARDCODED.finditer(stripped):
                    # Skip if this line already uses context.l10n
                    if 'context.l10n' in stripped:
                        continue
                    rel = os.path.relpath(fp, ROOT)
                    errors.append(f"HARDCODED: {rel}:{line_num} '{m.group(1)}'")

    return errors


def check_vietnamese_in_code():
    """Check Vietnamese diacritics in non-string Dart code."""
    errors = []
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                lines = fh.readlines()

            in_multiline_string = False
            for i, line in enumerate(lines, 1):
                stripped = line.strip()
                if stripped.startswith('import ') or stripped.startswith('part '):
                    continue
                if stripped.startswith("'''") or stripped.startswith('"""'):
                    in_multiline_string = not in_multiline_string
                    continue
                if in_multiline_string:
                    continue

                # Remove string literals
                cleaned = re.sub(r"'[^']*'", '', line)
                cleaned = re.sub(r'"[^"]*"', '', cleaned)

                if VIETNAMESE_DIACRITICS.search(cleaned):
                    rel = os.path.relpath(fp, ROOT)
                    errors.append(f"VN_IN_CODE: {rel}:{i} {stripped[:80]}")

    return errors


def check_arb_vietnamese():
    """Check that VN strings in ARB contain proper diacritics (no mojibake)."""
    errors = []
    arb_dir = os.path.join(ROOT, 'lib', 'l10n')
    for f in os.listdir(arb_dir):
        if not f.endswith('.arb'):
            continue
        if 'vi' not in f:
            continue
        fp = os.path.join(arb_dir, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        for i, line in enumerate(content.split('\n'), 1):
            m = MOJIBAKE_PATTERNS.search(line)
            if m:
                errors.append(f"ARB_MOJIBAKE: {f}:{i} {line.strip()[:80]}")
    return errors


def main():
    all_errors = []

    print("=== i18n Gate Check ===")
    print(f"\n1. ARB validity & sync...")
    errors = check_arb_validity()
    all_errors.extend(errors)
    for e in errors:
        print(f"  FAIL: {e}")

    print(f"\n2. Mojibake scan...")
    errors = check_mojibake()
    all_errors.extend(errors)
    for e in errors:
        print(f"  FAIL: {e}")

    print(f"\n3. Hardcoded strings...")
    errors = check_hardcoded_strings()
    all_errors.extend(errors)
    for e in errors:
        print(f"  FAIL: {e}")

    print(f"\n4. Vietnamese in code identifiers...")
    errors = check_vietnamese_in_code()
    all_errors.extend(errors)
    for e in errors:
        print(f"  FAIL: {e}")

    print(f"\n5. ARB Vietnamese diacritics...")
    errors = check_arb_vietnamese()
    all_errors.extend(errors)
    for e in errors:
        print(f"  FAIL: {e}")

    print(f"\n---")
    if all_errors:
        print(f"i18n GATE: BLOCKED ({len(all_errors)} issues)")
        sys.exit(1)
    else:
        print("i18n GATE: PASSED")
        sys.exit(0)


if __name__ == '__main__':
    main()
