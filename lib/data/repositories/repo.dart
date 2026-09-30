import 'dart:js_interop';

import 'package:drift/drift.dart';

import '../database/app_database.dart';

class UserRepo {
  final AppDatabase db;
  UserRepo({required this.db});
  // SELECT *
  Future<List<User>> getAll() => db.select(db.users).get();
  // SELECT ... WHERE ...
  Future<User?> getById(String id) =>
      (db.select(db.users)..where((u) => u.id.equals(id))).getSingleOrNull();
  Future<User?> getByName(String name) => (db.select(
    db.users,
  )..where((u) => u.username.equals(name))).getSingleOrNull();

  // INSERT
  // Future<int> create({required UsersCompanion u}) =>
  //     db.into(db.users).insert(u);
  Future<int> createUser({required String id, required String username}) => db
      .into(db.users)
      .insert(UsersCompanion.insert(id: id, username: username));

  // UPDATE
  // Future<bool> update({required User u}) => db.update(db.users).replace(u);
  Future<int> updateU({required String id, required UsersCompanion u}) {
    final ts = DateTime.now();
    if (u.createdAt.present && u.createdAt.value.isBefore(ts)) {
      return (db.update(db.users)..where((user) => user.id.equals(id))).write(
        UsersCompanion(username: u.username, modifiedAt: Value(ts)),
      );
    }
    return Future.value(-1);
  }

  Future<int> updateUser({required String id, required String username}) =>
      (db.update(db.users)..where((user) => user.id.equals(id))).write(
        UsersCompanion(
          username: Value(username),
          modifiedAt: Value(DateTime.now()),
        ),
      );

  // DELETE
  Future<int> clear() => db.delete(db.users).go();
  // Future<int> deleteU({required User u}) => db.delete(db.users).delete(u);
  Future<int> deleteById({required String id}) =>
      (db.delete(db.users)..where((u) => u.id.equals(id))).go();
}

class CategoryRepo {
  final AppDatabase db;
  CategoryRepo({required this.db});
  // SELECT *
  Future<List<Category>> getAll() => db.select(db.categories).get();
  // SELECT ... WHERE ...
  Future<Category?> getById(String id) => (db.select(
    db.categories,
  )..where((c) => c.id.equals(id))).getSingleOrNull();
  Future<Category?> getByName(String name) => (db.select(
    db.categories,
  )..where((c) => c.name.equals(name))).getSingleOrNull();
  Future<List<Category>> getByType(String type) =>
      (db.select(db.categories)..where((c) => c.type.equals(type))).get();
  Future<List<Category>> getByUserId(String id) =>
      (db.select(db.categories)..where((c) => c.userId.equals(id))).get();
  Future<List<Category>> getByUserIdAndName(String id, String name) =>
      (db.select(
        db.categories,
      )..where((c) => c.userId.equals(id) & c.name.equals(name))).get();
  Future<List<Category>> getByUserIdAndType(String id, String type) =>
      (db.select(
        db.categories,
      )..where((c) => c.userId.equals(id) & c.type.equals(type))).get();
  Future<List<Category>> getByAttribute({
    String? id,
    String? name,
    String? type,
    String? userId,
  }) async {
    final query = db.select(db.categories);
    query.where((c) {
      Expression<bool>? condition;
      condition = id != null ? c.id.equals(id) : condition;
      if (name != null) {
        condition = condition == null
            ? c.name.equals(name)
            : condition & c.name.equals(name);
      }
      if (type != null) {
        condition = condition == null
            ? c.type.equals(type)
            : condition & c.type.equals(type);
      }
      if (userId != null) {
        condition = condition == null
            ? c.userId.equals(userId)
            : condition & c.userId.equals(userId);
      }
      return condition ?? const Constant(false);
    });
    return query.get();
  }

  // INSERT
  // Future<int> create({required CategoriesCompanion u}) =>
  //     db.into(db.categories).insert(u);
  Future<int> createCategory({
    required String id,
    String? name,
    String? type,
    required String userId,
  }) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          name: name != null ? Value(name) : const Value.absent(),
          type: type != null ? Value(type) : const Value.absent(),
          userId: userId,
        ),
      );

  // UPDATE
  // Future<bool> update({required Category u}) => db.update(db.categories).replace(u);
  Future<int> updateC({required String id, required CategoriesCompanion c}) {
    final ts = DateTime.now();
    if (c.createdAt.present && c.createdAt.value.isBefore(ts)) {
      return (db.update(
        db.categories,
      )..where((catg) => catg.id.equals(id))).write(
        CategoriesCompanion(name: c.name, type: c.type, modifiedAt: Value(ts)),
      );
    }
    return Future.value(-1);
  }

  Future<int> updateCategory({required String id, String? name, String? type}) {
    final ts = DateTime.now();
    // print('UPDATE timestamp: $ts');
    // print('UPDATE microseconds: ${ts.microsecondsSinceEpoch}');
    return (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        modifiedAt: Value(ts),
      ),
    );
  }

  // DELETE
  Future<int> clear() => db.delete(db.categories).go();
  // Future<int> deleteU({required Category u}) => db.delete(db.categories).delete(u);
  Future<int> deleteById({required String id}) =>
      (db.delete(db.categories)..where((u) => u.id.equals(id))).go();
}

class TransactionRepo {
  final AppDatabase db;
  TransactionRepo({required this.db});
  // SELECT *
  Future<List<Transaction>> getAll() => db.select(db.transactions).get();
  // SELECT ... WHERE ...
  Future<Transaction?> getById(String id) => (db.select(
    db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<Transaction>> getByType(String type) =>
      (db.select(db.transactions)..where((t) => t.type.equals(type))).get();
  Future<List<Transaction>> getByCategory(String categoryId) => (db.select(
    db.transactions,
  )..where((t) => t.categoryId.equals(categoryId))).get();
  Future<List<Transaction>> getByUser(String userId) =>
      (db.select(db.transactions)..where((t) => t.userId.equals(userId))).get();
  Future<List<Transaction>> getByAmount({int? amountMin, int? amountMax}) {
    if (amountMin != null && amountMax != null) {
      return (db.select(
        db.transactions,
      )..where((t) => t.amount.isBetweenValues(amountMin, amountMax))).get();
    }
    if (amountMin == null && amountMax != null) {
      return (db.select(
        db.transactions,
      )..where((t) => t.amount.isSmallerOrEqualValue(amountMax))).get();
    }
    if (amountMin != null && amountMax == null) {
      return (db.select(
        db.transactions,
      )..where((t) => t.amount.isBiggerOrEqualValue(amountMin))).get();
    }
    return getAll();
  }

  Future<List<Transaction>> getByDate({
    required DateTime start,
    DateTime? end,
  }) {
    // TODO: datetime still need to normalize into day only
    if (end != null) {
      return (db.select(
        db.transactions,
      )..where((t) => t.date.isBetweenValues(start, end))).get();
    }
    return (db.select(
      db.transactions,
    )..where((t) => t.date.equals(start))).get();
  }

  // TODO: getByAttribute condition can be return by other getBy before
  Future<List<Transaction>> getByAttribute({
    String? id,
    int? amountMin,
    int? amountMax,
    String? type,
    DateTime? start,
    DateTime? end,
    String? categoryId,
    String? userId,
  }) {
    final query = db.select(db.transactions);
    query.where((c) {
      Expression<bool>? condition;
      condition = id != null ? c.id.equals(id) : condition;
      // if (amountMin != null || amountMax != null) {
      //   condition = condition == null
      //       ? c.name.equals(name)
      //       : condition & c.name.equals(name);
      // }
      if (type != null) {
        condition = condition == null
            ? c.type.equals(type)
            : condition & c.type.equals(type);
      }
      if (userId != null) {
        condition = condition == null
            ? c.userId.equals(userId)
            : condition & c.userId.equals(userId);
      }
      return condition ?? const Constant(false);
    });
    return query.get();
  }

  // INSERT
  Future<int> create({required TransactionsCompanion t}) =>
      db.into(db.transactions).insert(t);
  Future<int> createTransaction({
    required String id,
    required int amount,
    String? type,
    DateTime? date,
    String? categoryId,
    required String userId,
  }) async {
    if (amount < 0) {
      return Future.value(-1);
    }
    if (categoryId != null && type == null) {
      final category = await CategoryRepo(db: db).getById(categoryId);
      type = category != null ? category.type : 'expense';
    }
    type ??= 'expense';
    final ts = DateTime.now();
    date ??= ts;
    return db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: id,
            amount: amount,
            type: Value(type),
            date: Value(date),
            categoryId: Value(categoryId),
            userId: userId,
            createdAt: Value(ts),
            modifiedAt: Value(ts),
          ),
        );
  }

  // DELETE
  Future<int> clear() => db.delete(db.transactions).go();
  // Future<int> deleteU({required Transaction u}) => db.delete(db.transactions).delete(u);
  Future<int> deleteById({required String id}) =>
      (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  Future<int> deleteByUserId({required String id}) =>
      (db.delete(db.transactions)..where((t) => t.userId.equals(id))).go();
  Future<int> deleteByCategoryId({required String id}) =>
      (db.delete(db.transactions)..where((t) => t.categoryId.equals(id))).go();

  // UPDATE
  // Future<bool> update({required Category u}) => db.update(db.categories).replace(u);
  Future<bool> updateT(
    String id, {
    int? amount,
    String? type,
    DateTime? dateTime,
  }) {
    return Future.value(false);
  }
}
