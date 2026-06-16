import 'package:drift/drift.dart';

class AiParseLogs extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get source => text()();
  TextColumn get inputText => text()();
  TextColumn? get parsedJson => text().nullable()();
  BoolColumn get success => boolean().withDefault(const Constant(false))();
  TextColumn? get errorMessage => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
