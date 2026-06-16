import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../../l10n/l10n_extension.dart';

final _productProvider = FutureProvider.autoDispose.family<Product?, String>((ref, id) async {
  final db = ref.read(appDatabaseProvider);
  final repo = ProductRepository(db);
  return repo.getProductById(id);
});

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(_productProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.products),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                context.push('/products/$productId/edit');
              } else if (v == 'deactivate') {
                final confirmed = await ConfirmDialog.show(context, title: context.l10n.deactivate, message: 'San pham se an khoi POS.', confirmLabel: 'Ngung ban', destructive: true);
                if (confirmed) {
                  final db = ref.read(appDatabaseProvider);
                  await ProductRepository(db).deactivateProduct(productId);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Sua')),
              const PopupMenuItem(value: 'deactivate', child: Text('Ngung ban')),
            ],
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) return Center(child: Text(context.l10n.error));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: ProductImage(imagePath: product.imagePath, size: 120)),
              const SizedBox(height: 16),
              Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _infoRow(context.l10n.salePrice, CurrencyFormatter.format(product.salePrice)),
              _infoRow(context.l10n.costPrice, CurrencyFormatter.format(product.costPrice)),
              _infoRow(context.l10n.inventory, product.stockQuantity.toString()),
              _infoRow(context.l10n.lowStockThreshold, product.lowStockThreshold.toString()),
              if (product.sku != null) _infoRow(context.l10n.skuOptional, product.sku!),
              if (!product.isActive) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(context.l10n.deactivate, style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const LoadingState(),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: TextStyle(color: Colors.grey.shade600)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}
