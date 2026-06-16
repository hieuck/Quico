import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../l10n/l10n_extension.dart';

final _expenseListProvider = FutureProvider.autoDispose<List<ExpenseRow>>((ref) async {
  final database = ref.read(db.appDatabaseProvider);
  final settings = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
  if (settings == null) return [];
  return await (database.select(database.expenses)
    ..where((t) => t.storeId.equals(settings.value))
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => db.OrderingTerm(expression: t.spentAt, mode: db.OrderingMode.desc)])
  ).get();
});

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(_expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.expenses)),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return EmptyState(icon: Icons.money_off, title: context.l10n.noExpenses, description: 'Ghi lai chi phi de biet loi nhuan thuc te.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = expenses[i];
              return ListTile(
                title: Text(e.category),
                subtitle: Text(_formatDate(e.spentAt)),
                trailing: Text(CurrencyFormatter.format(e.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
              );
            },
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'Add Expense',
        onPressed: () => context.push('/expenses/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.day}/${d.month}/${d.year}';
  }
}
