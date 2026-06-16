class Product {
  final String id;
  final String storeId;
  final String name;
  final String normalizedName;
  final String? sku;
  final String? barcode;
  final int costPrice;
  final int salePrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? imagePath;
  final bool isActive;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.normalizedName,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sku,
    this.barcode,
    this.imagePath,
    this.deletedAt,
  });

  bool get isLowStock => stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity <= 0;
}

class CreateProductInput {
  final String storeId;
  final String name;
  final String? sku;
  final String? barcode;
  final int costPrice;
  final int salePrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String? imagePath;

  const CreateProductInput({
    required this.storeId,
    required this.name,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.sku,
    this.barcode,
    this.imagePath,
  });
}

class UpdateProductInput {
  final String id;
  final String? name;
  final String? sku;
  final String? barcode;
  final int? costPrice;
  final int? salePrice;
  final int? stockQuantity;
  final int? lowStockThreshold;
  final String? imagePath;
  final bool? isActive;

  const UpdateProductInput({
    required this.id,
    this.name,
    this.sku,
    this.barcode,
    this.costPrice,
    this.salePrice,
    this.stockQuantity,
    this.lowStockThreshold,
    this.imagePath,
    this.isActive,
  });
}
