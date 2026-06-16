import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

export 'tables/stores_table.dart';
export 'tables/products_table.dart';
export 'tables/customers_table.dart';
export 'tables/orders_table.dart';
export 'tables/order_items_table.dart';
export 'tables/inventory_movements_table.dart';
export 'tables/expenses_table.dart';
export 'tables/bank_accounts_table.dart';
export 'tables/app_settings_table.dart';
export 'tables/ai_parse_logs_table.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  List<TableInfo<Table, dynamic>> get allTables => [
    storesTable,
    productsTable,
    customersTable,
    ordersTable,
    orderItemsTable,
    inventoryMovementsTable,
    expensesTable,
    bankAccountsTable,
    appSettingsTable,
    aiParseLogsTable,
  ];

  final storesTable = Stores();
  final productsTable = Products();
  final customersTable = Customers();
  final ordersTable = Orders();
  final orderItemsTable = OrderItems();
  final inventoryMovementsTable = InventoryMovements();
  final expensesTable = Expenses();
  final bankAccountsTable = BankAccounts();
  final appSettingsTable = AppSettings();
  final aiParseLogsTable = AiParseLogs();

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        for (final table in allTables) {
          await m.createTable(table);
        }
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
