import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class AppDatabase {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dir.path, 'quico'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final path = p.join(dbDir.path, 'quico.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async => _createTables(db),
    );
    return _db!;
  }

  Future<void> initialize() async => database;

  // Table getters for Drift-compatible syntax
  TableInfo get appSettings => appSettingsTable;
  TableInfo get stores => storesTable;
  TableInfo get products => productsTable;
  TableInfo get customers => customersTable;
  TableInfo get orders => ordersTable;
  TableInfo get orderItems => orderItemsTable;
  TableInfo get inventoryMovements => inventoryMovementsTable;
  TableInfo get expenses => expensesTable;
  TableInfo get bankAccounts => bankAccountsTable;
  TableInfo get aiParseLogs => aiParseLogsTable;

  // Compatibility layer for Drift-style calls
  QueryBuilder select(TableInfo table) => QueryBuilder._(table, this);
  InsertBuilder into(TableInfo table) => InsertBuilder._(table, this);
  UpdateBuilder update(TableInfo table) => UpdateBuilder._(table, this);

  Future<void> _createTables(Database db) async {
    await db.execute('PRAGMA journal_mode=WAL');
    await db.execute('PRAGMA foreign_keys=ON');
    await db.execute('''CREATE TABLE IF NOT EXISTS stores (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, business_type TEXT,
      currency TEXT NOT NULL DEFAULT 'VND', phone TEXT, address TEXT,
      logo_path TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, name TEXT NOT NULL,
      normalized_name TEXT NOT NULL, sku TEXT, barcode TEXT,
      cost_price INTEGER NOT NULL DEFAULT 0, sale_price INTEGER NOT NULL DEFAULT 0,
      stock_quantity INTEGER NOT NULL DEFAULT 0, low_stock_threshold INTEGER NOT NULL DEFAULT 5,
      image_path TEXT, is_active INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS customers (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, name TEXT NOT NULL,
      phone TEXT, normalized_phone TEXT, note TEXT,
      total_spent INTEGER NOT NULL DEFAULT 0, total_orders INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, customer_id TEXT,
      order_code TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'draft',
      payment_status TEXT NOT NULL DEFAULT 'unpaid', payment_method TEXT,
      subtotal INTEGER NOT NULL DEFAULT 0, discount_amount INTEGER NOT NULL DEFAULT 0,
      total_amount INTEGER NOT NULL DEFAULT 0, cost_amount INTEGER NOT NULL DEFAULT 0,
      gross_profit INTEGER NOT NULL DEFAULT 0, paid_amount INTEGER NOT NULL DEFAULT 0,
      note TEXT, source TEXT NOT NULL DEFAULT 'manual', original_input TEXT,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
      completed_at INTEGER, cancelled_at INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS order_items (
      id TEXT PRIMARY KEY, order_id TEXT NOT NULL, product_id TEXT,
      product_name TEXT NOT NULL, quantity INTEGER NOT NULL DEFAULT 1,
      unit_price INTEGER NOT NULL DEFAULT 0, cost_price INTEGER NOT NULL DEFAULT 0,
      discount_amount INTEGER NOT NULL DEFAULT 0, line_total INTEGER NOT NULL DEFAULT 0,
      line_profit INTEGER NOT NULL DEFAULT 0, note TEXT,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS inventory_movements (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, product_id TEXT NOT NULL,
      type TEXT NOT NULL, quantity_delta INTEGER NOT NULL, quantity_after INTEGER NOT NULL,
      reference_type TEXT, reference_id TEXT, note TEXT, created_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS expenses (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, category TEXT NOT NULL,
      amount INTEGER NOT NULL, note TEXT, spent_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, deleted_at INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS bank_accounts (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, bank_code TEXT NOT NULL,
      bank_name TEXT NOT NULL, account_number TEXT NOT NULL, account_name TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0, created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL, deleted_at INTEGER)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS ai_parse_logs (
      id TEXT PRIMARY KEY, store_id TEXT NOT NULL, source TEXT NOT NULL,
      input_text TEXT NOT NULL, parsed_json TEXT, success INTEGER NOT NULL DEFAULT 0,
      error_message TEXT, created_at INTEGER NOT NULL)''');
  }
}

// Table metadata
class TableInfo {
  final String name;
  const TableInfo(this.name);
}

// Query builder that mimics Drift's select API
class QueryBuilder {
  final TableInfo _table;
  final AppDatabase _db;
  final List<String> _conditions = [];
  final List<dynamic> _args = [];
  String? _orderBy;

  QueryBuilder._(this._table, this._db);

  QueryBuilder where(void Function(dynamic t) callback) {
    final wb = WhereBuilder._();
    callback(wb);
    for (final clause in wb._clauses) {
      _conditions.add(clause.key);
      if (clause.value is List) {
        _args.addAll(clause.value as List);
      } else if (clause.value != null) {
        _args.add(clause.value);
      }
    }
    return this;
  }

  QueryBuilder orderBy(dynamic callback) => this;

  Future<List<Map<String, dynamic>>> get() async {
    final db = await _db.database;
    var query = 'SELECT * FROM ${_table.name}';
    if (_conditions.isNotEmpty) {
      query += ' WHERE ${_conditions.join(" AND ")}';
    }
    if (_orderBy != null) query += ' ORDER BY $_orderBy';
    return await db.rawQuery(query, _args);
  }

  Future<Row?> getSingleOrNull() async {
    final results = await get();
    return results.isNotEmpty ? Row(results.first) : null;
  }
}

class Row {
  final Map<String, dynamic> _data;
  Row(this._data);
  dynamic noSuchMethod(Invocation inv) {
    final name = _symbolName(inv.memberName);
    if (_data.containsKey(name)) return _data[name];
    if (_data.containsKey(_toSnake(name))) return _data[_toSnake(name)];
    return super.noSuchMethod(inv);
  }
  static String _symbolName(Symbol s) => s.toString().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  static String _toSnake(String camel) => camel.replaceAllMapped(
    RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}');
}
}

class WhereBuilder {
  final List<MapEntry<String, dynamic>> _clauses = [];
  WhereBuilder._();

  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName is Symbol) {
      final name = _symbolName(invocation.memberName);
      return ColumnRef(name, this);
    }
    return super.noSuchMethod(invocation);
  }

  static String _symbolName(Symbol s) {
    final str = s.toString();
    return str.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  }
}

class ColumnRef {
  final String _name;
  final WhereBuilder _wb;
  ColumnRef(this._name, this._wb);
  
  void equals(dynamic value) {
    _wb._clauses.add(MapEntry('$_name = ?', value));
  }
  void isNull() {
    _wb._clauses.add(MapEntry('$_name IS NULL', null));
  }
  void isNotIn(List<dynamic> values) {
    if (values.isEmpty) return;
    final placeholders = values.map((_) => '?').join(',');
    _wb._clauses.add(MapEntry('$_name NOT IN ($placeholders)', values));
  }
  void isBetweenValues(dynamic a, dynamic b) {
    _wb._clauses.add(MapEntry('$_name >= ? AND $_name <= ?', [a, b]));
  }
}

class InsertBuilder {
  final TableInfo _table;
  final AppDatabase _db;
  InsertBuilder._(this._table, this._db);

  Future<int> insert(Map<String, dynamic> values) async {
    final db = await _db.database;
    return await db.insert(_table.name, values);
  }
}

class UpdateBuilder {
  final TableInfo _table;
  final AppDatabase _db;
  final List<String> _conditions = [];
  final List<dynamic> _args = [];

  UpdateBuilder._(this._table, this._db);

  UpdateBuilder where(void Function(dynamic t) callback) {
    final wb = WhereBuilder._();
    callback(wb);
    for (final clause in wb._clauses) {
      _conditions.add(clause.key);
      if (clause.value is List) {
        _args.addAll(clause.value as List);
      } else if (clause.value != null) {
        _args.add(clause.value);
      }
    }
    return this;
  }

  Future<int> write(Map<String, dynamic> values) async {
    final db = await _db.database;
    String? where;
    if (_conditions.isNotEmpty) {
      where = _conditions.join(' AND ');
    }
    return await db.update(_table.name, values, where: where, whereArgs: _args.isNotEmpty ? _args : null);
  }
}

// Table instance definitions used by screens
final appSettingsTable = TableInfo('app_settings');
final storesTable = TableInfo('stores');
final productsTable = TableInfo('products');
final customersTable = TableInfo('customers');
final ordersTable = TableInfo('orders');
final orderItemsTable = TableInfo('order_items');
final inventoryMovementsTable = TableInfo('inventory_movements');
final expensesTable = TableInfo('expenses');
final bankAccountsTable = TableInfo('bank_accounts');
final aiParseLogsTable = TableInfo('ai_parse_logs');
