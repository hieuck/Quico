import 'package:drift/drift.dart';
import '../../../core/database/app_db.dart' as db;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/date_time_utils.dart';
import '../domain/product.dart';

class ProductRepository {
  final db.AppDatabase _db;

  ProductRepository(this._db);

  Future<List<Product>> listProducts(String storeId) async {
    final rows = await (_db.select(_db.products)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => db.OrderingTerm(expression: t.name, mode: db.OrderingMode.asc)])
    ).get();
    return rows.map(_toDomain).toList();
  }

  Future<List<Product>> listActiveProducts(String storeId) async {
    final rows = await (_db.select(_db.products)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.isActive.equals(true))
      ..where((t) => t.deletedAt.isNull())
    ).get();
    return rows.map(_toDomain).toList();
  }

  Future<List<Product>> searchProducts(String storeId, String query) async {
    final normalized = TextNormalizer.normalize(query);
    final rows = await (_db.select(_db.products)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.deletedAt.isNull())
    ).get();
    return rows
        .map(_toDomain)
        .where((p) =>
            p.normalizedName.contains(normalized) ||
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            (p.sku?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  Future<List<Product>> listLowStockProducts(String storeId) async {
    final rows = await (_db.select(_db.products)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.deletedAt.isNull())
      ..where((t) => t.isActive.equals(true))
    ).get();
    return rows.map(_toDomain).where((p) => p.isLowStock).toList();
  }

  Future<Product?> getProductById(String id) async {
    final row = await (_db.select(_db.products)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Future<Product> createProduct(CreateProductInput input) async {
    final now = DateTimeUtils.nowMillis();
    final id = IdGenerator.newId();
    final normalizedName = TextNormalizer.normalize(input.name);
    final normalizedFull = TextNormalizer.expandAbbreviations(input.name);

    _db.into(_db.products).insert(ProductsCompanion.insert(
      id: id,
      storeId: input.storeId,
      name: input.name,
      normalizedName: normalizedFull,
      costPrice: input.costPrice,
      salePrice: input.salePrice,
      stockQuantity: input.stockQuantity,
      lowStockThreshold: input.lowStockThreshold,
      imagePath: input.imagePath != null ? db.Value(input.imagePath!) : Value.absent(),
      sku: input.sku != null ? db.Value(input.sku!) : Value.absent(),
      barcode: input.barcode != null ? db.Value(input.barcode!) : Value.absent(),
      createdAt: now,
      updatedAt: now,
    ));

    if (input.stockQuantity > 0) {
      _db.into(_db.inventoryMovements).insert(InventoryMovementsCompanion.insert(
        id: IdGenerator.newId(),
        storeId: input.storeId,
        productId: id,
        type: 'initial',
        quantityDelta: input.stockQuantity,
        quantityAfter: input.stockQuantity,
        createdAt: now,
      ));
    }

    final created = await getProductById(id);
    return created!;
  }

  Future<Product> updateProduct(UpdateProductInput input) async {
    final now = DateTimeUtils.nowMillis();
    final updates = <String, dynamic>{};

    if (input.name != null) {
      updates['name'] = input.name;
      updates['normalized_name'] = TextNormalizer.expandAbbreviations(input.name!);
    }
    if (input.sku != null) updates['sku'] = input.sku;
    if (input.barcode != null) updates['barcode'] = input.barcode;
    if (input.costPrice != null) updates['cost_price'] = input.costPrice;
    if (input.salePrice != null) updates['sale_price'] = input.salePrice;
    if (input.stockQuantity != null) updates['stock_quantity'] = input.stockQuantity;
    if (input.lowStockThreshold != null) updates['low_stock_threshold'] = input.lowStockThreshold;
    if (input.imagePath != null) updates['image_path'] = input.imagePath;
    if (input.isActive != null) updates['is_active'] = input.isActive;
    updates['updated_at'] = now;

    await (_db.update(_db.products)..where((t) => t.id.equals(input.id))).write(
      ProductsCompanion.custom(updates),
    );

    final updated = await getProductById(input.id);
    return updated!;
  }

  Future<void> deactivateProduct(String id) async {
    await updateProduct(UpdateProductInput(id: id, isActive: false));
  }

  Future<void> softDeleteProduct(String id) async {
    final now = DateTimeUtils.nowMillis();
    await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion.custom({'deleted_at': now, 'updated_at': now}),
    );
  }

  Product _toDomain(ProductRow row) {
    return Product(
      id: row.id,
      storeId: row.storeId,
      name: row.name,
      normalizedName: row.normalizedName,
      sku: row.sku,
      barcode: row.barcode,
      costPrice: row.costPrice,
      salePrice: row.salePrice,
      stockQuantity: row.stockQuantity,
      lowStockThreshold: row.lowStockThreshold,
      imagePath: row.imagePath,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}
