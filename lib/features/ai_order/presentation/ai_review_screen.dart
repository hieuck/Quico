import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/ai/parser/parsed_order_models.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../orders/domain/order.dart';
import '../../orders/domain/order_calculation_service.dart';
import '../../orders/data/order_repository.dart';
import '../../../l10n/l10n_extension.dart';

final _draftProvider = StateProvider<ParsedOrderDraft?>((ref) => null);

class AiReviewScreen extends ConsumerWidget {
  const AiReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(_draftProvider);

    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiem tra don')),
        body: const Center(child: Text('No order data.')),
      );
    }

    final hasBlocking = draft.warnings.any((w) => w.blocking);

    return Scaffold(
      appBar: AppBar(title: const Text('Kiem tra don hang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Tao tu: ${_sourceText(draft.source)}', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Noi dung goc', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(draft.originalInput, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          if (draft.customerHint != null) ...[
            const SizedBox(height: 8),
            Text('Khach: ${draft.customerHint}', style: TextStyle(color: Colors.blue.shade700)),
          ],
          const Divider(height: 24),
          ...draft.items.map((item) => Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.rawName, style: const TextStyle(fontWeight: FontWeight.w600))),
                      _buildConfidenceBadge(item.productMatch?.confidence),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('SL: ${item.quantity}'),
                      const SizedBox(width: 16),
                      if (item.unitPrice != null)
                        Text('Gia: ${CurrencyFormatter.format(item.unitPrice!)}'),
                    ],
                  ),
                  if (item.productMatch != null && item.productMatch!.confidence == ProductMatchConfidence.unknown)
                    Text('San pham chua co trong danh sach', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),
                ],
              ),
            ),
          )),
          if (draft.note != null) ...[
            const Divider(),
            Text('Ghi chu: ${draft.note}', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Sua'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: hasBlocking ? null : () => _completeOrder(context, ref, draft),
                  child: Text(context.l10n.completeOrder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(ProductMatchConfidence? confidence) {
    if (confidence == null) return const SizedBox.shrink();
    switch (confidence) {
      case ProductMatchConfidence.exact:
      case ProductMatchConfidence.high:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Text('Matched', style: TextStyle(fontSize: 11, color: Colors.green)),
        );
      case ProductMatchConfidence.medium:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Text('Can kiem tra', style: TextStyle(fontSize: 11, color: Colors.orange)),
        );
      case ProductMatchConfidence.low:
      case ProductMatchConfidence.unknown:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Text('San pham moi', style: TextStyle(fontSize: 11, color: Colors.red)),
        );
    }
  }

  String _sourceText(String source) {
    switch (source) {
      case 'voice': return 'Giong noi';
      case 'text': return 'Van ban';
      case 'screenshot': return 'Anh tin nhan';
      default: return source;
    }
  }

  Future<void> _completeOrder(BuildContext context, WidgetRef ref, ParsedOrderDraft draft) async {
    final confirmed = await ConfirmDialog.show(context, title: context.l10n.confirmOrder, message: 'Xac nhan hoan tat don hang nay?');
    if (!confirmed || !context.mounted) return;

    try {
      final db = ref.read(appDatabaseProvider);
      final repo = OrderRepository(db);
      final settings = await (db.select(db.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
      if (settings == null) return;

      final items = draft.items.map((item) => CartItem(
        productId: item.productMatch?.productId,
        productName: item.rawName,
        quantity: item.quantity,
        unitPrice: item.unitPrice ?? 0,
      )).toList();

      await repo.completeOrder(CompleteOrderInput(
        storeId: settings.value,
        items: items,
        paymentStatus: 'paid',
        paymentMethod: 'cash',
        paidAmount: items.fold(0, (s, i) => s + i.lineTotal),
        source: draft.source,
        originalInput: draft.originalInput,
        note: draft.note,
      ));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Don hang da tao!')));
        context.go('/orders');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.orderFailed)));
      }
    }
  }
}
