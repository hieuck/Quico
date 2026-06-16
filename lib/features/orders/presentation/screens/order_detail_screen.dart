import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../data/order_repository.dart';
import '../../domain/order.dart';
import '../../../../l10n/l10n_extension.dart';

final _orderProvider = FutureProvider.autoDispose.family<Order?, String>((ref, id) async {
  final database = ref.read(db.appDatabaseProvider);
  final repo = OrderRepository(db);
  return repo.getOrderById(id);
});

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(_orderProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orders)),
      body: orderAsync.when(
        data: (order) {
          if (order == null) return Center(child: Text(context.l10n.error));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  StatusBadge.orderStatus(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(_formatDate(order.createdAt), style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.total),
                  Text(CurrencyFormatter.format(order.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              if (order.discountAmount > 0) Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(context.l10n.discount, style: TextStyle(color: Colors.grey.shade600)), Text('-${CurrencyFormatter.format(order.discountAmount)}')],
              ),
              const Divider(height: 32),
              if (order.status != 'cancelled' && order.status != 'refunded')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final confirmed = await ConfirmDialog.show(context, title: context.l10n.cancelOrderConfirm, message: context.l10n.cancelOrderBody, confirmLabel: context.l10n.cancelOrder, destructive: true);
                      if (confirmed) {
                        final database = ref.read(db.appDatabaseProvider);
                        await OrderRepository(db).cancelOrder(orderId);
                        if (context.mounted) context.pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(context.l10n.cancelOrder),
                  ),
                ),
              if (order.status == 'paid' || order.status == 'unpaid') ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/orders/$orderId/receipt'),
                    child: Text(context.l10n.receipt),
                  ),
                ),
              ],
            ],
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _formatDate(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} ${d.day}/${d.month}/${d.year}';
  }
}
