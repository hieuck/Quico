#!/usr/bin/env python3
"""Regenerate app_database.g.dart properly."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

content = '''// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../app_database.dart';

import 'package:drift/drift.dart';
'''

# Tables with their columns and types
TABLES = {
    'Stores': {'id':'String','name':'String','businessType':'String?','currency':'String','phone':'String?','address':'String?','logoPath':'String?','createdAt':'int','updatedAt':'int'},
    'Products': {'id':'String','storeId':'String','name':'String','normalizedName':'String','sku':'String?','barcode':'String?','costPrice':'int','salePrice':'int','stockQuantity':'int','lowStockThreshold':'int','imagePath':'String?','isActive':'bool','createdAt':'int','updatedAt':'int','deletedAt':'int?','syncStatus':'String?','lastSyncedAt':'int?','remoteId':'String?','deviceId':'String?','version':'int?'},
    'Customers': {'id':'String','storeId':'String','name':'String','phone':'String?','normalizedPhone':'String?','note':'String?','totalSpent':'int','totalOrders':'int','createdAt':'int','updatedAt':'int','deletedAt':'int?'},
    'Orders': {'id':'String','storeId':'String','customerId':'String?','orderCode':'String','status':'String','paymentStatus':'String','paymentMethod':'String?','subtotal':'int','discountAmount':'int','totalAmount':'int','costAmount':'int','grossProfit':'int','paidAmount':'int','note':'String?','source':'String','originalInput':'String?','createdAt':'int','updatedAt':'int','completedAt':'int?','cancelledAt':'int?','syncStatus':'String?','lastSyncedAt':'int?','remoteId':'String?'},
    'OrderItems': {'id':'String','orderId':'String','productId':'String?','productName':'String','quantity':'int','unitPrice':'int','costPrice':'int','discountAmount':'int','lineTotal':'int','lineProfit':'int','note':'String?','createdAt':'int','updatedAt':'int'},
    'InventoryMovements': {'id':'String','storeId':'String','productId':'String','type':'String','quantityDelta':'int','quantityAfter':'int','referenceType':'String?','referenceId':'String?','note':'String?','createdAt':'int'},
    'Expenses': {'id':'String','storeId':'String','category':'String','amount':'int','note':'String?','spentAt':'int','createdAt':'int','updatedAt':'int','deletedAt':'int?'},
    'BankAccounts': {'id':'String','storeId':'String','bankCode':'String','bankName':'String','accountNumber':'String','accountName':'String','isDefault':'bool','createdAt':'int','updatedAt':'int','deletedAt':'int?'},
    'AppSettings': {'key':'String','value':'String','updatedAt':'int'},
    'AiParseLogs': {'id':'String','storeId':'String','source':'String','inputText':'String','parsedJson':'String?','success':'bool','errorMessage':'String?','createdAt':'int'},
}

for table, cols in TABLES.items():
    nullable_types = {'String?','int?','bool?'}
    content += f'''
class {table}Companion extends UpdateCompanion<{table}> {{
  const {table}Companion({{
'''
    for col, typ in cols.items():
        optional = typ.endswith('?')
        content += f'    {"required " if not optional else ""}{typ.replace("?","")} {col}{" = const Value.absent()" if optional else ""},\n'
    content += '  });\n\n'
    for col, typ in cols.items():
        base = typ.replace('?','')
        content += f'  final Value<{base}> {col};\n'
    content += '\n'
    content += f'  Map<String, Expression> toColumns(bool nullToAbsent) => {{}};\n'
    content += '}\n'

# _$AppDatabase base class
content += '''
class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);

  late final Stores stores = Stores();
  late final Products products = Products();
  late final Customers customers = Customers();
  late final Orders orders = Orders();
  late final OrderItems orderItems = OrderItems();
  late final InventoryMovements inventoryMovements = InventoryMovements();
  late final Expenses expenses = Expenses();
  late final BankAccounts bankAccounts = BankAccounts();
  late final AppSettings appSettings = AppSettings();
  late final AiParseLogs aiParseLogs = AiParseLogs();

  @override
  List<TableInfo<Table, dynamic>> get allTables => [
    stores, products, customers, orders, orderItems,
    inventoryMovements, expenses, bankAccounts, appSettings, aiParseLogs,
  ];

  @override
  int get schemaVersion => 1;
}
'''

fp = os.path.join(ROOT, 'lib', 'core', 'database', 'app_database.g.dart')
with open(fp, 'w', encoding='utf-8') as f:
    f.write(content)
print(f'Generated {os.path.relpath(fp, ROOT)}')
