// ignore_for_file: avoid_print
// flutter run <file_absolute_path>
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart

import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import 'repo.dart';

const testId = 'test_persistence_001';
const testUsername = 'persistent_user';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);

  print('=== USER REPO TEST START ===');

  // ============================================================
  // 1. EMPTY STATE
  // ============================================================

  print('\n${'=' * 80}\n1. CHECK EMPTY / CURRENT STATE\n${'=' * 80}');

  final currentUsers = await uRepo.getAll();

  print('Current user count: ${currentUsers.length}');

  if (currentUsers.isEmpty) {
    print('PASS: Database currently has no users.');
  } else {
    print('INFO: Database already contains users:');
    for (final user in currentUsers) {
      print('  $user');
    }
  }

  // ============================================================
  // 2. SINGLE RECORD CRUD
  // ============================================================

  print('\n${'=' * 80}\n2. CHECK SINGLE RECORD CRUD\n${'=' * 80}');

  const singleId = 'test_single_001';
  const singleUsername = 'single_user';

  // ------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------

  print('\n[CREATE]');
  // Nếu record đã tồn tại từ lần chạy trước thì xóa trước.
  await uRepo.deleteById(id: singleId);
  try {
    final insertResult = await uRepo.createUser(
      id: singleId,
      username: singleUsername,
    );
    print('Insert result: $insertResult');
    if (insertResult == 1) {
      print('PASS: Single record created.');
    } else {
      print(
        'FAIL: Expected insert result = 1. (Will failed if don\'t clear database before!)',
      );
    }
  } catch (e) {
    print('FAIL: Unexpected exception: $e');
  }

  // ------------------------------------------------------------
  // READ BY ID
  // ------------------------------------------------------------

  print('\n[READ BY ID]');

  final singleUser = await uRepo.getById(singleId);
  if (singleUser != null &&
      singleUser.id == singleId &&
      singleUser.username == singleUsername) {
    print('PASS: getById returned correct user.\nUser: $singleUser');
  } else {
    print('FAIL: getById returned unexpected result.\nResult: $singleUser');
  }

  // ------------------------------------------------------------
  // READ BY NAME
  // ------------------------------------------------------------

  print('\n[READ BY NAME]');
  final singleUserByName = await uRepo.getByName(singleUsername);
  if (singleUserByName != null &&
      singleUserByName.id == singleId &&
      singleUserByName.username == singleUsername) {
    print('PASS: getByName returned correct user.');
  } else {
    print(
      'FAIL: getByName returned unexpected result.\nResult: $singleUserByName',
    );
  }

  // ------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------

  print('\n[UPDATE]');
  const updatedUsername = 'single_user_updated';
  final updateResult = await uRepo.updateUser(
    id: singleId,
    username: updatedUsername,
  );
  print('Update result: $updateResult');
  final updatedUser = await uRepo.getById(singleId);
  if (updateResult == 1 &&
      updatedUser != null &&
      updatedUser.username == updatedUsername) {
    print('PASS: User updated correctly.\nUser: $updatedUser');
  } else {
    print('FAIL: User update failed.\nUser: $updatedUser');
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  print('\n[DELETE]');
  final deleteResult = await uRepo.deleteById(id: singleId);
  print('Delete result: $deleteResult');
  final deletedUser = await uRepo.getById(singleId);
  if (deleteResult == 1 && deletedUser == null) {
    print('PASS: User deleted correctly.');
  } else {
    print('FAIL: User delete failed.\nResult after delete: $deletedUser');
  }

  // ============================================================
  // 3. MULTI RECORDS
  // ============================================================

  print('\n${'=' * 80}\n3. CHECK MULTI RECORDS\n${'=' * 80}');
  const multiUsers = [
    ('test_multi_001', 'multi_alice'),
    ('test_multi_002', 'multi_bob'),
    ('test_multi_003', 'multi_charlie'),
  ];

  // Cleanup previous test data.
  for (final user in multiUsers) {
    await uRepo.deleteById(id: user.$1);
  }

  // CREATE 3 USERS
  print('\n[CREATE MULTIPLE]');
  for (final user in multiUsers) {
    await uRepo.createUser(id: user.$1, username: user.$2);
  }

  // READ ALL
  final allAfterMultiInsert = await uRepo.getAll();
  final multiFound = allAfterMultiInsert
      .where((user) => user.id.startsWith('test_multi_'))
      .toList();
  print('Multi-test user count: ${multiFound.length}');
  if (multiFound.length == 3) {
    print('PASS: 3 records created.');
  } else {
    print('FAIL: Expected 3 records.');
  }

  // UPDATE ONE RECORD
  print('\n[UPDATE ONE RECORD]');
  final updateMultiResult = await uRepo.updateUser(
    id: 'test_multi_002',
    username: 'multi_bob_updated',
  );
  final multiAlice = await uRepo.getById('test_multi_001');
  final multiBob = await uRepo.getById('test_multi_002');
  final multiCharlie = await uRepo.getById('test_multi_003');
  if (updateMultiResult == 1 &&
      multiAlice?.username == 'multi_alice' &&
      multiBob?.username == 'multi_bob_updated' &&
      multiCharlie?.username == 'multi_charlie') {
    print('PASS: Updating one record did not affect other records.');
  } else {
    print('FAIL: Multi-record update behavior is incorrect.');
  }

  // DELETE ONE RECORD
  print('\n[DELETE ONE RECORD]');
  final deleteMultiResult = await uRepo.deleteById(id: 'test_multi_002');
  final remainingAlice = await uRepo.getById('test_multi_001');
  final deletedBob = await uRepo.getById('test_multi_002');
  final remainingCharlie = await uRepo.getById('test_multi_003');
  if (deleteMultiResult == 1 &&
      remainingAlice != null &&
      deletedBob == null &&
      remainingCharlie != null) {
    print('PASS: Deleting one record did not affect other records.');
  } else {
    print('FAIL: Multi-record delete behavior is incorrect.');
  }

  // Cleanup remaining multi-test data.
  await uRepo.deleteById(id: 'test_multi_001');
  await uRepo.deleteById(id: 'test_multi_003');

  // ============================================================
  // 4. MISSING ID
  // ============================================================

  print('\n${'=' * 80}\n4. CHECK MISSING ID\n${'=' * 80}');
  const missingId = 'test_missing_999';
  final missingUser = await uRepo.getById(missingId);
  if (missingUser == null) {
    print('PASS: getById returned null for missing ID.');
  } else {
    print('FAIL: Expected null.\nResult: $missingUser');
  }

  // UPDATE MISSING ID
  final updateMissingResult = await uRepo.updateUser(
    id: missingId,
    username: 'should_not_exist',
  );
  if (updateMissingResult == 0) {
    print('PASS: update missing ID returned 0.');
  } else {
    print('FAIL: Expected update result = 0.');
  }

  // DELETE MISSING ID
  final deleteMissingResult = await uRepo.deleteById(id: missingId);
  if (deleteMissingResult == 0) {
    print('PASS: delete missing ID returned 0.');
  } else {
    print('FAIL: Expected delete result = 0.');
  }
  // ============================================================
  // 5. DUPLICATE CONSTRAINTS
  // ============================================================

  print('\n${'=' * 80}');
  print('5. CHECK DUPLICATE CONSTRAINTS');
  print('=' * 80);

  const duplicateId = 'test_duplicate_001';

  // Cleanup.
  await uRepo.deleteById(id: duplicateId);

  // First insert.

  await uRepo.createUser(id: duplicateId, username: 'duplicate_user_1');

  // Second insert with same ID.

  print('\n[DUPLICATE ID]');
  try {
    await uRepo.createUser(id: duplicateId, username: 'duplicate_user_2');
    print('FAIL: Duplicate ID was accepted.');
  } catch (e) {
    print('PASS: Duplicate ID rejected.\nException: $e');
  }
  final duplicateIdUser = await uRepo.getById(duplicateId);
  if (duplicateIdUser?.username == 'duplicate_user_1') {
    print('PASS: Original record remained unchanged.');
  } else {
    print('FAIL: Original record was modified unexpectedly.');
  }

  // Cleanup.
  await uRepo.deleteById(id: duplicateId);

  // ============================================================
  // 6. PERSISTENCE
  // ============================================================

  print('\n${'=' * 80}\n6. CHECK PERSISTENCE\n${'=' * 80}');
  final persistedUser = await uRepo.getById(testId);
  if (persistedUser == null) {
    print('Persistence data: NOT FOUND\nCreating persistence test data...');
    try {
      final result = await uRepo.createUser(id: testId, username: testUsername);
      print('Insert result: $result');
      final createdUser = await uRepo.getById(testId);
      print(
        'Created persistence data:\nUser: $createdUser\n\nIMPORTANT:\nClose the program and run this test again.\nThe second run should show:\nPersistence data: FOUND',
      );
    } catch (e) {
      print('FAIL: Unexpected exception: $e');
    }
  } else {
    print('PASS: Persistence data FOUND.\nUser: $persistedUser');
    if (persistedUser.id == testId && persistedUser.username == testUsername) {
      print('PASS: Persisted data is correct.');
    } else {
      print('FAIL: Persisted data is incorrect.');
    }
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  await db.close();
  print('\n${'=' * 80}\n=== USER REPO TEST END ===\n${'=' * 80}');
}
