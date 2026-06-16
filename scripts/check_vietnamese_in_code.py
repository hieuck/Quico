#!/usr/bin/env python3
"""Check for Vietnamese text in code identifiers, comments, and non-string code.

Allows:
- Vietnamese inside string literals (UI strings, parser data, validator messages)
- Vietnamese in data map keys/values (diacritics, abbreviations, number words)

Flags:
- Vietnamese in class/method/variable/function names (identifiers)
- Vietnamese in comments
- Vietnamese in non-string code expressions
"""

import os
import re
import sys
from pathlib import Path

VIETNAMESE = re.compile(
    r'[àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ]',
    re.IGNORECASE
)

SKIP_DIRS = {'.git', 'build', '.dart_tool', '.pub', 'coverage', 'ios/Pods'}
SKIP_FILE_PATTERNS = ['l10n', 'intl', 'arb']

# Lines starting with these are allowed Vietnamese comments
ALLOWED_COMMENT_PREFIXES = ('// TODO', '// FIXME', '// HACK', '// XXX', '/// [')


def has_vietnamese_identifier(line: str) -> bool:
    """Check if Vietnamese chars appear outside string literals and map data."""
    # Remove quoted strings
    cleaned = re.sub(r"'[^']*'", '', line)
    cleaned = re.sub(r'"[^"]*"', '', cleaned)
    # Remove map key definitions (key: 'value' or 'key': value)
    cleaned = re.sub(r"'[^']+'\s*:", '', cleaned)

    return bool(VIETNAMESE.search(cleaned))


def check_file(filepath: Path) -> list[str]:
    for pat in SKIP_FILE_PATTERNS:
        if pat in filepath.name:
            return []
    errors = []
    try:
        content = filepath.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return []

    for i, line in enumerate(content.splitlines(), 1):
        if not VIETNAMESE.search(line):
            continue

        stripped = line.strip()
        if stripped.startswith('// ') or stripped.startswith('/// '):
            for prefix in ALLOWED_COMMENT_PREFIXES:
                if stripped.startswith(prefix):
                    break
            else:
                errors.append(f"  {filepath}:{i} (comment): {stripped[:80]}")
            continue

        if has_vietnamese_identifier(stripped):
            errors.append(f"  {filepath}:{i} (code): {stripped[:80]}")

    return errors


def main():
    root = Path.cwd()
    errors = []
    checked = 0

    for filepath in sorted(root.rglob('*.dart')):
        rel = filepath.relative_to(root)
        if any(p in rel.parts for p in SKIP_DIRS):
            continue
        checked += 1
        errors.extend(check_file(filepath))

    if errors:
        print(f"VIETNAMESE TEXT IN CODE ({len(errors)} occurrences):")
        print("Use English for code identifiers and comments.\n")
        for e in errors:
            print(e)
        print(f"\nChecked {checked} .dart files.")
        sys.exit(1)
    else:
        print(f"OK: Checked {checked} .dart files, no issues.")
        sys.exit(0)


if __name__ == '__main__':
    main()
