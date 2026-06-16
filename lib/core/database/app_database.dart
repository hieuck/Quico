import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/stores_table.dart';
import 'tables/products_table.dart';
import 'tables/customers_table.dart';
import 'tables/orders_table.dart';
import 'tables/order_items_table.dart';
import 'tables/inventory_movements_table.dart';
import 'tables/expenses_table.dart';
import 'tables/bank_accounts_table.dart';
import 'tables/app_settings_table.dart';
import 'tables/ai_parse_logs_table.dart';

part 'app_database.g.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

@DriftDatabase(
  tables: [
    Stores,
    Products,
    Customers,
    Orders,
    OrderItems,
    InventoryMovements,
    Expenses,
    BankAccounts,
    AppSettings,
    AiParseLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {},
      beforeOpen: (details) async {
        await customStatement('PRAGMA journal_mode=WAL');
        await customStatement('PRAGMA foreign_keys=ON');
      },
    );
  }

  Future<void> initialize() async {}
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dir.path, 'quico'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final path = p.join(dbDir.path, 'quico.db');
    return NativeDatabase(File(path));
  });
}
