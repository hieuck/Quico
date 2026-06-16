// Stub companion classes for Drift-compatibility
// These convert named-parameter insert calls to Map<String, dynamic>

class CustomersCompanion {
  static Map<String, dynamic> insert({
    required String id,
    required String storeId,
    required String name,
    String? phone,
    String? note,
    required int createdAt,
    required int updatedAt,
  }) {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'phone': phone,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ExpensesCompanion {
  static Map<String, dynamic> insert({
    required String id,
    required String storeId,
    required String category,
    required int amount,
    String? note,
    required int spentAt,
    required int createdAt,
    required int updatedAt,
  }) {
    return {
      'id': id,
      'store_id': storeId,
      'category': category,
      'amount': amount,
      'note': note,
      'spent_at': spentAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductsCompanion {
  static Map<String, dynamic> insert({
    required String id,
    required String storeId,
    required String name,
    required int salePrice,
    required int createdAt,
    required int updatedAt,
    String? normalizedName,
    int costPrice = 0,
    int stockQuantity = 0,
    int lowStockThreshold = 5,
    String? imagePath,
    String? sku,
    String? barcode,
  }) {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'normalized_name': normalizedName ?? name,
      'sku': sku,
      'barcode': barcode,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'image_path': imagePath,
      'is_active': 1,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class BankAccountsCompanion {
  static Map<String, dynamic> insert({
    required String id,
    required String storeId,
    required String bankCode,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required int createdAt,
    required int updatedAt,
  }) {
    return {
      'id': id,
      'store_id': storeId,
      'bank_code': bankCode,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'is_default': 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class AppSettingsCompanion {
  static Map<String, dynamic> insert({
    required String key,
    required String value,
    required int updatedAt,
  }) {
    return {'key': key, 'value': value, 'updated_at': updatedAt};
  }
}

class StoresCompanion {
  static Map<String, dynamic> custom(Map<String, dynamic> values) => values;

  Map<String, dynamic> Function(Map<String, dynamic>)? _custom;
  StoresCompanion({Map<String, dynamic>? custom}) {
    _custom = (v) => custom ?? v;
  }

  factory StoresCompanion.fromMap(Map<String, dynamic> map) => StoresCompanion();
}
