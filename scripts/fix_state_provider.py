#!/usr/bin/env python3
"""Replace StateProvider with NotifierProvider-compatible patterns."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FILES = {
    'lib/features/ai_order/presentation/ai_order_screen.dart': {
        "import '../../../l10n/l10n_extension.dart';": None,
        "import '../../../l10n/l10n_extension.dart';\nimport '../../../core/ai/parser/parsed_order_models.dart';": None,
    },
}

def fix_state_providers():
    """Find all files with StateProvider and fix them."""
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if not f.endswith('.dart'):
                continue
            fp = os.path.join(root, f)
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()

            if 'StateProvider<' not in content:
                continue

            print(f'NEEDS FIX: {os.path.relpath(fp, ROOT)}')

if __name__ == '__main__':
    fix_state_providers()
