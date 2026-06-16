import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  TextColumn? get sku => text().nullable()();
  TextColumn? get barcode => text().nullable()();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
  IntColumn get salePrice => integer().withDefault(const Constant(0))();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  TextColumn? get imagePath => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn? get deletedAt => integer().nullable()();
  TextColumn? get syncStatus => text().nullable()();
  IntColumn? get lastSyncedAt => integer().nullable()();
  TextColumn? get remoteId => text().nullable()();
  TextColumn? get deviceId => text().nullable()();
  IntColumn? get version => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE(normalized_name, store_id)',
  ];
}
