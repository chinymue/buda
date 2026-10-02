import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
// import 'package:drift/native.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users, Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'budget_app_v0.1.3.db',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.dart.js'),
          ),
        ),
      );
  // AppDatabase.test() : super(NativeDatabase.memory());
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(categories);
        await m.createTable(transactions);
      }
      if (from < 3) {
        // Handle migration from version 2 to 3
        await m.addColumn(transactions, transactions.createdAt);
        await m.addColumn(transactions, transactions.modifiedAt);
      }
    },
  );
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

class Transactions extends Table {
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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get modifiedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
