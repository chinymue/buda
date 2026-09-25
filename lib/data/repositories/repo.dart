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
