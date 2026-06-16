

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn? get productId => text().nullable()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPrice => integer().withDefault(const Constant(0))();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get lineTotal => integer().withDefault(const Constant(0))();
  IntColumn get lineProfit => integer().withDefault(const Constant(0))();
  TextColumn? get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
