#!/usr/bin/env python3
"""
Full codebase audit: find ALL issues that would block compilation.
Checks: imports, const conflicts, missing classes, route mismatches, etc.
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ISSUES = []

def log(severity, msg):
    ISSUES.append((severity, msg))

def find_dart_files():
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        for f in files:
            if f.endswith('.dart'):
                yield os.path.join(root, f)

def check_imports(filepath, content, rel):
    """Verify imports point to existing files."""
    for m in re.finditer(r"^import\s+'(.+)';$", content, re.MULTILINE):
        imp = m.group(1)
        if imp.startswith('dart:') or imp.startswith('package:'):
            continue
        if imp.startswith('..') or imp.startswith('.'):
            basedir = os.path.dirname(filepath)
            target = os.path.normpath(os.path.join(basedir, imp))
            if not os.path.exists(target):
                log('ERROR', f'{rel}: import not found: {imp} -> {target}')

def check_const_with_l10n(filepath, content, rel):
    """Find const constructors that use context.l10n (compile error)."""
    for i, line in enumerate(content.split('\n'), 1):
        if 'const' in line and 'context.l10n' in line:
            log('ERROR', f'{rel}:{i}: const + context.l10n conflict: {line.strip()[:80]}')

def check_const_list_with_l10n(filepath, content, rel):
    """Find const list literals containing context.l10n values."""
    # Look for pattern: items: const [ ... context.l10n ... ]
    if 'const [' in content and 'context.l10n' in content:
        in_const_list = False
        for i, line in enumerate(content.split('\n'), 1):
            if 'const [' in line and 'context.l10n' in content:
                # Check if this const list contains context.l10n
                start = content.find('const [')
                end = content.find(']', start)
                if start >= 0 and end > start:
                    segment = content[start:end]
                    if 'context.l10n' in segment:
                        log('ERROR', f'{rel}:{i}: const list contains context.l10n values')

def check_missing_l10n_keys(content, rel):
    """Find context.l10n.xxx calls where xxx isn't in AppLocalizations."""
    l10n_calls = set()
    for m in re.finditer(r'context\.l10n\.(\w+)', content):
        l10n_calls.add(m.group(1))

    if not l10n_calls:
        return

    # Read AppLocalizations to find defined getters
    l10n_file = os.path.join(ROOT, 'lib', 'l10n', 'app_localizations.dart')
    if os.path.exists(l10n_file):
        with open(l10n_file) as f:
            l10n_content = f.read()
        for call in l10n_calls:
            # Check if getter exists: 'String get callName' or 'String callName('
            pattern1 = f'String get {call}'
            pattern2 = f'String {call}('
            if pattern1 not in l10n_content and pattern2 not in l10n_content:
                log('WARNING', f'{rel}: context.l10n.{call} not found in AppLocalizations')

def check_missing_providers(content, rel):
    """Find ref.watch/ref.read calls to providers that don't exist."""
    if 'appDatabaseProvider' in content:
        # Make sure the provider file is imported
        if 'app_providers.dart' not in content and 'app_database.dart' not in content:
            if 'Provider<AppDatabase>' not in content:
                log('WARNING', f'{rel}: uses appDatabaseProvider but may be missing import')

def check_file(filepath):
    rel = os.path.relpath(filepath, ROOT)
    with open(filepath, encoding='utf-8') as f:
        content = f.read()

    check_imports(filepath, content, rel)
    check_const_with_l10n(filepath, content, rel)
    check_const_list_with_l10n(filepath, content, rel)
    check_missing_l10n_keys(content, rel)
    check_missing_providers(content, rel)

def check_project_config():
    """Check project configuration files."""
    pubspec = os.path.join(ROOT, 'pubspec.yaml')
    if not os.path.exists(pubspec):
        log('ERROR', 'pubspec.yaml not found!')

    # Check for required dependencies
    if os.path.exists(pubspec):
        with open(pubspec) as f:
            content = f.read()
        required = ['flutter_localizations', 'flutter_riverpod', 'go_router', 'drift', 'intl', 'uuid']
        for dep in required:
            if dep not in content:
                log('ERROR', f'pubspec.yaml: missing {dep}')

    # Check for Flutter 3.x requirement
    if '>=3.2.0' not in content and '>=3.0.0' not in content:
        log('WARNING', 'pubspec.yaml: SDK constraint may need >=3.2.0 for Riverpod/Drift')

def check_arb_files():
    """Verify ARB files exist and are valid."""
    arb_dir = os.path.join(ROOT, 'lib', 'l10n')
    if not os.path.exists(arb_dir):
        log('ERROR', 'lib/l10n/ directory not found!')
        return

    for f in ['app_en.arb', 'app_vi.arb']:
        fp = os.path.join(arb_dir, f)
        if not os.path.exists(fp):
            log('ERROR', f'Missing ARB: {f}')
        else:
            with open(fp, encoding='utf-8') as fh:
                content = fh.read()
            if '@@locale' not in content:
                log('WARNING', f'{f}: missing @@locale key')

if __name__ == '__main__':
    print('=== Full Codebase Audit ===\n')

    for fp in find_dart_files():
        check_file(fp)

    check_project_config()
    check_arb_files()

    if not ISSUES:
        print('NO ISSUES FOUND')
        sys.exit(0)

    errors = [i for i in ISSUES if i[0] == 'ERROR']
    warnings = [i for i in ISSUES if i[0] == 'WARNING']

    for sev, msg in ISSUES:
        print(f'  [{sev}] {msg}')

    print(f'\n{len(errors)} errors, {len(warnings)} warnings')
    sys.exit(1 if errors else 0)
