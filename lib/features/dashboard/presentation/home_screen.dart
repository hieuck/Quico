import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_db.dart' as db;
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../l10n/l10n_extension.dart';

final _activeStoreProvider = FutureProvider((ref) async {
  final database = ref.read(db.appDatabaseProvider);
  final settings = await (database.select(database.appSettings)..where((t) => t.key.equals('active_store_id'))).getSingleOrNull();
  if (settings == null) return null;
  return await (database.select(database.stores)..where((t) => t.id.equals(settings.value))).getSingleOrNull();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(_activeStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: storeAsync.when(
          data: (store) => Text(store?.name ?? context.l10n.appName),
          error: (_, __) => Text(context.l10n.appName),
          loading: () => Text(context.l10n.appName),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/more'),
          ),
        ],
      ),
      body: storeAsync.when(
        data: (store) {
          if (store == null) {
            return _buildNoStore(context);
          }
          return _buildHome(context, ref, store.name);
        },
        error: (_, __) => Center(child: Text(context.l10n.error)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildNoStore(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.store, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(context.l10n.noStore, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/store-setup'),
            child: const Text('Tao cua hang'),
          ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context, WidgetRef ref, String storeName) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('San sang ban hang', style: TextStyle(fontSize: 12, color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doanh thu hom nay', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('0d', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.ordersToday, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const Text('0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.grossProfit, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const Text('0d', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Tao nhanh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildQuickActionGrid(context),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text('San pham sap het hang', style: TextStyle(color: Colors.amber.shade700)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('No products yet.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Don gan day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const AppCard(
          child: Text('No orders yet.', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _actionButton(context, Icons.add_shopping_cart, context.l10n.manualOrder, () => context.push('/pos'))),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(context, Icons.mic, 'Noi don', () => context.push('/ai-order'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _actionButton(context, Icons.text_fields, 'Nhap text', () => context.push('/ai-order'))),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(context, Icons.image, 'Anh tin nhan', () => context.push('/ai-order'))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
