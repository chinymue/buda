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

  Future<int> updateCategory({
    required String id,
    String? name,
    String? type,
  }) => (db.update(db.categories)..where((c) => c.id.equals(id))).write(
    CategoriesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      modifiedAt: Value(DateTime.now()),
    ),
  );

  // DELETE
  Future<int> clear() => db.delete(db.categories).go();
  // Future<int> deleteU({required Category u}) => db.delete(db.categories).delete(u);
  Future<int> deleteById({required String id}) =>
      (db.delete(db.categories)..where((u) => u.id.equals(id))).go();
}
