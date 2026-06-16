import 'package:drift/drift.dart';

class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn? get businessType => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('VND'))();
  TextColumn? get phone => text().nullable()();
  TextColumn? get address => text().nullable()();
  TextColumn? get logoPath => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
