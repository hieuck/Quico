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
