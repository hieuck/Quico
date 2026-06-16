class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty.';
    }
    return null;
  }

  static String? positiveInt(int? value, String fieldName) {
    if (value == null || value <= 0) {
      return '$fieldName must be greater than 0.';
    }
    return null;
  }

  static String? nonNegativeInt(int? value, String fieldName) {
    if (value == null || value < 0) {
      return '$fieldName cannot be negative.';
    }
    return null;
  }

  static String? storeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Store name cannot be empty.';
    }
    if (value.trim().length > 80) {
      return 'Store name max 80 characters.';
    }
    return null;
  }

  static String? productName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name cannot be empty.';
    }
    if (value.trim().length > 120) {
      return 'Product name max 120 characters.';
    }
    return null;
  }

  static String? salePrice(int? value) {
    if (value == null || value < 0) {
      return 'Sale price is invalid.';
    }
    return null;
  }

  static String? costPrice(int? value) {
    if (value == null || value < 0) {
      return 'Cost price is invalid.';
    }
    return null;
  }

  static String? quantity(int? value) {
    if (value == null || value <= 0) {
      return 'Quantity must be greater than 0.';
    }
    return null;
  }

  static String? expenseAmount(int? value) {
    if (value == null || value <= 0) {
      return 'Amount must be greater than 0.';
    }
    return null;
  }
}
