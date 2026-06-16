import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';

class InventoryService {
  final AppDatabase _db;

  InventoryService(this._db);

  Future<void> applySaleMovement({
    required String storeId,
    required String productId,
    required String orderId,
    required int quantitySold,
  }) async {
    final now = DateTimeUtils.nowMillis();
    final product = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (product == null) return;

    final newStock = product.stockQuantity - quantitySold;
    _db.into(_db.inventoryMovements).insert(InventoryMovementsCompanion.insert(
      id: IdGenerator.newId(),
      storeId: storeId,
      productId: productId,
      type: 'sale',
      quantityDelta: -quantitySold,
      quantityAfter: newStock,
      referenceType: const Value('order'),
      referenceId: Value(orderId),
      createdAt: now,
    ));

    await (_db.update(_db.products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion.custom({'stock_quantity': newStock, 'updated_at': now}),
    );
  }

  Future<void> applyRefundMovement({
    required String storeId,
    required String productId,
    required String orderId,
    required int quantityRestored,
  }) async {
    final now = DateTimeUtils.nowMillis();
    final product = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (product == null) return;

    final newStock = product.stockQuantity + quantityRestored;
    _db.into(_db.inventoryMovements).insert(InventoryMovementsCompanion.insert(
      id: IdGenerator.newId(),
      storeId: storeId,
      productId: productId,
      type: 'refund',
      quantityDelta: quantityRestored,
      quantityAfter: newStock,
      referenceType: const Value('order'),
      referenceId: Value(orderId),
      createdAt: now,
    ));

    await (_db.update(_db.products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion.custom({'stock_quantity': newStock, 'updated_at': now}),
    );
  }

  Future<void> adjustStock({
    required String storeId,
    required String productId,
    required int newQuantity,
    required String note,
  }) async {
    final now = DateTimeUtils.nowMillis();
    final product = await (_db.select(_db.products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (product == null) return;

    final delta = newQuantity - product.stockQuantity;
    _db.into(_db.inventoryMovements).insert(InventoryMovementsCompanion.insert(
      id: IdGenerator.newId(),
      storeId: storeId,
      productId: productId,
      type: 'correction',
      quantityDelta: delta,
      quantityAfter: newQuantity,
      note: Value(note),
      createdAt: now,
    ));

    await (_db.update(_db.products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion.custom({'stock_quantity': newQuantity, 'updated_at': now}),
    );
  }

  Future<List<InventoryMovementRow>> listMovements(String productId) async {
    return await (_db.select(_db.inventoryMovements)
      ..where((t) => t.productId.equals(productId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).get();
  }
}
