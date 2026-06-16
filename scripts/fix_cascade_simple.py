#!/usr/bin/env python3
"""Simple fix: remove ALL ..where((t) patterns that regex missed."""
import os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
    for f in files:
        if not f.endswith('.dart'):
            continue
        fp = os.path.join(root, f)
        with open(fp, encoding='utf-8') as fh:
            content = fh.read()
        original = content

        # Remove ALL ..where((t) chains that follow await patterns
        content = re.sub(
            r"\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.equals\((\w+)\)\)",
            "",
            content
        )
        content = re.sub(
            r"\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.isNull\(\)\)",
            "",
            content
        )
        content = re.sub(
            r"\.\.where\(\(t\)\s*=>\s*t\.(\w+)\.isNotIn\(\[.*?\]\)\)",
            "",
            content
        )
        content = re.sub(
            r"\.\.orderBy\(\[\(t\)\s*=>\s*OrderingTerm\(expression:\s*t\.(\w+),\s*mode:\s*OrderingMode\.(\w+)\)\]\)",
            "",
            content
        )
        content = re.sub(r"\.get\(\)", "", content)
        content = re.sub(r"\.getSingleOrNull\(\)", "", content)

        # Fix double parens
        content = re.sub(r"\(\(await", "(await", content)

        # Fix ((await...)) -> (await...)
        content = re.sub(r"\(\(await database", r"(await database", content)

        if content != original:
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Fixed: {os.path.relpath(fp, ROOT)}')
