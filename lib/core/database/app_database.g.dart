// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../app_database.dart';

import 'package:drift/drift.dart';

class StoresCompanion extends UpdateCompanion<Stores> {
  const StoresCompanion({
    required String id,
    required String name,
    String businessType = const Value.absent(),
    required String currency,
    String phone = const Value.absent(),
    String address = const Value.absent(),
    String logoPath = const Value.absent(),
    required int createdAt,
    required int updatedAt,
  });

  final Value<String> id;
  final Value<String> name;
  final Value<String> businessType;
  final Value<String> currency;
  final Value<String> phone;
  final Value<String> address;
  final Value<String> logoPath;
  final Value<int> createdAt;
  final Value<int> updatedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class ProductsCompanion extends UpdateCompanion<Products> {
  const ProductsCompanion({
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
    int deletedAt = const Value.absent(),
    String syncStatus = const Value.absent(),
    int lastSyncedAt = const Value.absent(),
    String remoteId = const Value.absent(),
    String deviceId = const Value.absent(),
    int version = const Value.absent(),
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> sku;
  final Value<String> barcode;
  final Value<int> costPrice;
  final Value<int> salePrice;
  final Value<int> stockQuantity;
  final Value<int> lowStockThreshold;
  final Value<String> imagePath;
  final Value<bool> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> deletedAt;
  final Value<String> syncStatus;
  final Value<int> lastSyncedAt;
  final Value<String> remoteId;
  final Value<String> deviceId;
  final Value<int> version;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class CustomersCompanion extends UpdateCompanion<Customers> {
  const CustomersCompanion({
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
    int deletedAt = const Value.absent(),
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> normalizedPhone;
  final Value<String> note;
  final Value<int> totalSpent;
  final Value<int> totalOrders;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> deletedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class OrdersCompanion extends UpdateCompanion<Orders> {
  const OrdersCompanion({
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
    int completedAt = const Value.absent(),
    int cancelledAt = const Value.absent(),
    String syncStatus = const Value.absent(),
    int lastSyncedAt = const Value.absent(),
    String remoteId = const Value.absent(),
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> customerId;
  final Value<String> orderCode;
  final Value<String> status;
  final Value<String> paymentStatus;
  final Value<String> paymentMethod;
  final Value<int> subtotal;
  final Value<int> discountAmount;
  final Value<int> totalAmount;
  final Value<int> costAmount;
  final Value<int> grossProfit;
  final Value<int> paidAmount;
  final Value<String> note;
  final Value<String> source;
  final Value<String> originalInput;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> completedAt;
  final Value<int> cancelledAt;
  final Value<String> syncStatus;
  final Value<int> lastSyncedAt;
  final Value<String> remoteId;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class OrderItemsCompanion extends UpdateCompanion<OrderItems> {
  const OrderItemsCompanion({
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
  });

  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<int> unitPrice;
  final Value<int> costPrice;
  final Value<int> discountAmount;
  final Value<int> lineTotal;
  final Value<int> lineProfit;
  final Value<String> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class InventoryMovementsCompanion extends UpdateCompanion<InventoryMovements> {
  const InventoryMovementsCompanion({
    required String id,
    required String storeId,
    required String productId,
    required String type,
    required int quantityDelta,
    required int quantityAfter,
    String referenceType = const Value.absent(),
    String referenceId = const Value.absent(),
    String note = const Value.absent(),
    required int createdAt,
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> quantityDelta;
  final Value<int> quantityAfter;
  final Value<String> referenceType;
  final Value<String> referenceId;
  final Value<String> note;
  final Value<int> createdAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class ExpensesCompanion extends UpdateCompanion<Expenses> {
  const ExpensesCompanion({
    required String id,
    required String storeId,
    required String category,
    required int amount,
    String note = const Value.absent(),
    required int spentAt,
    required int createdAt,
    required int updatedAt,
    int deletedAt = const Value.absent(),
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> category;
  final Value<int> amount;
  final Value<String> note;
  final Value<int> spentAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> deletedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class BankAccountsCompanion extends UpdateCompanion<BankAccounts> {
  const BankAccountsCompanion({
    required String id,
    required String storeId,
    required String bankCode,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required bool isDefault,
    required int createdAt,
    required int updatedAt,
    int deletedAt = const Value.absent(),
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> bankCode;
  final Value<String> bankName;
  final Value<String> accountNumber;
  final Value<String> accountName;
  final Value<bool> isDefault;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> deletedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class AppSettingsCompanion extends UpdateCompanion<AppSettings> {
  const AppSettingsCompanion({
    required String key,
    required String value,
    required int updatedAt,
  });

  final Value<String> key;
  final Value<String> value;
  final Value<int> updatedAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

class AiParseLogsCompanion extends UpdateCompanion<AiParseLogs> {
  const AiParseLogsCompanion({
    required String id,
    required String storeId,
    required String source,
    required String inputText,
    String parsedJson = const Value.absent(),
    required bool success,
    String errorMessage = const Value.absent(),
    required int createdAt,
  });

  final Value<String> id;
  final Value<String> storeId;
  final Value<String> source;
  final Value<String> inputText;
  final Value<String> parsedJson;
  final Value<bool> success;
  final Value<String> errorMessage;
  final Value<int> createdAt;

  Map<String, Expression> toColumns(bool nullToAbsent) => {};
}

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
