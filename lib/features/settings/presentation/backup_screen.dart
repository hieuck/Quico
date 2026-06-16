import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../../core/database/app_database.dart';
import '../../../core/local_storage/backup_file_service.dart';
import '../../../l10n/l10n_extension.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _loading = false;

  Future<void> _exportBackup() async {
    setState(() => _loading = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final stores = await db.select(db.stores).get();
      final products = await db.select(db.products).get();
      final customers = await db.select(db.customers).get();
      final orders = await db.select(db.orders).get();
      final items = await db.select(db.orderItems).get();
      final movements = await db.select(db.inventoryMovements).get();
      final expenses = await db.select(db.expenses).get();
      final accounts = await db.select(db.bankAccounts).get();

      final backup = {
        'app': context.l10n.appName,
        'version': 1,
        'exported_at': DateTime.now().millisecondsSinceEpoch,
        'stores': stores.map((r) => r.toJson()).toList(),
        'products': products.map((r) => r.toJson()).toList(),
        'customers': customers.map((r) => r.toJson()).toList(),
        'orders': orders.map((r) => r.toJson()).toList(),
        'order_items': items.map((r) => r.toJson()).toList(),
        'inventory_movements': movements.map((r) => r.toJson()).toList(),
        'expenses': expenses.map((r) => r.toJson()).toList(),
        'bank_accounts': accounts.map((r) => r.toJson()).toList(),
      };

      final service = BackupFileService();
      final path = await service.saveBackupFile('quico_backup.json', backup.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup exported: $path')),
        );
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot export backup')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sao luu & phuc hoi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xuat backup du lieu cua ban de dam bao an toan.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _exportBackup,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.backup),
                label: Text(context.l10n.exportBackup),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import du lieu tu file backup.'))),
                icon: const Icon(Icons.restore),
                label: Text(context.l10n.importBackup),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
