import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';

class InventoryService {
  final AppDatabase _db;

  InventoryService(this._db);

  Future<Database> get _d => _db.database;

  Future<void> applySaleMovement({
    required String storeId,
    required String productId,
    required String orderId,
    required int quantitySold,
  }) async {
    final db = await _d;
    final now = DateTimeUtils.nowMillis();
    final rows = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (rows.isEmpty) return;
    final currentStock = (rows.first['stock_quantity'] as num).toInt();
    final newStock = currentStock - quantitySold;

    await db.insert('inventory_movements', {
      'id': IdGenerator.newId(),
      'store_id': storeId,
      'product_id': productId,
      'type': 'sale',
      'quantity_delta': -quantitySold,
      'quantity_after': newStock,
      'reference_type': 'order',
      'reference_id': orderId,
      'created_at': now,
    });

    await db.update('products', {'stock_quantity': newStock, 'updated_at': now},
        where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> applyRefundMovement({
    required String storeId,
    required String productId,
    required String orderId,
    required int quantityRestored,
  }) async {
    final db = await _d;
    final now = DateTimeUtils.nowMillis();
    final rows = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (rows.isEmpty) return;
    final currentStock = (rows.first['stock_quantity'] as num).toInt();
    final newStock = currentStock + quantityRestored;

    await db.insert('inventory_movements', {
      'id': IdGenerator.newId(),
      'store_id': storeId,
      'product_id': productId,
      'type': 'refund',
      'quantity_delta': quantityRestored,
      'quantity_after': newStock,
      'reference_type': 'order',
      'reference_id': orderId,
      'created_at': now,
    });

    await db.update('products', {'stock_quantity': newStock, 'updated_at': now},
        where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> adjustStock({
    required String storeId,
    required String productId,
    required int newQuantity,
    required String note,
  }) async {
    final db = await _d;
    final now = DateTimeUtils.nowMillis();
    final rows = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (rows.isEmpty) return;
    final currentStock = (rows.first['stock_quantity'] as num).toInt();
    final delta = newQuantity - currentStock;

    await db.insert('inventory_movements', {
      'id': IdGenerator.newId(),
      'store_id': storeId,
      'product_id': productId,
      'type': 'correction',
      'quantity_delta': delta,
      'quantity_after': newQuantity,
      'note': note,
      'created_at': now,
    });

    await db.update('products', {'stock_quantity': newQuantity, 'updated_at': now},
        where: 'id = ?', whereArgs: [productId]);
  }

  Future<List<Map<String, dynamic>>> listMovements(String productId) async {
    final db = await _d;
    return await db.query('inventory_movements',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
  }
}
