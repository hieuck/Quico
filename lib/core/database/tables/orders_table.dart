

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn? get customerId => text().nullable()();
  TextColumn get orderCode => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get paymentStatus => text().withDefault(const Constant('unpaid'))();
  TextColumn? get paymentMethod => text().nullable()();
  IntColumn get subtotal => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  IntColumn get costAmount => integer().withDefault(const Constant(0))();
  IntColumn get grossProfit => integer().withDefault(const Constant(0))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  TextColumn? get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn? get originalInput => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn? get completedAt => integer().nullable()();
  IntColumn? get cancelledAt => integer().nullable()();
  TextColumn? get syncStatus => text().nullable()();
  IntColumn? get lastSyncedAt => integer().nullable()();
  TextColumn? get remoteId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
