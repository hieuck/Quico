import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/customer.dart';
import '../../../l10n/l10n_extension.dart';

final _customerListProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  final database = ref.read(appDatabaseProvider);
  final settings = await (await database.database).query('app_settings');
  if (settings == null) return [];
  final rows = await (await database.database).query('customers')
    
    
  );
  return rows.map((r) => Customer(
    id: r.id,
    storeId: r.storeId,
    name: r.name,
    phone: r.phone,
    note: r.note,
    totalSpent: r.totalSpent,
    totalOrders: r.totalOrders,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    deletedAt: r.deletedAt,
  )).toList();
});

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(_customerListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.customer)),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return EmptyState(icon: Icons.people, title: context.l10n.noCustomers, description: context.l10n.noCustomers);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = customers[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text('${CurrencyFormatter.format(c.totalSpent)} . ${c.totalOrders} don'),
                onTap: () => context.push('/customers/${c.id}'),
              );
            },
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_customer',
        onPressed: () => context.push('/customers/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
