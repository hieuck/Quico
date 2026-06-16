

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get name => text()();
  TextColumn? get phone => text().nullable()();
  TextColumn? get normalizedPhone => text().nullable()();
  TextColumn? get note => text().nullable()();
  IntColumn get totalSpent => integer().withDefault(const Constant(0))();
  IntColumn get totalOrders => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn? get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
