import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart' ;
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/product_image.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../products/data/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../domain/order.dart';
import '../../domain/order_calculation_service.dart';
import '../../data/order_repository.dart';
import '../../../../l10n/l10n_extension.dart';

final _activeProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final database = ref.read(appDatabaseProvider);
  final repo = ProductRepository(db);
  final settings = await (await database.database).query('app_settings');
  if (settings == null) return [];
  return repo.listActiveProducts(settings.value);
});

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _cart = <CartItem>[];
  final _calc = OrderCalculationService();
  String _paymentStatus = 'paid';
  String _paymentMethod = 'cash';

  void _addToCart(Product product) {
    final existing = _cart.where((c) => c.productId == product.id).firstOrNull;
    if (existing != null) {
      setState(() => existing.quantity++);
    } else {
      setState(() => _cart.add(CartItem(
        productId: product.id,
        productName: product.name,
        quantity: 1,
        unitPrice: product.salePrice,
        costPrice: product.costPrice,
      });
    }
  }

  Future<void> _completeOrder() async {
    if (!_calc.canCompleteOrder(_cart)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Don hang chua co san pham'});
      return;
    }

    final confirmed = await ConfirmDialog.show(context, title: context.l10n.confirmOrder, message: context.l10n.confirmOrderBody);
    if (!confirmed || !mounted) return;

    try {
      final database = ref.read(appDatabaseProvider);
      final repo = OrderRepository(db);
      final settings = await (await database.database).query('app_settings');
      if (settings == null) return;

      final order = await repo.completeOrder(CompleteOrderInput(
        storeId: settings.value,
        items: List.from(_cart),
        paymentStatus: _paymentStatus,
        paymentMethod: _paymentMethod,
        paidAmount: _paymentStatus == 'paid' ? _calc.calculateTotalAmount(_calc.calculateSubtotal(_cart), 0) : 0,
        source: 'manual',
      ));

      if (mounted) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Don ${order.orderCode} da tao'});
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.orderFailed});
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(_activeProductsProvider);
    final subtotal = _calc.calculateSubtotal(_cart);
    final total = _calc.calculateTotalAmount(subtotal, 0);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.manualOrder)),
      body: Column(
        children: [
          Expanded(
            child: productsAsync.when(
              data: (products) => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return Card(
                    child: InkWell(
                      onTap: () => _addToCart(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProductImage(imagePath: p.imagePath, size: 40),
                            const SizedBox(height: 4),
                            Text(p.name, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(CurrencyFormatter.format(p.salePrice), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                            if (p.isLowStock) Text('Stock: ${p.stockQuantity}', style: const TextStyle(fontSize: 11, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              error: (_, __) => Center(child: Text(context.l10n.error)),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                if (_cart.isNotEmpty) ...[
                  ..._cart.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.productName} x${item.quantity}', style: const TextStyle(fontSize: 14))),
                        Text(CurrencyFormatter.format(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                  const Divider(),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_cart.length} mon', style: const TextStyle(fontSize: 16)),
                    Text(CurrencyFormatter.format(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _paymentStatus,
                        decoration: InputDecoration(labelText: context.l10n.paymentStatus, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [
                          DropdownMenuItem(value: 'paid', child: Text(context.l10n.paid)),
                          DropdownMenuItem(value: 'unpaid', child: Text(context.l10n.unpaid)),
                        ],
                        onChanged: (v) => setState(() => _paymentStatus = v ?? 'paid'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: InputDecoration(labelText: context.l10n.paymentMethod, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [
                          DropdownMenuItem(value: 'cash', child: Text(context.l10n.cash)),
                          DropdownMenuItem(value: 'bank_transfer', child: Text(context.l10n.bankTransfer)),
                        ],
                        onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _completeOrder,
                    child: Text(context.l10n.completeOrder),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
