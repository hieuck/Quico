import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../domain/customer.dart';
import '../../../l10n/l10n_extension.dart';

final _customerDetailProvider = FutureProvider.autoDispose.family<Customer?, String>((ref, id) async {
  final database = ref.read(db.appDatabaseProvider);
  final row = await (db.select(db.customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  if (row == null) return null;
  return Customer(
    id: row.id,
    storeId: row.storeId,
    name: row.name,
    phone: row.phone,
    note: row.note,
    totalSpent: row.totalSpent,
    totalOrders: row.totalOrders,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
});

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(_customerDetailProvider(customerId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.customer)),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) return Center(child: Text(context.l10n.error));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(customer.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (customer.phone != null) Text(customer.phone!, style: const TextStyle(color: Colors.grey)),
              if (customer.note != null) Text(customer.note!, style: const TextStyle(color: Colors.grey)),
              const Divider(height: 32),
              _statRow('Tong don', customer.totalOrders.toString()),
              _statRow('Tong chi tieu', CurrencyFormatter.format(customer.totalSpent)),
            ],
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]),
    );
  }
}
