import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'budget_app'));

  @override
  int get schemaVersion => 1;
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant('New Category'))();
  late final TextColumn type = text()
      .withDefault(const Constant('expense'))
      .check(type.isIn(['income', 'expense', 'transfer']))();
  TextColumn get userId => text().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class MockTransaction extends Table {
  TextColumn get id => text()();
  late final Column<int> amount = integer().check(
    amount.isBiggerOrEqualValue(0),
  )();
  late final TextColumn type = text()
      .withDefault(const Constant('expense'))
      .check(type.isIn(['income', 'expense', 'transfer']))();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get userId => text().references(Users, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
