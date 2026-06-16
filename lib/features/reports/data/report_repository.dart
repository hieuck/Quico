import 'package:drift/drift.dart';
import '../../../core/database/app_db.dart' as db;
import '../../../core/utils/date_time_utils.dart';

class ReportRepository {
  final db.AppDatabase _db;

  ReportRepository(this._db);

  Future<DashboardSummary> getDashboardSummary(String storeId) async {
    final range = DateTimeUtils.today();
    return await _getSummary(storeId, range);
  }

  Future<DashboardSummary> getRevenueReport(String storeId, DateRange range) async {
    return await _getSummary(storeId, range);
  }

  Future<DashboardSummary> _getSummary(String storeId, DateRange range) async {
    final orders = await (_db.select(__db.orders)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.createdAt.isBetweenValues(range.start, range.end))
      ..where((t) => t.status.isNotIn(['draft', 'cancelled', 'refunded']))
    ).get();

    final revenue = orders.fold<int>(0, (s, o) => s + o.totalAmount);
    final profit = orders.fold<int>(0, (s, o) => s + o.grossProfit);
    final expenseRows = await (_db.select(_db.expenses)
      ..where((t) => t.storeId.equals(storeId))
      ..where((t) => t.spentAt.isBetweenValues(range.start, range.end))
      ..where((t) => t.deletedAt.isNull())
    ).get();
    final expenses = expenseRows.fold<int>(0, (s, e) => s + e.amount);
    final netProfit = profit - expenses;

    return DashboardSummary(
      revenue: revenue,
      orderCount: orders.length,
      grossProfit: profit,
      expenses: expenses,
      netProfit: netProfit,
    );
  }

  Future<List<ProductSalesSummary>> getBestSellingProducts(String storeId, DateRange range) async {
    final items = await (_db.select(__db.orderItems)
      ..join([
        innerJoin(__db.orders, __db.orderItems.orderId.equalsExpressions(__db.orders.id)),
      ])
      ..where(__db.orders.storeId.equals(storeId))
      ..where(__db.orders.createdAt.isBetweenValues(range.start, range.end))
      ..where(__db.orders.status.isNotIn(['draft', 'cancelled', 'refunded']))
    ).get();

    final productMap = <String, ProductSalesSummary>{};
    for (final row in items) {
      final item = row.readTable(__db.orderItems);
      final key = item.productId ?? item.productName;
      productMap.update(key, (existing) {
        return ProductSalesSummary(
          productName: item.productName,
          quantity: existing.quantity + item.quantity,
          revenue: existing.revenue + item.lineTotal,
        );
      }, ifAbsent: () => ProductSalesSummary(
        productName: item.productName,
        quantity: item.quantity,
        revenue: item.lineTotal,
      ));
    }

    return productMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
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
