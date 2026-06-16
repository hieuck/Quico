import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/loading_state.dart';
import '../data/report_repository.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../l10n/l10n_extension.dart';

final _reportProvider = FutureProvider.autoDispose((ref) async {
  final db = ref.read(appDatabaseProvider);
  final settings = await (db.select(db.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
  if (settings == null) return null;
  final repo = ReportRepository(db);
  final today = await repo.getDashboardSummary(settings.value);
  final bestSelling = await repo.getBestSellingProducts(settings.value, DateTimeUtils.thisMonth());
  return (summary: today, bestSelling: bestSelling);
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(_reportProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reports)),
      body: reportAsync.when(
        data: (data) {
          if (data == null) return Center(child: Text(context.l10n.noStore));
          final summary = data.summary;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(context.l10n.revenueToday, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              AppCard(child: Column(
                children: [
                  _reportRow(context.l10n.revenueToday, CurrencyFormatter.format(summary.revenue)),
                  _reportRow(context.l10n.grossProfit, CurrencyFormatter.format(summary.grossProfit)),
                  _reportRow(context.l10n.expenses, CurrencyFormatter.format(summary.expenses)),
                  const Divider(),
                  _reportRow('Lai rong', CurrencyFormatter.format(summary.netProfit), bold: true),
                  const SizedBox(height: 8),
                  _reportRow(context.l10n.ordersToday, summary.orderCount.toString()),
                ],
              )),
              if (data.bestSelling.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('San pham ban chay (thang nay)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...data.bestSelling.take(5).map((p) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(p.productName)),
                        Text('${p.quantity} luot', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const LoadingState(),
      ),
    );
  }

  Widget _reportRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
      ]),
    );
  }
}
