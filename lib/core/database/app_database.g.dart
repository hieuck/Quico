// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:drift/drift.dart';

class StoresCompanion extends UpdateCompanion<dynamic>(
  Stores,
) {
  const StoresCompanion({
    required this.id,
    required this.name,
    this.businessType,
    required this.currency,
    this.phone,
    this.address,
    this.logoPath,
    this.createdAt,
    this.updatedAt,
  });

  final Value<String>? id;
  final Value<String>? name;
  final Value<String>? businessType;
  final Value<String>? currency;
  final Value<String>? phone;
  final Value<String>? address;
  final Value<String>? logoPath;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;

  static StoresCompanion insert({
    required String id,
    required String name,
    String businessType = const Value.absent(),
    required String currency,
    String phone = const Value.absent(),
    String address = const Value.absent(),
    String logoPath = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) => StoresCompanion(
    id: Value(id),
    name: Value(name),
    businessType: Value(businessType),
    currency: Value(currency),
    phone: Value(phone),
    address: Value(address),
    logoPath: Value(logoPath),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );

  static StoresCompanion custom(Map<String, dynamic> values) =>
      StoresCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        name: values.containsKey('name') ? Value(values['name']) : const Value.absent(),
        businessType: values.containsKey('businessType') ? Value(values['businessType']) : const Value.absent(),
        currency: values.containsKey('currency') ? Value(values['currency']) : const Value.absent(),
        phone: values.containsKey('phone') ? Value(values['phone']) : const Value.absent(),
        address: values.containsKey('address') ? Value(values['address']) : const Value.absent(),
        logoPath: values.containsKey('logoPath') ? Value(values['logoPath']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class ProductsCompanion extends UpdateCompanion<dynamic>(
  Products,
) {
  const ProductsCompanion({
    required this.id,
    required this.storeId,
    required this.name,
    required this.normalizedName,
    this.sku,
    this.barcode,
    this.costPrice,
    this.salePrice,
    this.stockQuantity,
    this.lowStockThreshold,
    this.imagePath,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.remoteId,
    this.deviceId,
    this.version,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? name;
  final Value<String>? normalizedName;
  final Value<String>? sku;
  final Value<String>? barcode;
  final Value<int>? costPrice;
  final Value<int>? salePrice;
  final Value<int>? stockQuantity;
  final Value<int>? lowStockThreshold;
  final Value<String>? imagePath;
  final Value<bool>? isActive;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;
  final Value<String>? deletedAt;
  final Value<String>? syncStatus;
  final Value<int>? lastSyncedAt;
  final Value<String>? remoteId;
  final Value<String>? deviceId;
  final Value<int>? version;

  static ProductsCompanion insert({
    required String id,
    required String storeId,
    required String name,
    required String normalizedName,
    String sku = const Value.absent(),
    String barcode = const Value.absent(),
    required int costPrice,
    required int salePrice,
    required int stockQuantity,
    required int lowStockThreshold,
    String imagePath = const Value.absent(),
    required bool isActive,
    required int createdAt,
    required int updatedAt,
    String deletedAt = const Value.absent(),
    String syncStatus = const Value.absent(),
    int lastSyncedAt = const Value.absent(),
    String remoteId = const Value.absent(),
    String deviceId = const Value.absent(),
    int version = const Value.absent(),
  }) => ProductsCompanion(
    id: Value(id),
    storeId: Value(storeId),
    name: Value(name),
    normalizedName: Value(normalizedName),
    sku: Value(sku),
    barcode: Value(barcode),
    costPrice: Value(costPrice),
    salePrice: Value(salePrice),
    stockQuantity: Value(stockQuantity),
    lowStockThreshold: Value(lowStockThreshold),
    imagePath: Value(imagePath),
    isActive: Value(isActive),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
    syncStatus: Value(syncStatus),
    lastSyncedAt: Value(lastSyncedAt),
    remoteId: Value(remoteId),
    deviceId: Value(deviceId),
    version: Value(version),
  );

  static ProductsCompanion custom(Map<String, dynamic> values) =>
      ProductsCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        name: values.containsKey('name') ? Value(values['name']) : const Value.absent(),
        normalizedName: values.containsKey('normalizedName') ? Value(values['normalizedName']) : const Value.absent(),
        sku: values.containsKey('sku') ? Value(values['sku']) : const Value.absent(),
        barcode: values.containsKey('barcode') ? Value(values['barcode']) : const Value.absent(),
        costPrice: values.containsKey('costPrice') ? Value(values['costPrice']) : const Value.absent(),
        salePrice: values.containsKey('salePrice') ? Value(values['salePrice']) : const Value.absent(),
        stockQuantity: values.containsKey('stockQuantity') ? Value(values['stockQuantity']) : const Value.absent(),
        lowStockThreshold: values.containsKey('lowStockThreshold') ? Value(values['lowStockThreshold']) : const Value.absent(),
        imagePath: values.containsKey('imagePath') ? Value(values['imagePath']) : const Value.absent(),
        isActive: values.containsKey('isActive') ? Value(values['isActive']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
        deletedAt: values.containsKey('deletedAt') ? Value(values['deletedAt']) : const Value.absent(),
        syncStatus: values.containsKey('syncStatus') ? Value(values['syncStatus']) : const Value.absent(),
        lastSyncedAt: values.containsKey('lastSyncedAt') ? Value(values['lastSyncedAt']) : const Value.absent(),
        remoteId: values.containsKey('remoteId') ? Value(values['remoteId']) : const Value.absent(),
        deviceId: values.containsKey('deviceId') ? Value(values['deviceId']) : const Value.absent(),
        version: values.containsKey('version') ? Value(values['version']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class CustomersCompanion extends UpdateCompanion<dynamic>(
  Customers,
) {
  const CustomersCompanion({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.normalizedPhone,
    this.note,
    this.totalSpent,
    this.totalOrders,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? name;
  final Value<String>? phone;
  final Value<String>? normalizedPhone;
  final Value<String>? note;
  final Value<int>? totalSpent;
  final Value<int>? totalOrders;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;
  final Value<String>? deletedAt;

  static CustomersCompanion insert({
    required String id,
    required String storeId,
    required String name,
    String phone = const Value.absent(),
    String normalizedPhone = const Value.absent(),
    String note = const Value.absent(),
    required int totalSpent,
    required int totalOrders,
    required int createdAt,
    required int updatedAt,
    String deletedAt = const Value.absent(),
  }) => CustomersCompanion(
    id: Value(id),
    storeId: Value(storeId),
    name: Value(name),
    phone: Value(phone),
    normalizedPhone: Value(normalizedPhone),
    note: Value(note),
    totalSpent: Value(totalSpent),
    totalOrders: Value(totalOrders),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );

  static CustomersCompanion custom(Map<String, dynamic> values) =>
      CustomersCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        name: values.containsKey('name') ? Value(values['name']) : const Value.absent(),
        phone: values.containsKey('phone') ? Value(values['phone']) : const Value.absent(),
        normalizedPhone: values.containsKey('normalizedPhone') ? Value(values['normalizedPhone']) : const Value.absent(),
        note: values.containsKey('note') ? Value(values['note']) : const Value.absent(),
        totalSpent: values.containsKey('totalSpent') ? Value(values['totalSpent']) : const Value.absent(),
        totalOrders: values.containsKey('totalOrders') ? Value(values['totalOrders']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
        deletedAt: values.containsKey('deletedAt') ? Value(values['deletedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class OrdersCompanion extends UpdateCompanion<dynamic>(
  Orders,
) {
  const OrdersCompanion({
    required this.id,
    required this.storeId,
    this.customerId,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.subtotal,
    this.discountAmount,
    this.totalAmount,
    this.costAmount,
    this.grossProfit,
    this.paidAmount,
    this.note,
    required this.source,
    this.originalInput,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.syncStatus,
    this.lastSyncedAt,
    this.remoteId,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? customerId;
  final Value<String>? orderCode;
  final Value<String>? status;
  final Value<String>? paymentStatus;
  final Value<String>? paymentMethod;
  final Value<int>? subtotal;
  final Value<int>? discountAmount;
  final Value<int>? totalAmount;
  final Value<int>? costAmount;
  final Value<int>? grossProfit;
  final Value<int>? paidAmount;
  final Value<String>? note;
  final Value<String>? source;
  final Value<String>? originalInput;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;
  final Value<String>? completedAt;
  final Value<String>? cancelledAt;
  final Value<String>? syncStatus;
  final Value<int>? lastSyncedAt;
  final Value<String>? remoteId;

  static OrdersCompanion insert({
    required String id,
    required String storeId,
    String customerId = const Value.absent(),
    required String orderCode,
    required String status,
    required String paymentStatus,
    String paymentMethod = const Value.absent(),
    required int subtotal,
    required int discountAmount,
    required int totalAmount,
    required int costAmount,
    required int grossProfit,
    required int paidAmount,
    String note = const Value.absent(),
    required String source,
    String originalInput = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    String completedAt = const Value.absent(),
    String cancelledAt = const Value.absent(),
    String syncStatus = const Value.absent(),
    int lastSyncedAt = const Value.absent(),
    String remoteId = const Value.absent(),
  }) => OrdersCompanion(
    id: Value(id),
    storeId: Value(storeId),
    customerId: Value(customerId),
    orderCode: Value(orderCode),
    status: Value(status),
    paymentStatus: Value(paymentStatus),
    paymentMethod: Value(paymentMethod),
    subtotal: Value(subtotal),
    discountAmount: Value(discountAmount),
    totalAmount: Value(totalAmount),
    costAmount: Value(costAmount),
    grossProfit: Value(grossProfit),
    paidAmount: Value(paidAmount),
    note: Value(note),
    source: Value(source),
    originalInput: Value(originalInput),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    completedAt: Value(completedAt),
    cancelledAt: Value(cancelledAt),
    syncStatus: Value(syncStatus),
    lastSyncedAt: Value(lastSyncedAt),
    remoteId: Value(remoteId),
  );

  static OrdersCompanion custom(Map<String, dynamic> values) =>
      OrdersCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        customerId: values.containsKey('customerId') ? Value(values['customerId']) : const Value.absent(),
        orderCode: values.containsKey('orderCode') ? Value(values['orderCode']) : const Value.absent(),
        status: values.containsKey('status') ? Value(values['status']) : const Value.absent(),
        paymentStatus: values.containsKey('paymentStatus') ? Value(values['paymentStatus']) : const Value.absent(),
        paymentMethod: values.containsKey('paymentMethod') ? Value(values['paymentMethod']) : const Value.absent(),
        subtotal: values.containsKey('subtotal') ? Value(values['subtotal']) : const Value.absent(),
        discountAmount: values.containsKey('discountAmount') ? Value(values['discountAmount']) : const Value.absent(),
        totalAmount: values.containsKey('totalAmount') ? Value(values['totalAmount']) : const Value.absent(),
        costAmount: values.containsKey('costAmount') ? Value(values['costAmount']) : const Value.absent(),
        grossProfit: values.containsKey('grossProfit') ? Value(values['grossProfit']) : const Value.absent(),
        paidAmount: values.containsKey('paidAmount') ? Value(values['paidAmount']) : const Value.absent(),
        note: values.containsKey('note') ? Value(values['note']) : const Value.absent(),
        source: values.containsKey('source') ? Value(values['source']) : const Value.absent(),
        originalInput: values.containsKey('originalInput') ? Value(values['originalInput']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
        completedAt: values.containsKey('completedAt') ? Value(values['completedAt']) : const Value.absent(),
        cancelledAt: values.containsKey('cancelledAt') ? Value(values['cancelledAt']) : const Value.absent(),
        syncStatus: values.containsKey('syncStatus') ? Value(values['syncStatus']) : const Value.absent(),
        lastSyncedAt: values.containsKey('lastSyncedAt') ? Value(values['lastSyncedAt']) : const Value.absent(),
        remoteId: values.containsKey('remoteId') ? Value(values['remoteId']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class OrderItemsCompanion extends UpdateCompanion<dynamic>(
  OrderItems,
) {
  const OrderItemsCompanion({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.quantity,
    this.unitPrice,
    this.costPrice,
    this.discountAmount,
    this.lineTotal,
    this.lineProfit,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  final Value<String>? id;
  final Value<String>? orderId;
  final Value<String>? productId;
  final Value<String>? productName;
  final Value<int>? quantity;
  final Value<int>? unitPrice;
  final Value<int>? costPrice;
  final Value<int>? discountAmount;
  final Value<int>? lineTotal;
  final Value<int>? lineProfit;
  final Value<String>? note;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;

  static OrderItemsCompanion insert({
    required String id,
    required String orderId,
    String productId = const Value.absent(),
    required String productName,
    required int quantity,
    required int unitPrice,
    required int costPrice,
    required int discountAmount,
    required int lineTotal,
    required int lineProfit,
    String note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  }) => OrderItemsCompanion(
    id: Value(id),
    orderId: Value(orderId),
    productId: Value(productId),
    productName: Value(productName),
    quantity: Value(quantity),
    unitPrice: Value(unitPrice),
    costPrice: Value(costPrice),
    discountAmount: Value(discountAmount),
    lineTotal: Value(lineTotal),
    lineProfit: Value(lineProfit),
    note: Value(note),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );

  static OrderItemsCompanion custom(Map<String, dynamic> values) =>
      OrderItemsCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        orderId: values.containsKey('orderId') ? Value(values['orderId']) : const Value.absent(),
        productId: values.containsKey('productId') ? Value(values['productId']) : const Value.absent(),
        productName: values.containsKey('productName') ? Value(values['productName']) : const Value.absent(),
        quantity: values.containsKey('quantity') ? Value(values['quantity']) : const Value.absent(),
        unitPrice: values.containsKey('unitPrice') ? Value(values['unitPrice']) : const Value.absent(),
        costPrice: values.containsKey('costPrice') ? Value(values['costPrice']) : const Value.absent(),
        discountAmount: values.containsKey('discountAmount') ? Value(values['discountAmount']) : const Value.absent(),
        lineTotal: values.containsKey('lineTotal') ? Value(values['lineTotal']) : const Value.absent(),
        lineProfit: values.containsKey('lineProfit') ? Value(values['lineProfit']) : const Value.absent(),
        note: values.containsKey('note') ? Value(values['note']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class InventoryMovementsCompanion extends UpdateCompanion<dynamic>(
  InventoryMovements,
) {
  const InventoryMovementsCompanion({
    required this.id,
    required this.storeId,
    this.productId,
    required this.type,
    this.quantityDelta,
    this.quantityAfter,
    this.referenceType,
    this.referenceId,
    this.note,
    this.createdAt,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? productId;
  final Value<String>? type;
  final Value<int>? quantityDelta;
  final Value<int>? quantityAfter;
  final Value<String>? referenceType;
  final Value<String>? referenceId;
  final Value<String>? note;
  final Value<int>? createdAt;

  static InventoryMovementsCompanion insert({
    required String id,
    required String storeId,
    String productId = const Value.absent(),
    required String type,
    required int quantityDelta,
    required int quantityAfter,
    String referenceType = const Value.absent(),
    String referenceId = const Value.absent(),
    String note = const Value.absent(),
    required int createdAt,
  }) => InventoryMovementsCompanion(
    id: Value(id),
    storeId: Value(storeId),
    productId: Value(productId),
    type: Value(type),
    quantityDelta: Value(quantityDelta),
    quantityAfter: Value(quantityAfter),
    referenceType: Value(referenceType),
    referenceId: Value(referenceId),
    note: Value(note),
    createdAt: Value(createdAt),
  );

  static InventoryMovementsCompanion custom(Map<String, dynamic> values) =>
      InventoryMovementsCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        productId: values.containsKey('productId') ? Value(values['productId']) : const Value.absent(),
        type: values.containsKey('type') ? Value(values['type']) : const Value.absent(),
        quantityDelta: values.containsKey('quantityDelta') ? Value(values['quantityDelta']) : const Value.absent(),
        quantityAfter: values.containsKey('quantityAfter') ? Value(values['quantityAfter']) : const Value.absent(),
        referenceType: values.containsKey('referenceType') ? Value(values['referenceType']) : const Value.absent(),
        referenceId: values.containsKey('referenceId') ? Value(values['referenceId']) : const Value.absent(),
        note: values.containsKey('note') ? Value(values['note']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class ExpensesCompanion extends UpdateCompanion<dynamic>(
  Expenses,
) {
  const ExpensesCompanion({
    required this.id,
    required this.storeId,
    required this.category,
    this.amount,
    this.note,
    this.spentAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? category;
  final Value<int>? amount;
  final Value<String>? note;
  final Value<int>? spentAt;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;
  final Value<String>? deletedAt;

  static ExpensesCompanion insert({
    required String id,
    required String storeId,
    required String category,
    required int amount,
    String note = const Value.absent(),
    required int spentAt,
    required int createdAt,
    required int updatedAt,
    String deletedAt = const Value.absent(),
  }) => ExpensesCompanion(
    id: Value(id),
    storeId: Value(storeId),
    category: Value(category),
    amount: Value(amount),
    note: Value(note),
    spentAt: Value(spentAt),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );

  static ExpensesCompanion custom(Map<String, dynamic> values) =>
      ExpensesCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        category: values.containsKey('category') ? Value(values['category']) : const Value.absent(),
        amount: values.containsKey('amount') ? Value(values['amount']) : const Value.absent(),
        note: values.containsKey('note') ? Value(values['note']) : const Value.absent(),
        spentAt: values.containsKey('spentAt') ? Value(values['spentAt']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
        deletedAt: values.containsKey('deletedAt') ? Value(values['deletedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class BankAccountsCompanion extends UpdateCompanion<dynamic>(
  BankAccounts,
) {
  const BankAccountsCompanion({
    required this.id,
    required this.storeId,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? bankCode;
  final Value<String>? bankName;
  final Value<String>? accountNumber;
  final Value<String>? accountName;
  final Value<bool>? isDefault;
  final Value<int>? createdAt;
  final Value<int>? updatedAt;
  final Value<String>? deletedAt;

  static BankAccountsCompanion insert({
    required String id,
    required String storeId,
    required String bankCode,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required bool isDefault,
    required int createdAt,
    required int updatedAt,
    String deletedAt = const Value.absent(),
  }) => BankAccountsCompanion(
    id: Value(id),
    storeId: Value(storeId),
    bankCode: Value(bankCode),
    bankName: Value(bankName),
    accountNumber: Value(accountNumber),
    accountName: Value(accountName),
    isDefault: Value(isDefault),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );

  static BankAccountsCompanion custom(Map<String, dynamic> values) =>
      BankAccountsCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        bankCode: values.containsKey('bankCode') ? Value(values['bankCode']) : const Value.absent(),
        bankName: values.containsKey('bankName') ? Value(values['bankName']) : const Value.absent(),
        accountNumber: values.containsKey('accountNumber') ? Value(values['accountNumber']) : const Value.absent(),
        accountName: values.containsKey('accountName') ? Value(values['accountName']) : const Value.absent(),
        isDefault: values.containsKey('isDefault') ? Value(values['isDefault']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
        deletedAt: values.containsKey('deletedAt') ? Value(values['deletedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class AppSettingsCompanion extends UpdateCompanion<dynamic>(
  AppSettings,
) {
  const AppSettingsCompanion({
    required this.key,
    required this.value,
    this.updatedAt,
  });

  final Value<String>? key;
  final Value<String>? value;
  final Value<int>? updatedAt;

  static AppSettingsCompanion insert({
    required String key,
    required String value,
    required int updatedAt,
  }) => AppSettingsCompanion(
    key: Value(key),
    value: Value(value),
    updatedAt: Value(updatedAt),
  );

  static AppSettingsCompanion custom(Map<String, dynamic> values) =>
      AppSettingsCompanion(
        key: values.containsKey('key') ? Value(values['key']) : const Value.absent(),
        value: values.containsKey('value') ? Value(values['value']) : const Value.absent(),
        updatedAt: values.containsKey('updatedAt') ? Value(values['updatedAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class AiParseLogsCompanion extends UpdateCompanion<dynamic>(
  AiParseLogs,
) {
  const AiParseLogsCompanion({
    required this.id,
    required this.storeId,
    required this.source,
    required this.inputText,
    this.parsedJson,
    this.success,
    this.errorMessage,
    this.createdAt,
  });

  final Value<String>? id;
  final Value<String>? storeId;
  final Value<String>? source;
  final Value<String>? inputText;
  final Value<String>? parsedJson;
  final Value<bool>? success;
  final Value<String>? errorMessage;
  final Value<int>? createdAt;

  static AiParseLogsCompanion insert({
    required String id,
    required String storeId,
    required String source,
    required String inputText,
    String parsedJson = const Value.absent(),
    required bool success,
    String errorMessage = const Value.absent(),
    required int createdAt,
  }) => AiParseLogsCompanion(
    id: Value(id),
    storeId: Value(storeId),
    source: Value(source),
    inputText: Value(inputText),
    parsedJson: Value(parsedJson),
    success: Value(success),
    errorMessage: Value(errorMessage),
    createdAt: Value(createdAt),
  );

  static AiParseLogsCompanion custom(Map<String, dynamic> values) =>
      AiParseLogsCompanion(
        id: values.containsKey('id') ? Value(values['id']) : const Value.absent(),
        storeId: values.containsKey('storeId') ? Value(values['storeId']) : const Value.absent(),
        source: values.containsKey('source') ? Value(values['source']) : const Value.absent(),
        inputText: values.containsKey('inputText') ? Value(values['inputText']) : const Value.absent(),
        parsedJson: values.containsKey('parsedJson') ? Value(values['parsedJson']) : const Value.absent(),
        success: values.containsKey('success') ? Value(values['success']) : const Value.absent(),
        errorMessage: values.containsKey('errorMessage') ? Value(values['errorMessage']) : const Value.absent(),
        createdAt: values.containsKey('createdAt') ? Value(values['createdAt']) : const Value.absent(),
      );

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}
