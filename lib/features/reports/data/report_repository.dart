import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_time_utils.dart';

class ReportRepository {
  final AppDatabase _db;

  ReportRepository(this._db);

  Future<Database> get _d => _db.database;

  Future<DashboardSummary> getDashboardSummary(String storeId) async {
    final range = DateTimeUtils.today();
    return _getSummary(storeId, range.start, range.end);
  }

  Future<DashboardSummary> getRevenueReport(String storeId, DateRange range) async {
    return _getSummary(storeId, range.start, range.end);
  }

  Future<DashboardSummary> _getSummary(String storeId, int start, int end) async {
    final db = await _d;
    final orderRows = await db.query('orders',
      where: 'store_id = ? AND created_at >= ? AND created_at <= ? AND status NOT IN (?, ?, ?)',
      whereArgs: [storeId, start, end, 'draft', 'cancelled', 'refunded'],
    );

    final revenue = orderRows.fold<int>(0, (s, r) => s + (r['total_amount'] as num).toInt());
    final grossProfit = orderRows.fold<int>(0, (s, r) => s + (r['gross_profit'] as num).toInt());

    final expenseRows = await db.query('expenses',
      where: 'store_id = ? AND spent_at >= ? AND spent_at <= ? AND deleted_at IS NULL',
      whereArgs: [storeId, start, end],
    );
    final expenses = expenseRows.fold<int>(0, (s, r) => s + (r['amount'] as num).toInt());

    return DashboardSummary(
      revenue: revenue,
      orderCount: orderRows.length,
      grossProfit: grossProfit,
      expenses: expenses,
      netProfit: grossProfit - expenses,
    );
  }

  Future<List<ProductSalesSummary>> getBestSellingProducts(String storeId, DateRange range) async {
    final db = await _d;
    final rows = await db.rawQuery('''
      SELECT oi.product_name, SUM(oi.quantity) as total_qty, SUM(oi.line_total) as total_revenue
      FROM order_items oi
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE o.store_id = ? AND o.created_at >= ? AND o.created_at <= ?
        AND o.status NOT IN ('draft', 'cancelled', 'refunded')
      GROUP BY oi.product_name
      ORDER BY total_qty DESC
    ''', [storeId, range.start, range.end]);

    return rows.map((r) => ProductSalesSummary(
      productName: r['product_name'] as String,
      quantity: (r['total_qty'] as num).toInt(),
      revenue: (r['total_revenue'] as num).toInt(),
    )).toList();
  }
}

class DashboardSummary {
  final int revenue;
  final int orderCount;
  final int grossProfit;
  final int expenses;
  final int netProfit;

  const DashboardSummary({
    required this.revenue,
    required this.orderCount,
    required this.grossProfit,
    required this.expenses,
    required this.netProfit,
  });
}

class ProductSalesSummary {
  final String productName;
  final int quantity;
  final int revenue;

  const ProductSalesSummary({
    required this.productName,
    required this.quantity,
    required this.revenue,
  });
}
