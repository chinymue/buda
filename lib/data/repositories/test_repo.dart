// ignore_for_file: avoid_print
// flutter run <file_absolute_path>
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import 'repo.dart';

// User repo data test
const testId = 'test_persistence_001';
const testUsername = 'persistent_user';
const singleId = 'test_single_001';
const singleUsername = 'single_user';
const multiUsers = [
  ('test_multi_001', 'multi_alice'),
  ('test_multi_002', 'multi_bob'),
  ('test_multi_003', 'multi_charlie'),
];
const duplicateId = 'test_duplicate_001';
// Category repo data test
const categoryTestUserId = 'test_category_user_001';
const otherCategoryUserId = 'test_category_other_user_001';
const categoryTestUsername = 'category_test_user';
const categorySingleId = 'test_category_single_001';
const categorySingleName = 'Food';
const categorySingleType = 'expense';
const updatedCategoryName = 'Food Updated';
const updatedCategoryType = 'income';
const multiCategories = [
  ('test_category_multi_001', 'Food', 'expense', categoryTestUserId),
  ('test_category_multi_002', 'Salary', 'income', categoryTestUserId),
  ('test_category_multi_003', 'Shopping', 'expense', categoryTestUserId),
  ('test_category_multi_004', 'Travel', 'expense', otherCategoryUserId),
];
const modifiedTestId = 'test_category_modified_001';
const missingCategoryId = 'test_category_missing_999';
const duplicateCategoryId = 'test_category_duplicate_001';
const categoryPersistenceId = 'test_category_persistence_001';
const categoryPersistenceName = 'Persistent Category';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
  // ============================================================
  // ============================================================
  // A. USER REPO TEST
  // ============================================================
  // ============================================================
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
  // ------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------
  print('\n[CREATE]');
  final result = await uRepo.createUser(id: singleId, username: singleUsername);

  print('Insert result: $result');

  final createdUser = await uRepo.getById(singleId);

  final usersAfterInsert = await uRepo.getAll();

  if (result > 0 &&
      createdUser != null &&
      createdUser.id == singleId &&
      createdUser.username == singleUsername &&
      usersAfterInsert.length == currentUsers.length + 1) {
    print('PASS: Category created.');
    print('Created category: $createdUser');
  } else {
    print(
      'FAIL: Category creation failed.\n'
      'Insert result: $result\n'
      'Created category: $createdUser\n'
      'Category count before: ${currentUsers.length}\n'
      'Category count after: ${usersAfterInsert.length}',
    );
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
  for (final user in multiUsers) {
    await uRepo.deleteById(id: user.$1);
  }
  print('\n[CREATE MULTIPLE]');
  for (final user in multiUsers) {
    await uRepo.createUser(id: user.$1, username: user.$2);
  }
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
  final updateMissingResult = await uRepo.updateUser(
    id: missingId,
    username: 'should_not_exist',
  );
  if (updateMissingResult == 0) {
    print('PASS: update missing ID returned 0.');
  } else {
    print('FAIL: Expected update result = 0.');
  }
  final deleteMissingResult = await uRepo.deleteById(id: missingId);
  if (deleteMissingResult == 0) {
    print('PASS: delete missing ID returned 0.');
  } else {
    print('FAIL: Expected delete result = 0.');
  }
  // ============================================================
  // 5. DUPLICATE CONSTRAINTS
  // ============================================================
  print('\n${'=' * 80}\n5. CHECK DUPLICATE CONSTRAINTS\n${'=' * 80}');
  await uRepo.deleteById(id: duplicateId);
  await uRepo.createUser(id: duplicateId, username: 'duplicate_user_1');
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
  print('\n${'=' * 80}\n=== USER REPO TEST END ===\n${'=' * 80}');
  // ============================================================
  // ============================================================
  // CATEGORY REPO TEST
  // ============================================================
  // ============================================================
  print('\n${'=' * 80}\n=== CATEGORY REPO TEST START ===\n${'=' * 80}');
  // ------------------------------------------------------------
  // CATEGORY TEST USER
  // ------------------------------------------------------------
  // Category yêu cầu userId.
  // Tạo một user cố định để dùng cho toàn bộ Category test.
  print('\n${'=' * 80}\nCATEGORY TEST USER\n${'=' * 80}');
  final existingCategoryTestUser = await uRepo.getById(categoryTestUserId);
  if (existingCategoryTestUser == null) {
    await uRepo.createUser(
      id: categoryTestUserId,
      username: categoryTestUsername,
    );
    print('Created category test user.');
  } else {
    print('Category test user already exists.');
  }
  // ============================================================
  // 1. CATEGORY SINGLE RECORD CRUD
  // ============================================================
  print('\n${'=' * 80}\n1. CATEGORY SINGLE RECORD CRUD\n${'=' * 80}');
  print('\n[CLEANUP]');
  await cRepo.deleteById(id: categorySingleId);
  print('Previous test category removed if existed.');
  final currentCategories = await cRepo.getAll();
  print('Current categories count: ${currentCategories.length}');
  if (currentCategories.isEmpty) {
    print('PASS: Database currently has no categories.');
  } else {
    print('INFO: Database already contains categories:');
    for (final c in currentCategories) {
      print('  $c');
    }
  }
  print('\n[CREATE]');
  final result1 = await cRepo.createCategory(
    id: categorySingleId,
    name: categorySingleName,
    type: categorySingleType,
    userId: categoryTestUserId,
  );

  print('Insert result: $result1');

  final createdCategory = await cRepo.getById(categorySingleId);

  final categoriesAfterInsert = await cRepo.getAll();

  if (result1 > 0 &&
      createdCategory != null &&
      createdCategory.id == categorySingleId &&
      createdCategory.name == categorySingleName &&
      createdCategory.type == categorySingleType &&
      createdCategory.userId == categoryTestUserId &&
      categoriesAfterInsert.length == currentCategories.length + 1) {
    print('PASS: Category created.');
    print('Created category: $createdCategory');
  } else {
    print(
      'FAIL: Category creation failed.\n'
      'Insert result: $result1\n'
      'Created category: $createdCategory\n'
      'Category count before: ${currentCategories.length}\n'
      'Category count after: ${categoriesAfterInsert.length}',
    );
  }
  print('\n[READ BY ID]');
  final categoryById = await cRepo.getById(categorySingleId);
  if (categoryById != null &&
      categoryById.id == categorySingleId &&
      categoryById.name == categorySingleName &&
      categoryById.type == categorySingleType &&
      categoryById.userId == categoryTestUserId) {
    print(
      'PASS: getById returned correct category.\n'
      'Category: $categoryById',
    );
  } else {
    print(
      'FAIL: getById returned unexpected result.\n'
      'Result: $categoryById',
    );
  }
  print('\n[READ BY NAME]');
  final categoryByName = await cRepo.getByName(categorySingleName);
  if (categoryByName != null &&
      categoryByName.id == categorySingleId &&
      categoryByName.name == categorySingleName) {
    print('PASS: getByName returned correct category.');
  } else {
    print(
      'FAIL: getByName returned unexpected result.\n'
      'Result: $categoryByName',
    );
  }
  print('\n[READ BY TYPE]');
  final expenseCategories = await cRepo.getByType(categorySingleType);
  final foundByType = expenseCategories.any(
    (category) => category.id == categorySingleId,
  );
  if (foundByType) {
    print('PASS: getByType returned the expected category.');
  } else {
    print('FAIL: getByType did not return the expected category');
  }
  print('\n[READ BY USER ID]');
  final userCategories = await cRepo.getByUserId(categoryTestUserId);
  final foundByUserId = userCategories.any(
    (category) => category.id == categorySingleId,
  );
  if (foundByUserId) {
    print('PASS: getByUserId returned the expected category.');
  } else {
    print('FAIL: getByUserId did not return the expected category.');
  }
  print('\n[READ BY USER ID + NAME]');
  final userNameCategories = await cRepo.getByUserIdAndName(
    categoryTestUserId,
    categorySingleName,
  );
  if (userNameCategories.length == 1 &&
      userNameCategories.first.id == categorySingleId) {
    print('PASS: getByUserIdAndName returned correct category.');
  } else {
    print(
      'FAIL: getByUserIdAndName returned unexpected result.\n'
      'Result: $userNameCategories',
    );
  }
  print('\n[READ BY USER ID + TYPE]');
  final userTypeCategories = await cRepo.getByUserIdAndType(
    categoryTestUserId,
    categorySingleType,
  );
  final foundByUserAndType = userTypeCategories.any(
    (category) => category.id == categorySingleId,
  );
  if (foundByUserAndType) {
    print('PASS: getByUserIdAndType returned correct category.');
  } else {
    print('FAIL: getByUserIdAndType did not return expected category.');
  }
  print('\n[UPDATE]');
  final updateCategoryResult = await cRepo.updateCategory(
    id: categorySingleId,
    name: updatedCategoryName,
    type: updatedCategoryType,
  );
  print('Update result: $updateCategoryResult');
  final updatedCategory = await cRepo.getById(categorySingleId);
  if (updateResult == 1 &&
      updatedCategory != null &&
      updatedCategory.name == updatedCategoryName &&
      updatedCategory.type == updatedCategoryType &&
      updatedCategory.userId == categoryTestUserId) {
    print(
      'PASS: Category updated correctly.\n'
      'Category: $updatedCategory',
    );
  } else {
    print(
      'FAIL: Category update failed.\n'
      'Category: $updatedCategory',
    );
  }
  print('\n[DELETE]');
  final deleteCategoryResult = await cRepo.deleteById(id: categorySingleId);
  print('Delete result: $deleteCategoryResult');
  final deletedCategory = await cRepo.getById(categorySingleId);
  if (deleteResult == 1 && deletedCategory == null) {
    print('PASS: Category deleted correctly.');
  } else {
    print(
      'FAIL: Category delete failed.\n'
      'Result after delete: $deletedCategory',
    );
  }
  // ============================================================
  // 2. CATEGORY MULTI RECORDS + FILTER
  // ============================================================

  print('\n${'=' * 80}\n2. CATEGORY MULTI RECORDS + FILTER\n${'=' * 80}');
  // CREATE TEST USER FOR OTHER USER CATEGORY
  final otherUser = await uRepo.getById(otherCategoryUserId);
  if (otherUser == null) {
    await uRepo.createUser(
      id: otherCategoryUserId,
      username: 'category_other_user',
    );
    print('Created other category test user.');
  }
  for (final category in multiCategories) {
    await cRepo.deleteById(id: category.$1);
  }
  print('\n[CREATE MULTIPLE]');
  for (final category in multiCategories) {
    final result = await cRepo.createCategory(
      id: category.$1,
      name: category.$2,
      type: category.$3,
      userId: category.$4,
    );
    print('${category.$1}: insert result = $result');
  }
  print('\n[GET ALL]');
  final allCategories = await cRepo.getAll();
  final multiCategoriesFound = allCategories
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  print('Multi-test category count: ${multiCategoriesFound.length}');
  if (multiCategoriesFound.length == 4) {
    print('PASS: 4 categories created.');
  } else {
    print('FAIL: Expected 4 categories.');
    print('Result: $multiCategoriesFound');
  }
  print('\n[FILTER BY TYPE]');
  final expenseResult = await cRepo.getByType('expense');
  final expenseMultiFound = expenseResult
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  if (expenseMultiFound.length == 3) {
    print('PASS: getByType returned 3 expense categories.');
  } else {
    print(
      'FAIL: Expected 3 expense categories, got ${expenseMultiFound.length}.',
    );
  }
  print('\n[FILTER BY USER ID]');
  final userResult = await cRepo.getByUserId(categoryTestUserId);
  final userMultiFound = userResult
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  if (userMultiFound.length == 3) {
    print('PASS: getByUserId returned 3 categories');
  } else {
    print(
      'FAIL: Expected 3 categories for test user, got ${userMultiFound.length}.',
    );
  }
  print('\n[FILTER BY USER ID + NAME]');
  final userNameResult = await cRepo.getByUserIdAndName(
    categoryTestUserId,
    'Food',
  );
  if (userNameResult.length == 1 &&
      userNameResult.first.id == 'test_category_multi_001') {
    print('PASS: getByUserIdAndName returned correct result.');
  } else {
    print(
      'FAIL: getByUserIdAndName returned unexpected result.\n'
      'Result: $userNameResult',
    );
  }
  print('\n[FILTER BY USER ID + TYPE]');
  final userTypeResult = await cRepo.getByUserIdAndType(
    categoryTestUserId,
    'expense',
  );
  final expectedUserTypeIds = {
    'test_category_multi_001',
    'test_category_multi_003',
  };
  final actualUserTypeIds = userTypeResult
      .map((c) => c.id)
      .where((id) => id.startsWith('test_category_multi_'))
      .toSet();
  if (setEquals(actualUserTypeIds, expectedUserTypeIds)) {
    print('PASS: getByUserIdAndType returned correct results.');
  } else {
    print(
      'FAIL: getByUserIdAndType returned unexpected results.\n'
      'Result: $actualUserTypeIds',
    );
  }
  print('\n${'=' * 80}\nCATEGORY getByAttribute\n${'=' * 80}');
  print('\n[ATTRIBUTE: ID]');
  final attrById = await cRepo.getByAttribute(id: 'test_category_multi_001');
  if (attrById.length == 1 && attrById.first.id == 'test_category_multi_001') {
    print('PASS: getByAttribute(id) works.');
  } else {
    print(
      'FAIL: getByAttribute(id) returned unexpected result.\n'
      'Result: $attrById',
    );
  }
  print('\n[ATTRIBUTE: NAME]');
  final attrByName = await cRepo.getByAttribute(name: 'Food');
  if (attrByName.length == 1 && attrByName.first.name == 'Food') {
    print('PASS: getByAttribute(name) works.');
  } else {
    print(
      'FAIL: getByAttribute(name) returned unexpected result.\n'
      'Result: $attrByName',
    );
  }
  print('\n[ATTRIBUTE: TYPE]');
  final attrByType = await cRepo.getByAttribute(type: 'expense');
  final attrExpenseIds = attrByType
      .where((c) => c.id.startsWith('test_category_multi_'))
      .map((c) => c.id)
      .toSet();
  final expectedExpenseIds = {
    'test_category_multi_001',
    'test_category_multi_003',
    'test_category_multi_004',
  };
  if (setEquals(attrExpenseIds, expectedExpenseIds)) {
    print('PASS: getByAttribute(type) works.');
  } else {
    print(
      'FAIL: getByAttribute(type) returned unexpected result.\n'
      'Result: $attrExpenseIds',
    );
  }
  print('\n[ATTRIBUTE: USER ID]');
  final attrByUserId = await cRepo.getByAttribute(userId: categoryTestUserId);
  final attrUserIds = attrByUserId
      .where((category) => category.id.startsWith('test_category_multi_'))
      .map((category) => category.id)
      .toSet();
  final expectedUserIds = {
    'test_category_multi_001',
    'test_category_multi_002',
    'test_category_multi_003',
  };
  if (setEquals(attrUserIds, expectedUserIds)) {
    print('PASS: getByAttribute(userId) works.');
  } else {
    print(
      'FAIL: getByAttribute(userId) returned unexpected result.\n'
      'Result: $attrUserIds',
    );
  }
  print('\n[ATTRIBUTE: USER ID + TYPE]');
  final attrByUserAndType = await cRepo.getByAttribute(
    userId: categoryTestUserId,
    type: 'expense',
  );
  final attrUserTypeIds = attrByUserAndType
      .where((category) => category.id.startsWith('test_category_multi_'))
      .map((category) => category.id)
      .toSet();
  if (setEquals(attrUserTypeIds, expectedUserTypeIds)) {
    print('PASS: getByAttribute(userId + type) works.');
  } else {
    print(
      'FAIL: getByAttribute(userId + type) returned '
      'unexpected result.\nResult: $attrUserTypeIds',
    );
  }
  print('\n[ATTRIBUTE: USER ID + NAME + TYPE]');
  final attrAll = await cRepo.getByAttribute(
    userId: categoryTestUserId,
    name: 'Food',
    type: 'expense',
  );
  if (attrAll.length == 1 && attrAll.first.id == 'test_category_multi_001') {
    print('PASS: getByAttribute(all attributes) works.');
  } else {
    print(
      'FAIL: getByAttribute(all attributes) returned '
      'unexpected result.\nResult: $attrAll',
    );
  }
  print('\n[ATTRIBUTE: NO ATTRIBUTE]');
  final attrNone = await cRepo.getByAttribute();
  final attrNoneTestCategories = attrNone
      .where((category) => category.id.startsWith('test_category_multi_'))
      .toList();
  if (attrNoneTestCategories.isEmpty) {
    print('PASS: getByAttribute() returned empty result.');
  } else {
    print(
      'FAIL: getByAttribute() should return empty result '
      'when no attribute is provided.',
    );
  }
  // ============================================================
  // 3. UPDATE + modifiedAt
  // ============================================================
  print('\n${'=' * 80}\n3. CATEGORY UPDATE + modifiedAt\n${'=' * 80}');
  await cRepo.deleteById(id: modifiedTestId);
  await cRepo.createCategory(
    id: modifiedTestId,
    name: 'Modified Test',
    type: 'expense',
    userId: categoryTestUserId,
  );
  final beforeUpdate = await cRepo.getById(modifiedTestId);
  print('Before update: $beforeUpdate');
  print(
    'BEFORE microseconds: '
    '${beforeUpdate!.modifiedAt.microsecondsSinceEpoch}',
  );
  await Future.delayed(const Duration(seconds: 10)); // for reassure update time
  final modifiedUpdateResult = await cRepo.updateCategory(
    id: modifiedTestId,
    name: 'Modified Test Updated',
    type: 'expense',
  );
  final afterUpdate = await cRepo.getById(modifiedTestId);
  print('After update: $afterUpdate');
  print(
    'AFTER microseconds: '
    '${afterUpdate!.modifiedAt.microsecondsSinceEpoch}',
  );

  print('Update result: $modifiedUpdateResult');
  if (modifiedUpdateResult == 1 &&
      afterUpdate.name == 'Modified Test Updated' &&
      afterUpdate.createdAt == beforeUpdate.createdAt &&
      (afterUpdate.modifiedAt.isAfter(beforeUpdate.modifiedAt) ||
          afterUpdate.modifiedAt.isAtSameMomentAs(beforeUpdate.modifiedAt))) {
    print(
      'PASS: updateCategory updated data and modifiedAt '
      'while keeping createdAt.',
    );
  } else {
    print('FAIL: modifiedAt / createdAt behavior is incorrect.');
  }
  await cRepo.deleteById(id: modifiedTestId);
  // ============================================================
  // 4. MISSING ID
  // ============================================================
  print('\n${'=' * 80}\n4. CATEGORY MISSING ID\n${'=' * 80}');
  final missingCategory = await cRepo.getById(missingCategoryId);
  if (missingCategory == null) {
    print('PASS: getById returned null for missing ID.');
  } else {
    print(
      'FAIL: Expected null.\n'
      'Result: $missingCategory',
    );
  }
  // UPDATE MISSING
  final updateMissingCategory = await cRepo.updateCategory(
    id: missingCategoryId,
    name: 'Should Not Exist',
    type: 'expense',
  );
  if (updateMissingCategory == 0) {
    print('PASS: update missing ID returned 0.');
  } else {
    print('FAIL: Expected update result = 0.');
  }
  // DELETE MISSING
  final deleteMissingCategory = await cRepo.deleteById(id: missingCategoryId);
  if (deleteMissingCategory == 0) {
    print('PASS: delete missing ID returned 0.');
  } else {
    print('FAIL: Expected delete result = 0.');
  }
  // ============================================================
  // 5. DUPLICATE ID
  // ============================================================
  print('\n${'=' * 80}\n5. CATEGORY DUPLICATE ID\n${'=' * 80}');
  await cRepo.deleteById(id: duplicateCategoryId);
  await cRepo.createCategory(
    id: duplicateCategoryId,
    name: 'Duplicate Original',
    type: 'expense',
    userId: categoryTestUserId,
  );
  try {
    await cRepo.createCategory(
      id: duplicateCategoryId,
      name: 'Duplicate Second',
      type: 'income',
      userId: categoryTestUserId,
    );
    print('FAIL: Duplicate category ID was accepted.');
  } catch (e) {
    print(
      'PASS: Duplicate category ID rejected.\n'
      'Exception: $e',
    );
  }
  final duplicateCategory = await cRepo.getById(duplicateCategoryId);
  if (duplicateCategory != null &&
      duplicateCategory.name == 'Duplicate Original') {
    print('PASS: Original category remained unchanged.');
  } else {
    print('FAIL: Original category was modified unexpectedly.');
  }
  await cRepo.deleteById(id: duplicateCategoryId);
  // ============================================================
  // 6. CATEGORY PERSISTENCE
  // ============================================================
  print('\n${'=' * 80}\n6. CATEGORY PERSISTENCE\n${'=' * 80}');
  final persistedCategory = await cRepo.getById(categoryPersistenceId);
  if (persistedCategory == null) {
    print(
      'Persistence data: NOT FOUND\n'
      'Creating persistence test category...',
    );
    try {
      final result = await cRepo.createCategory(
        id: categoryPersistenceId,
        name: categoryPersistenceName,
        type: 'expense',
        userId: categoryTestUserId,
      );
      print('Insert result: $result');
      final createdCategory = await cRepo.getById(categoryPersistenceId);
      print(
        'Created persistence data:\n'
        'Category: $createdCategory\n\n'
        'IMPORTANT:\n'
        'Close the program and run this test again.\n'
        'The second run should show:\n'
        'Persistence data: FOUND',
      );
    } catch (e) {
      print('FAIL: Unexpected exception: $e');
    }
  } else {
    print(
      'PASS: Persistence data FOUND.\n'
      'Category: $persistedCategory',
    );
    if (persistedCategory.id == categoryPersistenceId &&
        persistedCategory.name == categoryPersistenceName &&
        persistedCategory.userId == categoryTestUserId) {
      print('PASS: Persisted category data is correct.');
    } else {
      print('FAIL: Persisted category data is incorrect.');
    }
  }
  // ============================================================
  // CLEANUP MULTI TEST DATA
  // ============================================================
  print('\n[CATEGORY CLEANUP]');
  for (final category in multiCategories) {
    await cRepo.deleteById(id: category.$1);
  }
  print('Multi-category test data cleaned.');
  print('\n${'=' * 80}\n=== CATEGORY REPO TEST END ===\n${'=' * 80}');
  // ============================================================
  // CLOSE DATABASE
  // ============================================================
  await db.close();
}
