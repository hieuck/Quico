import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/date_time_utils.dart';
import '../domain/order.dart';

class OrderRepository {
  final AppDatabase _db;

  OrderRepository(this._db);

  Future<Database> get _d => _db.database;

  Future<String> generateNextOrderCode(String storeId) async {
    final db = await _d;
    final key = 'order_sequence:$storeId';
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [key]);
    int nextSeq = 1;
    if (rows.isNotEmpty) {
      nextSeq = int.tryParse(rows.first['value'] as String?) ?? 1;
    }
    await db.insert('app_settings', {
      'key': key,
      'value': (nextSeq + 1).toString(),
      'updated_at': DateTimeUtils.nowMillis(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return 'DH${nextSeq.toString().padLeft(6, '0')}';
  }

  Future<Order> completeOrder(CompleteOrderInput input) async {
    final db = await _d;
    final now = DateTimeUtils.nowMillis();
    final orderId = IdGenerator.newId();
    final orderCode = await generateNextOrderCode(input.storeId);

    final subtotal = input.items.fold(0, (s, i) => s + (i.quantity * i.unitPrice));
    final totalAmount = subtotal - input.discountAmount >= 0 ? subtotal - input.discountAmount : 0;
    final costAmount = input.items.fold(0, (s, i) => s + (i.quantity * i.costPrice));
    final grossProfit = totalAmount - costAmount;

    await db.insert('orders', {
      'id': orderId,
      'store_id': input.storeId,
      'customer_id': input.customerId,
      'order_code': orderCode,
      'status': 'paid',
      'payment_status': input.paymentStatus ?? 'paid',
      'payment_method': input.paymentMethod,
      'subtotal': subtotal,
      'discount_amount': input.discountAmount,
      'total_amount': totalAmount,
      'cost_amount': costAmount,
      'gross_profit': grossProfit,
      'paid_amount': input.paidAmount,
      'source': input.source,
      'original_input': input.originalInput,
      'note': input.note,
      'completed_at': now,
      'created_at': now,
      'updated_at': now,
    });

    Batch? batch;
    for (final item in input.items) {
      final lineTotal = (item.quantity * item.unitPrice) - item.discountAmount;
      final lineProfit = lineTotal - (item.quantity * item.costPrice);
      await db.insert('order_items', {
        'id': IdGenerator.newId(),
        'order_id': orderId,
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'cost_price': item.costPrice,
        'discount_amount': item.discountAmount,
        'line_total': lineTotal,
        'line_profit': lineProfit,
        'note': item.note,
        'created_at': now,
        'updated_at': now,
      });

      if (item.productId != null) {
        await db.insert('inventory_movements', {
          'id': IdGenerator.newId(),
          'store_id': input.storeId,
          'product_id': item.productId,
          'type': 'sale',
          'quantity_delta': -item.quantity,
          'quantity_after': 0,
          'reference_type': 'order',
          'reference_id': orderId,
          'created_at': now,
        });
        await db.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity - ?, updated_at = ? WHERE id = ?',
          [item.quantity, now, item.productId],
        );
      }
    }

    if (input.customerId != null) {
      final paidRows = await db.query('orders',
        where: 'customer_id = ? AND status = ?',
        whereArgs: [input.customerId, 'paid'],
      );
      final totalSpent = paidRows.fold<int>(0, (s, r) => s + (r['total_amount'] as int));
      await db.update('customers',
        {'total_orders': paidRows.length, 'total_spent': totalSpent, 'updated_at': now},
        where: 'id = ?', whereArgs: [input.customerId],
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
  }

  Future<Order?> getOrderById(String id) async {
    final db = await _d;
    final rows = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _orderFromRow(rows.first);
  }

  Future<List<Order>> listOrders(OrderFilter filter) async {
    final db = await _d;
    var query = 'SELECT * FROM orders';
    final conditions = <String>[];
    final args = <dynamic>[];
    if (filter.status != null) {
      conditions.add('status = ?');
      args.add(filter.status);
    }
    if (filter.paymentStatus != null) {
      conditions.add('payment_status = ?');
      args.add(filter.paymentStatus);
    }
    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(" AND ")}';
    }
    query += ' ORDER BY created_at DESC';
    if (filter.limit != null) query += ' LIMIT ${filter.limit}';
    if (filter.offset != null) query += ' OFFSET ${filter.offset}';

    final rows = await db.rawQuery(query, args);
    return rows.map(_orderFromRow).toList();
  }

  Future<void> cancelOrder(String orderId) async {
    final db = await _d;
    final now = DateTimeUtils.nowMillis();
    await db.update('orders', {'status': 'cancelled', 'cancelled_at': now, 'updated_at': now},
        where: 'id = ?', whereArgs: [orderId]);

    final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);
    for (final item in items) {
      if (item['product_id'] != null) {
        await db.rawUpdate(
          'UPDATE products SET stock_quantity = stock_quantity + ?, updated_at = ? WHERE id = ?',
          [item['quantity'], now, item['product_id']],
        );
      }
    }
  }

  Order _orderFromRow(Map<String, dynamic> row) {
    return Order(
      id: row['id'],
      storeId: row['store_id'],
      customerId: row['customer_id'] as String?,
      orderCode: row['order_code'] as String,
      status: row['status'] as String,
      paymentStatus: row['payment_status'] as String,
      paymentMethod: row['payment_method'] as String?,
      subtotal: (row['subtotal'] as num).toInt(),
      discountAmount: (row['discount_amount'] as num).toInt(),
      totalAmount: (row['total_amount'] as num).toInt(),
      costAmount: (row['cost_amount'] as num).toInt(),
      grossProfit: (row['gross_profit'] as num).toInt(),
      paidAmount: (row['paid_amount'] as num).toInt(),
      source: row['source'] as String,
      originalInput: row['original_input'] as String?,
      note: row['note'] as String?,
      completedAt: row['completed_at'] as int?,
      cancelledAt: row['cancelled_at'] as int?,
      createdAt: (row['created_at'] as num).toInt(),
      updatedAt: (row['updated_at'] as num).toInt(),
    );
  }
}
