#!/usr/bin/env python3
"""Find remaining Vietnamese text (with or without diacritics) in code files."""
import os, re

# Common Vietnamese words that shouldn't be in code
VN_PATTERNS = [
    r"'C[oòóỏõọ]n\s", r"'N[gàáảãạ]an\s", r"'Kh[aàáảãạ]ch\s", r"'Th[eèéẻẽẹ]m\s",
    r"'L[uùúủũụ]u\s", r"'H[uùúủũụ]y\s", r"'X[oòóỏõọ]a\s", r"'S[ư]a\s",
    r"'D[aàáảãạ] ", r"'[Kk]h[ôo]ng\s", r"'[Cc]h[ưu]\s",
    # Without diacritics
    r"'Con\s", r"'Ngan\s", r"'Chua\s", r"'Khong\s", r"'Khach\s", r"'Them\s",
    r"'Luu\s", r"'Huy\s", r"'Xoa\s", r"'Sua\s", r"'Da\s",
]

for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if d not in ('.dart_tool', 'build')]
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        for i, line in enumerate(content.split('\n'), 1):
            for pat in VN_PATTERNS:
                if re.search(pat, line):
                    print(f'{os.path.relpath(fp)}:{i}: {line.strip()[:100]}')
                    break
