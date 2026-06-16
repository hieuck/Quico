import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/currency_formatter.dart';
import '../../../core/receipt/receipt_renderer.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../l10n/l10n_extension.dart';

final _receiptDataProvider = FutureProvider.autoDispose.family<ReceiptData?, String>((ref, orderId) async {
  final database = ref.read(appDatabaseProvider);
  final order = await (database.select(database.orders)..where((t) => t.id.equals(orderId))).getSingleOrNull();
  if (order == null) return null;
  final items = await (database.select(database.orderItems)..where((t) => t.orderId.equals(orderId))).get();
  final store = await (database.select(database.stores)..where((t) => t.id.equals(order.storeId))).getSingleOrNull();
  return ReceiptData(
    storeName: store?.name ?? 'Quico',
    orderCode: order.orderCode,
    createdAt: order.createdAt,
    items: items.map((i) => ReceiptItem(
      productName: i.productName,
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      lineTotal: i.lineTotal,
    )).toList(),
    subtotal: order.subtotal,
    discountAmount: order.discountAmount,
    totalAmount: order.totalAmount,
    paymentStatus: order.paymentStatus,
    paymentMethod: order.paymentMethod ?? 'cash',
    note: order.note,
  );
});

class ReceiptScreen extends ConsumerWidget {
  final String orderId;
  const ReceiptScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = ref.watch(_receiptDataProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.receipt)),
      body: receiptAsync.when(
        data: (receipt) {
          if (receipt == null) return Center(child: Text(context.l10n.error));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: Text(receipt.storeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 4),
              Center(child: Text(receipt.orderCode, style: const TextStyle(fontSize: 16))),
              Center(child: Text(_formatDate(receipt.createdAt), style: TextStyle(color: Colors.grey.shade600))),
              if (receipt.customerName != null) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Khach: ${receipt.customerName}', style: TextStyle(color: Colors.blue.shade700)),
              ),
              const Divider(height: 32),
              ...receipt.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${item.productName} x${item.quantity}')),
                    Text(CurrencyFormatter.format(item.lineTotal)),
                  ],
                ),
              )),
              const Divider(),
              _totalRow(context.l10n.subtotal, CurrencyFormatter.format(receipt.subtotal)),
              if (receipt.discountAmount > 0) _totalRow(context.l10n.discount, '-${CurrencyFormatter.format(receipt.discountAmount)}'),
              _totalRow(context.l10n.total, CurrencyFormatter.format(receipt.totalAmount), bold: true),
              const SizedBox(height: 8),
              Text('Thanh toan: ${_paymentStatusText(receipt.paymentStatus)}', style: TextStyle(color: Colors.grey.shade600)),
              Text('Phuong thuc: ${_paymentMethodText(receipt.paymentMethod)}', style: TextStyle(color: Colors.grey.shade600)),
              if (receipt.note != null) Text('Ghi chu: ${receipt.note}', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),
              Center(child: Text(context.l10n.receiptFooter, style: TextStyle(color: Colors.grey.shade500))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => SharePlus.instance.share(ShareParams(text: '${receipt.storeName}\n${receipt.orderCode}\nTong: ${CurrencyFormatter.format(receipt.totalAmount)}')),
                  icon: const Icon(Icons.share),
                  label: const Text('Chia se hoa don'),
                ),
              ),
            ],
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const LoadingState(),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(value, style: bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null),
      ]),
    );
  }

  String _formatDate(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} ${d.day}/${d.month}/${d.year}';
  }

  String _paymentStatusText(String s) {
    switch (s) { case 'paid': return 'Paid'; case 'unpaid': return 'Unpaid'; case 'partial': return 'Partial'; default: return s; }
  }

  String _paymentMethodText(String m) {
    switch (m) { case 'cash': return 'Cash'; case 'bank_transfer': return 'Bank Transfer'; default: return 'Other'; }
  }
}
