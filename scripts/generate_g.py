#!/usr/bin/env python3
"""Generate minimal app_database.g.dart with Companion classes."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TABLES = {
    'Stores': ['id','name','businessType','currency','phone','address','logoPath','createdAt','updatedAt'],
    'Products': ['id','storeId','name','normalizedName','sku','barcode','costPrice','salePrice','stockQuantity','lowStockThreshold','imagePath','isActive','createdAt','updatedAt','deletedAt','syncStatus','lastSyncedAt','remoteId','deviceId','version'],
    'Customers': ['id','storeId','name','phone','normalizedPhone','note','totalSpent','totalOrders','createdAt','updatedAt','deletedAt'],
    'Orders': ['id','storeId','customerId','orderCode','status','paymentStatus','paymentMethod','subtotal','discountAmount','totalAmount','costAmount','grossProfit','paidAmount','note','source','originalInput','createdAt','updatedAt','completedAt','cancelledAt','syncStatus','lastSyncedAt','remoteId'],
    'OrderItems': ['id','orderId','productId','productName','quantity','unitPrice','costPrice','discountAmount','lineTotal','lineProfit','note','createdAt','updatedAt'],
    'InventoryMovements': ['id','storeId','productId','type','quantityDelta','quantityAfter','referenceType','referenceId','note','createdAt'],
    'Expenses': ['id','storeId','category','amount','note','spentAt','createdAt','updatedAt','deletedAt'],
    'BankAccounts': ['id','storeId','bankCode','bankName','accountNumber','accountName','isDefault','createdAt','updatedAt','deletedAt'],
    'AppSettings': ['key','value','updatedAt'],
    'AiParseLogs': ['id','storeId','source','inputText','parsedJson','success','errorMessage','createdAt'],
}

def generate():
    lines = ['// GENERATED CODE - DO NOT MODIFY BY HAND', '',
             "import 'package:drift/drift.dart';", '']
    for table, cols in TABLES.items():
        nullable = ['businessType','phone','address','logoPath','sku','barcode','imagePath',
                    'deletedAt','syncStatus','lastSyncedAt','remoteId','deviceId','version',
                    'customerId','paymentMethod','note','originalInput','completedAt','cancelledAt',
                    'productId','referenceType','referenceId','parsedJson','errorMessage',
                    'normalizedPhone']
        bools = ['isActive','isDefault','success']
        ints = ['costPrice','salePrice','stockQuantity','lowStockThreshold','createdAt','updatedAt',
                'totalSpent','totalOrders','subtotal','discountAmount','totalAmount','costAmount',
                'grossProfit','paidAmount','quantity','unitPrice','lineTotal','lineProfit',
                'quantityDelta','quantityAfter','amount','spentAt','lastSyncedAt','version']

        lines.append(f'class {table}Companion extends UpdateCompanion<dynamic>(')
        lines.append(f'  {table},')
        lines.append(f') {{')
        lines.append(f'  const {table}Companion({{')
        for c in cols:
            opt = c in nullable or c in bools or c in ints
            if opt:
                lines.append(f'    this.{c},')
            else:
                lines.append(f'    required this.{c},')
        lines.append(f'  }});')
        lines.append('')
        for c in cols:
            t = 'bool' if c in bools else 'int' if c in ints else 'String'
            lines.append(f'  final Value<{t}>? {c};')
        lines.append('')
        lines.append(f'  static {table}Companion insert({{')
        for c in cols:
            opt = c in nullable
            lines.append(f'    {"required " if not opt else ""}{"String" if c not in ints and c not in bools else "int" if c in ints else "bool"} {c}{" = " + f"const Value.absent()" if opt else ""},')
        lines.append(f'  }}) => {table}Companion(')
        for c in cols:
            lines.append(f'    {c}: Value({c}),')
        lines.append(f'  );')
        lines.append('')
        lines.append(f'  static {table}Companion custom(Map<String, dynamic> values) =>')
        lines.append(f'      {table}Companion(')
        for c in cols:
            lines.append(f'        {c}: values.containsKey(\'{c}\') ? Value(values[\'{c}\']) : const Value.absent(),')
        lines.append(f'      );')
        lines.append('')
        lines.append(f'  @override')
        lines.append(f'  Map<String, Expression> toColumns(bool nullToAbsent) => {{}};')
        lines.append(f'}}')
        lines.append('')

    fp = os.path.join(ROOT, 'lib', 'core', 'database', 'app_database.g.dart')
    with open(fp, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print(f'Generated {os.path.relpath(fp, ROOT)} with {len(TABLES)} companion classes')

if __name__ == '__main__':
    generate()
