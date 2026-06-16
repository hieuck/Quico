import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/home_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/store_setup_screen.dart';
import '../features/orders/presentation/screens/pos_screen.dart';
import '../features/orders/presentation/screens/order_list_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/products/presentation/product_list_screen.dart';
import '../features/products/presentation/product_form_screen.dart';
import '../features/products/presentation/product_detail_screen.dart';
import '../features/products/presentation/menu_import_screen.dart';
import '../features/customers/presentation/customer_list_screen.dart';
import '../features/customers/presentation/customer_form_screen.dart';
import '../features/customers/presentation/customer_detail_screen.dart';
import '../features/ai_order/presentation/ai_order_screen.dart';
import '../features/ai_order/presentation/ai_review_screen.dart';
import '../features/expenses/presentation/expense_list_screen.dart';
import '../features/expenses/presentation/expense_form_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/receipts/presentation/receipt_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/store_settings_screen.dart';
import '../features/settings/presentation/bank_accounts_screen.dart';
import '../features/settings/presentation/backup_screen.dart';
import '../l10n/l10n_extension.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/store-setup',
        name: 'storeSetup',
        builder: (context, state) => const StoreSetupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'orderDetail',
                builder: (context, state) => OrderDetailScreen(
                  orderId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'receipt',
                    name: 'orderReceipt',
                    builder: (context, state) => ReceiptScreen(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'productNew',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'productDetail',
                builder: (context, state) => ProductDetailScreen(
                  productId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'productEdit',
                builder: (context, state) => ProductFormScreen(
                  productId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                path: 'import-menu',
                name: 'menuImport',
                builder: (context, state) => const MenuImportScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/pos',
        name: 'pos',
        builder: (context, state) => const PosScreen(),
      ),
      GoRoute(
        path: '/ai-order',
        name: 'aiOrder',
        builder: (context, state) => const AiOrderScreen(),
        routes: [
          GoRoute(
            path: 'review',
            name: 'aiReview',
            builder: (context, state) => const AiReviewScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomerListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'customerNew',
            builder: (context, state) => const CustomerFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'customerDetail',
            builder: (context, state) => CustomerDetailScreen(
              customerId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpenseListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'expenseNew',
            builder: (context, state) => const ExpenseFormScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/inventory',
        name: 'inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/settings/store',
        name: 'storeSettings',
        builder: (context, state) => const StoreSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/bank-accounts',
        name: 'bankAccounts',
        builder: (context, state) => const BankAccountsScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        name: 'backup',
        builder: (context, state) => const BackupScreen(),
      ),
    ],
  );
});

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(context),
        onTap: (index) => _onTab(context, index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: context.l10n.home),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_outlined), activeIcon: const Icon(Icons.receipt), label: context.l10n.orders),
          BottomNavigationBarItem(icon: const Icon(Icons.inventory_2_outlined), activeIcon: const Icon(Icons.inventory_2), label: context.l10n.products),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: context.l10n.reports),
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: context.l10n.more),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewSaleSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  void _onTab(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/orders');
      case 2: context.go('/products');
      case 3: context.go('/reports');
      case 4: context.go('/more');
    }
  }

  void _showNewSaleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.newOrder, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: Text(context.l10n.manualOrder),
                subtitle: Text(context.l10n.selectProducts),
                onTap: () { Navigator.pop(ctx); context.push('/pos'); },
              ),
              ListTile(
                leading: const Icon(Icons.mic),
                title: Text(context.l10n.voiceOrder),
                subtitle: Text(context.l10n.orderByVoice),
                onTap: () { Navigator.pop(ctx); context.push('/ai-order'); },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: Text(context.l10n.textOrder),
                subtitle: Text(context.l10n.pasteOrder),
                onTap: () { Navigator.pop(ctx); context.push('/ai-order'); },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(context.l10n.screenshots),
                subtitle: Text(context.l10n.chatScreenshot),
                onTap: () { Navigator.pop(ctx); context.push('/ai-order'); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
