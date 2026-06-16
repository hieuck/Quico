import 'package:drift/drift.dart';

class BankAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get bankCode => text()();
  TextColumn get bankName => text()();
  TextColumn get accountNumber => text()();
  TextColumn get accountName => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn? get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
