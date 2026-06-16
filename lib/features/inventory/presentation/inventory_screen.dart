import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../products/data/product_repository.dart';
import '../../products/domain/product.dart';
import '../../../l10n/l10n_extension.dart';

final _inventoryProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final settings = await (db.select(db.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
  if (settings == null) return [];
  return ProductRepository(db).listProducts(settings.value);
});

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_inventoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.inventory)),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(icon: Icons.inventory, title: context.l10n.noProducts, description: 'Add products to track inventory.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = products[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('Stock: ${p.stockQuantity}. Low threshold: ${p.lowStockThreshold}'),
                trailing: p.isLowStock
                    ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Text(context.l10n.lowStock, style: TextStyle(fontSize: 12, color: Colors.orange)))
                    : null,
              );
            },
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const LoadingState(),
      ),
    );
  }
}
