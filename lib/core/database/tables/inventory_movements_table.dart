

class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get type => text()();
  IntColumn get quantityDelta => integer()();
  IntColumn get quantityAfter => integer()();
  TextColumn? get referenceType => text().nullable()();
  TextColumn? get referenceId => text().nullable()();
  TextColumn? get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
