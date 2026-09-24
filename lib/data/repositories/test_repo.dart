// ignore_for_file: avoid_print
// flutter run <file_absolute_path>
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart

import 'package:flutter/widgets.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'repo.dart';

const testId = 'test_persistence_001';
const testUsername = 'persistent_user';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);

  print('=== TEST START ===');

  // ============================================================
  // CHECK EXISTING DATA / PERSISTENCE
  // ============================================================

  print('Check persistence ${'-' * 80}');

  final persistedUser = await uRepo.getById(testId);

  if (persistedUser == null) {
    print('Persistence data: NOT FOUND');
    print('No previous test data found.');
    print('Creating persistence test data...');

    try {
      await uRepo.createUser(id: testId, username: testUsername);

      final createdUser = await uRepo.getById(testId);

      print('Created persistence data:');
      print('User: $createdUser');
    } catch (e) {
      print('Unexpected error/exception: $e');
    }
  } else {
    print('Persistence data: FOUND');
    print('User: $persistedUser');
  }

  // ============================================================
  // CHECK INSERT
  // ============================================================

  print('Check insert ${'-' * 100}');

  final before = await uRepo.getAll();

  print('Data before insert:');
  for (final user in before) {
    print('Users: $user');
  }

  try {
    final tmp = DateTime.now().toIso8601String();

    await uRepo.createUser(id: tmp, username: 'user_no_$tmp');
  } catch (e) {
    print('Unexpected error/exception: $e');
  }

  final after = await uRepo.getAll();

  print('Data after insert:');
  for (final user in after) {
    print('Users: $user');
  }

  // ============================================================
  // CHECK GET
  // ============================================================

  print('Check get ${'-' * 100}');

  final resGetById = await uRepo.getById(testId);
  final resGetByName = await uRepo.getByName(testUsername);

  print('Result get by ID: $resGetById');
  print('Result get by name: $resGetByName');

  // ============================================================
  // CHECK UPDATE
  // ============================================================

  print('Check update ${'-' * 100}');

  final beforeUpdate = await uRepo.getAll();

  print('Data before update:');
  for (final user in beforeUpdate) {
    print('Users: $user');
  }

  final iUpdate = await uRepo.updateU(
    id: 'u1',
    u: UsersCompanion(
      id: Value('10'),
      username: Value('david'),
      createdAt: Value(DateTime.now()),
      modifiedAt: Value(DateTime.now()),
    ),
  );

  final iUpdateUser = await uRepo.updateUser(
    id: testId,
    username: 'persistent_user_updated',
  );

  print('Result updateU: $iUpdate');
  print('Result updateUser: $iUpdateUser');

  final afterUpdate = await uRepo.getAll();

  print('Data after update:');
  for (final user in afterUpdate) {
    print('Users: $user');
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  await db.close();

  print('=== TEST END ===');
}
