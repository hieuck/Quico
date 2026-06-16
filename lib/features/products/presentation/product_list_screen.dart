import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart' ;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/product_image.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';
import '../../../l10n/l10n_extension.dart';

final _productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final database = ref.read(appDatabaseProvider);
  final repo = ProductRepository(database);
  final storeId = await _getStoreId(database);
  if (storeId == null) return [];
  return repo.listProducts(storeId);
});

Future<String?> _getStoreId(AppDatabase database) async {
  final settings = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
  return settings?.value;
}

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_productListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.products)),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2,
              title: context.l10n.noProducts,
              description: 'Add your first product to start selling.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final product = products[i];
              return ListTile(
                leading: ProductImage(imagePath: product.imagePath),
                title: Text(product.name),
                subtitle: Text('${CurrencyFormatter.format(product.salePrice)} . Con ${product.stockQuantity}'),
                trailing: product.isLowStock
                    ? Text(context.l10n.lowStock, style: TextStyle(fontSize: 12, color: Colors.orange.shade700))
                    : null,
                onTap: () => context.push('/products/${product.id}'),
              );
            },
          );
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const LoadingState(message: 'Dang tai san pham...'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_product',
        onPressed: () => context.push('/products/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
