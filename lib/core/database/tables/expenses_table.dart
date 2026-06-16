

class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  TextColumn? get note => text().nullable()();
  IntColumn get spentAt => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn? get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
