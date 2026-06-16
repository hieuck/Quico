import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../domain/order.dart';

class OrderRepository {
  final db.AppDatabase _db;

  OrderRepository(this._db);

  Future<String> generateNextOrderCode(String storeId) async {
    final settings = _db.select(_db.appSettings);
    final key = 'order_sequence:$storeId';
    final row = await (settings..where((t) => t.key.equals(key))).getSingleOrNull();
    int nextSeq = 1;
    if (row != null) {
      nextSeq = int.tryParse(row.value) ?? 1;
    }
    await (settings..where((t) => t.key.equals(key))).upsert(db.AppSettingsCompanion.insert(
      key: key,
      value: (nextSeq + 1).toString(),
      updatedAt: DateTimeUtils.nowMillis(),
    ));
    return 'DH${nextSeq.toString().padLeft(6, '0')}';
  }

  Future<Order> completeOrder(CompleteOrderInput input) async {
    return await _db.transaction(() async {
      final now = DateTimeUtils.nowMillis();
      final orderId = IdGenerator.newId();
      final orderCode = await generateNextOrderCode(input.storeId);

      final items = input.items;
      final subtotal = items.fold(0, (s, i) => s + (i.quantity * i.unitPrice));
      final totalAmount = subtotal - input.discountAmount >= 0 ? subtotal - input.discountAmount : 0;
      final costAmount = items.fold(0, (s, i) => s + (i.quantity * i.costPrice));
      final grossProfit = totalAmount - costAmount;

      _db.into(_db.orders).insert(db.OrdersCompanion.insert(
        id: orderId,
        storeId: input.storeId,
        customerId: input.customerId != null ? db.Value(input.customerId!) : Value.absent(),
        orderCode: orderCode,
        status: const Constant('paid'),
        paymentStatus: input.paymentStatus as String,
        paymentMethod: input.paymentMethod != null ? db.Value(input.paymentMethod!) : Value.absent(),
        subtotal: subtotal,
        discountAmount: input.discountAmount,
        totalAmount: totalAmount,
        costAmount: costAmount,
        grossProfit: grossProfit,
        paidAmount: input.paidAmount,
        source: input.source,
        originalInput: input.originalInput != null ? db.Value(input.originalInput!) : Value.absent(),
        note: input.note != null ? db.Value(input.note!) : Value.absent(),
        completedAt: db.Value(now),
        createdAt: now,
        updatedAt: now,
      ));

      for (final item in items) {
        final lineTotal = (item.quantity * item.unitPrice) - item.discountAmount;
        final lineProfit = lineTotal - (item.quantity * item.costPrice);
        _db.into(_db.orderItems).insert(db.OrderItemsCompanion.insert(
          id: IdGenerator.newId(),
          orderId: orderId,
          productId: item.productId != null ? db.Value(item.productId!) : Value.absent(),
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          costPrice: item.costPrice,
          discountAmount: item.discountAmount,
          lineTotal: lineTotal,
          lineProfit: lineProfit,
          note: item.note != null ? db.Value(item.note!) : Value.absent(),
          createdAt: now,
          updatedAt: now,
        ));

        if (item.productId != null) {
          _db.into(_db.inventoryMovements).insert(db.InventoryMovementsCompanion.insert(
            id: IdGenerator.newId(),
            storeId: input.storeId,
            productId: item.productId!,
            type: 'sale',
            quantityDelta: -item.quantity,
            quantityAfter: 0,
            referenceType: const db.Value('order'),
            referenceId: db.Value(orderId),
            createdAt: now,
          ));

          final product = await (_db.select(_db.products)..where((t) => t.id.equals(item.productId!))).getSingleOrNull();
          if (product != null) {
            final newStock = product.stockQuantity - item.quantity;
            await (_db.update(_db.products)..where((t) => t.id.equals(item.productId!))).write(
              db.ProductsCompanion.custom({'stock_quantity': newStock, 'updated_at': now}),
            );
          }
        }
      }

      if (input.customerId != null) {
        final customerOrders = await (_db.select(_db.orders)
          ..where((t) => t.customerId.equals(input.customerId!))
          ..where((t) => t.status.equals('paid'))
        ).get();
        final totalSpent = customerOrders.fold(0, (s, o) => s + o.totalAmount);
        await (_db.update(_db.customers)..where((t) => t.id.equals(input.customerId!))).write(
          db.CustomersCompanion.custom({
            'total_orders': customerOrders.length,
            'total_spent': totalSpent,
            'updated_at': now,
          }),
        );
      }

      return Order(
        id: orderId,
        storeId: input.storeId,
        customerId: input.customerId,
        orderCode: orderCode,
        status: 'paid',
        paymentStatus: input.paymentStatus ?? 'paid',
        paymentMethod: input.paymentMethod,
        subtotal: subtotal,
        discountAmount: input.discountAmount,
        totalAmount: totalAmount,
        costAmount: costAmount,
        grossProfit: grossProfit,
        paidAmount: input.paidAmount,
        source: input.source,
        originalInput: input.originalInput,
        note: input.note,
        completedAt: now,
        cancelledAt: null,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<Order?> getOrderById(String id) async {
    final row = await (_db.select(_db.orders)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Order(
      id: row.id,
      storeId: row.storeId,
      customerId: row.customerId,
      orderCode: row.orderCode,
      status: row.status,
      paymentStatus: row.paymentStatus,
      paymentMethod: row.paymentMethod,
      subtotal: row.subtotal,
      discountAmount: row.discountAmount,
      totalAmount: row.totalAmount,
      costAmount: row.costAmount,
      grossProfit: row.grossProfit,
      paidAmount: row.paidAmount,
      source: row.source,
      originalInput: row.originalInput,
      note: row.note,
      completedAt: row.completedAt,
      cancelledAt: row.cancelledAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<List<Order>> listOrders(OrderFilter filter) async {
    var query = _db.select(_db.orders)..orderBy([(t) => db.OrderingTerm(expression: t.createdAt, mode: db.OrderingMode.desc)]);
    if (filter.status != null) {
      query.where((t) => t.status.equals(filter.status!));
    }
    if (filter.paymentStatus != null) {
      query.where((t) => t.paymentStatus.equals(filter.paymentStatus!));
    }
    if (filter.limit != null) {
      query.limit(filter.limit!);
    }
    if (filter.offset != null) {
      query.offset(filter.offset!);
    }
    final rows = await query.get();
    return rows.map((r) => Order(
      id: r.id,
      storeId: r.storeId,
      customerId: r.customerId,
      orderCode: r.orderCode,
      status: r.status,
      paymentStatus: r.paymentStatus,
      paymentMethod: r.paymentMethod,
      subtotal: r.subtotal,
      discountAmount: r.discountAmount,
      totalAmount: r.totalAmount,
      costAmount: r.costAmount,
      grossProfit: r.grossProfit,
      paidAmount: r.paidAmount,
      source: r.source,
      originalInput: r.originalInput,
      note: r.note,
      completedAt: r.completedAt,
      cancelledAt: r.cancelledAt,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    )).toList();
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.transaction(() async {
      final now = DateTimeUtils.nowMillis();
      final order = await getOrderById(orderId);
      if (order == null) return;

      await (_db.update(_db.orders)..where((t) => t.id.equals(orderId))).write(
        db.OrdersCompanion.custom({
          'status': 'cancelled',
          'cancelled_at': now,
          'updated_at': now,
        }),
      );

      final items = await (_db.select(_db.orderItems)..where((t) => t.orderId.equals(orderId))).get();
      for (final item in items) {
        if (item.productId != null) {
          final product = await (_db.select(_db.products)..where((t) => t.id.equals(item.productId!))).getSingleOrNull();
          if (product != null) {
            final newStock = product.stockQuantity + item.quantity;
            await (_db.update(_db.products)..where((t) => t.id.equals(item.productId!))).write(
              db.ProductsCompanion.custom({'stock_quantity': newStock, 'updated_at': now}),
            );
          }
        }
      }
    });
  }
}
