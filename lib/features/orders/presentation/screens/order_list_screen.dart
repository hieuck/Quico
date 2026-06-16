import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart' ;
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/order_repository.dart';
import '../../domain/order.dart';
import '../../../../l10n/l10n_extension.dart';

final _orderListProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final database = ref.read(appDatabaseProvider);
  final repo = OrderRepository(database);
  return repo.listOrders(const OrderFilter(limit: 50));
});

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(_orderListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orders)),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return EmptyState(icon: Icons.receipt, title: context.l10n.noOrders, description: context.l10n.noOrders);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final order = orders[i];
              return ListTile(
                title: Text(order.orderCode),
                subtitle: Text('${_formatTime(order.createdAt)}${order.note != null ? ' . ${order.note}' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(CurrencyFormatter.format(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    StatusBadge.paymentStatus(order.paymentStatus),
                  ],
                ),
                onTap: () => context.push('/orders/${order.id}'),
              );
            },
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _formatTime(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
