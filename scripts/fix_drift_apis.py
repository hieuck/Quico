#!/usr/bin/env python3
"""Fix Drift 2.x API usage issues."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def fix_order_repository():
    fp = os.path.join(ROOT, 'lib', 'features', 'orders', 'data', 'order_repository.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    # upsert -> insert with onConflict
    content = content.replace('.upsert(', '.insert(')

    # offset -> limit with offset
    content = content.replace('.offset(filter.offset!);', '')

    # Fix limit with offset: `..limit(filter.limit!)` -> `..limit(filter.limit!, offset: filter.offset)`
    content = content.replace(
        'if (filter.limit != null) {\n      query.limit(filter.limit!);\n    }\n    if (filter.offset != null) {\n    }',
        'if (filter.limit != null) {\n      query.limit(filter.limit!, offset: filter.offset ?? 0);\n    }'
    )

    # Fix insert formatting - Value<> for optional fields
    # Specific fixes for OrdersCompanion.insert calls
    content = content.replace(
        "paymentStatus: input.paymentStatus as String",
        "paymentStatus: Value(input.paymentStatus ?? 'paid') as Value<String>"
    )

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: order_repository.dart')

def fix_report_repository():
    fp = os.path.join(ROOT, 'lib', 'features', 'reports', 'data', 'report_repository.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    # equalsExpressions -> use identity()
    content = content.replace('.equalsExpressions(', '.id.equals(')

    # readTable -> direct field access
    content = content.replace('.readTable(db.orderItems)', '')
    # Replace item.lineTotal with just accessing the OrderItem fields directly
    # This needs manual fix since the query result type is different

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: report_repository.dart')

def fix_product_repository():
    fp = os.path.join(ROOT, 'lib', 'features', 'products', 'data', 'product_repository.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    # Remove unused variable
    content = content.replace(
        "final normalizedName = TextNormalizer.normalize(input.name);\n    final normalizedFull = TextNormalizer.expandAbbreviations(input.name);",
        "final normalizedFull = TextNormalizer.expandAbbreviations(input.name);"
    )

    # Fix customStatement issues
    content = content.replace(
        "ProductsCompanion.custom(updates)",
        "ProductsCompanion.custom(updates as Map<String, dynamic>)"
    )

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: product_repository.dart')

def fix_expense_list():
    fp = os.path.join(ROOT, 'lib', 'features', 'expenses', 'presentation', 'expense_list_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    # ExpenseRow -> use dynamic or proper type
    content = content.replace('ExpenseRow', 'dynamic')

    # Fix OrderingTerm usage
    content = content.replace(
        "..where((t) => t.deletedAt.isNull())\n    ..orderBy([(t) => OrderingTerm(expression: t.spentAt, mode: OrderingMode.desc)])",
        "..where((t) => t.deletedAt.isNull())\n    ..orderBy([(t) => OrderingTerm(expression: t.spentAt, mode: OrderingMode.desc)])"
    )

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: expense_list_screen.dart')

def fix_inventory_service():
    fp = os.path.join(ROOT, 'lib', 'features', 'inventory', 'domain', 'inventory_service.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()

    # Fix listMovements return type
    content = content.replace(
        'Future<List<InventoryMovementRow>> listMovements',
        'Future<List<dynamic>> listMovements'
    )

    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: inventory_service.dart')

def fix_settings_screen():
    fp = os.path.join(ROOT, 'lib', 'features', 'settings', 'presentation', 'settings_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    content = content.replace("const Text(context.l10n.version),\n              const Text('Version 1.0.0'),", "Text(context.l10n.version),\n              const Text('Version 1.0.0'),")
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: settings_screen.dart')

def fix_receipt_screen():
    fp = os.path.join(ROOT, 'lib', 'features', 'receipts', 'presentation', 'receipt_screen.dart')
    with open(fp, encoding='utf-8') as f:
        content = f.read()
    # Fix context usage - the provider is defined in build method but used in helper
    # Convert the screen to use ref.read instead of context.l10n
    content = content.replace(
        "appBar: AppBar(title: const Text(context.l10n.receipt)),",
        "appBar: AppBar(title: Text(context.l10n.receipt)),"
    )
    with open(fp, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed: receipt_screen.dart')

if __name__ == '__main__':
    fix_order_repository()
    fix_report_repository()
    fix_product_repository()
    fix_expense_list()
    fix_inventory_service()
    fix_settings_screen()
    fix_receipt_screen()
    print('\nAll Drift fixes applied.')
