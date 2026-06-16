#!/usr/bin/env python3
"""Add missing l10n keys to ARB files and AppLocalizations class."""
import json, os

def add_key(key, en_value, vi_value):
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # 1. app_en.arb
    fp = os.path.join(root, 'lib', 'l10n', 'app_en.arb')
    with open(fp, encoding='utf-8') as f:
        en = json.load(f)
    if key not in en or en[key] != en_value:
        en[key] = en_value
        with open(fp, 'w', encoding='utf-8') as f:
            json.dump(en, f, indent=2, ensure_ascii=False)
        print(f'Added {key} -> en: {en_value}')

    # 2. app_vi.arb
    fp = os.path.join(root, 'lib', 'l10n', 'app_vi.arb')
    with open(fp, encoding='utf-8') as f:
        vi = json.load(f)
    if key not in vi or vi[key] != vi_value:
        vi[key] = vi_value
        with open(fp, 'w', encoding='utf-8') as f:
            json.dump(vi, f, indent=2, ensure_ascii=False)
        print(f'Added {key} -> vi: {vi_value}')

    # 3. AppLocalizations class
    fp = os.path.join(root, 'lib', 'l10n', 'app_localizations.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    getter = f"  String get {key} => _t('{key}');"
    if getter not in content:
        content = content.replace(
            "  String get version",
            f"{getter}\n  String get version"
        )
        with open(fp, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Added getter to AppLocalizations: {key}')


if __name__ == '__main__':
    add_key('screenshots', 'Screenshots', 'Anh tin nhan')
