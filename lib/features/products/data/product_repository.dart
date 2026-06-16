import 'dart:io' show File;
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../core/utils/date_time_utils.dart';
import '../domain/product.dart';

class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  Future<Database> get _database => _db.database;

  Future<List<Product>> listProducts(String storeId) async {
    final db = await _database;
    final rows = await db.query('products',
      where: 'store_id = ? AND deleted_at IS NULL',
      whereArgs: [storeId],
      orderBy: 'name ASC',
    );
    return rows.map(_toDomain).toList();
  }

  Future<List<Product>> listActiveProducts(String storeId) async {
    final db = await _database;
    final rows = await db.query('products',
      where: 'store_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [storeId],
    );
    return rows.map(_toDomain).toList();
  }

  Future<List<Product>> searchProducts(String storeId, String query) async {
    final normalized = TextNormalizer.normalize(query);
    final db = await _database;
    final rows = await db.query('products',
      where: 'store_id = ? AND deleted_at IS NULL AND (normalized_name LIKE ? OR name LIKE ? OR sku LIKE ?)',
      whereArgs: [storeId, '%$normalized%', '%$query%', '%$query%'],
    );
    return rows.map(_toDomain).toList();
  }

  Future<List<Product>> listLowStockProducts(String storeId) async {
    final db = await _database;
    final rows = await db.query('products',
      where: 'store_id = ? AND deleted_at IS NULL AND is_active = 1 AND stock_quantity <= low_stock_threshold',
      whereArgs: [storeId],
    );
    return rows.map(_toDomain).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await _database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _toDomain(rows.first);
  }

  Future<Product> createProduct(CreateProductInput input) async {
    final db = await _database;
    final now = DateTimeUtils.nowMillis();
    final id = IdGenerator.newId();
    final normalizedFull = TextNormalizer.expandAbbreviations(input.name);

    await db.insert('products', {
      'id': id,
      'store_id': input.storeId,
      'name': input.name,
      'normalized_name': normalizedFull,
      'sku': input.sku,
      'barcode': input.barcode,
      'cost_price': input.costPrice,
      'sale_price': input.salePrice,
      'stock_quantity': input.stockQuantity,
      'low_stock_threshold': input.lowStockThreshold,
      'image_path': input.imagePath,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    if (input.stockQuantity > 0) {
      await db.insert('inventory_movements', {
        'id': IdGenerator.newId(),
        'store_id': input.storeId,
        'product_id': id,
        'type': 'initial',
        'quantity_delta': input.stockQuantity,
        'quantity_after': input.stockQuantity,
        'created_at': now,
      });
    }

    return (await getProductById(id))!;
  }

  Future<Product> updateProduct(UpdateProductInput input) async {
    final db = await _database;
    final now = DateTimeUtils.nowMillis();
    final values = <String, dynamic>{'updated_at': now};
    if (input.name != null) {
      values['name'] = input.name;
      values['normalized_name'] = TextNormalizer.expandAbbreviations(input.name!);
    }
    if (input.sku != null) values['sku'] = input.sku;
    if (input.barcode != null) values['barcode'] = input.barcode;
    if (input.costPrice != null) values['cost_price'] = input.costPrice;
    if (input.salePrice != null) values['sale_price'] = input.salePrice;
    if (input.stockQuantity != null) values['stock_quantity'] = input.stockQuantity;
    if (input.lowStockThreshold != null) values['low_stock_threshold'] = input.lowStockThreshold;
    if (input.imagePath != null) values['image_path'] = input.imagePath;
    if (input.isActive != null) values['is_active'] = input.isActive == true ? 1 : 0;

    await db.update('products', values, where: 'id = ?', whereArgs: [input.id]);
    return (await getProductById(input.id))!;
  }

  Future<void> deactivateProduct(String id) async {
    await updateProduct(UpdateProductInput(id: id, isActive: false));
  }

  Future<void> softDeleteProduct(String id) async {
    final db = await _database;
    final now = DateTimeUtils.nowMillis();
    await db.update('products', {'deleted_at': now, 'updated_at': now},
        where: 'id = ?', whereArgs: [id]);
  }

  Product _toDomain(Map<String, dynamic> row) {
    return Product(
      id: row['id'],
      storeId: row['store_id'],
      name: row['name'],
      normalizedName: row['normalized_name'],
      sku: row['sku'] as String?,
      barcode: row['barcode'] as String?,
      costPrice: (row['cost_price'] as num).toInt(),
      salePrice: (row['sale_price'] as num).toInt(),
      stockQuantity: (row['stock_quantity'] as num).toInt(),
      lowStockThreshold: (row['low_stock_threshold'] as num).toInt(),
      imagePath: row['image_path'] as String?,
      isActive: row['is_active'] == 1,
      createdAt: (row['created_at'] as num).toInt(),
      updatedAt: (row['updated_at'] as num).toInt(),
      deletedAt: row['deleted_at'] as int?,
    );
  }
}
