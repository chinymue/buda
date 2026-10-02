// ignore_for_file: avoid_print
// flutter run <file_absolute_path>
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\data\repositories\test_repo.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import '../../utils/test_result_helper.dart';
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
  final testResults = TestResultHelper();

  await testUserRepo(db, testResults);
  await testCategoryRepo(db, testResults);
  await testTransactionRepo(db, testResults);
  testResults.printSummary();
  await db.close();
}

Future<void> testUserRepo(AppDatabase db, TestResultHelper testResults) async {
  final uRepo = UserRepo(db: db);
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
  if (currentUsers.isEmpty) {
    print('INFO: Database currently has no users.');
  } else {
    print('INFO: Database already contains ${currentUsers.length} users.');
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

  final createdUser = await uRepo.getById(singleId);
  final usersAfterInsert = await uRepo.getAll();

  testResults.record(
    name: 'Create user',
    passed:
        result > 0 &&
        createdUser != null &&
        createdUser.id == singleId &&
        createdUser.username == singleUsername &&
        usersAfterInsert.length == currentUsers.length + 1,
    failureDetail:
        'Insert result: $result; user: $createdUser; '
        'count: ${currentUsers.length} -> ${usersAfterInsert.length}.',
  );
  // ------------------------------------------------------------
  // READ BY ID
  // ------------------------------------------------------------
  print('\n[READ BY ID]');
  final singleUser = await uRepo.getById(singleId);
  testResults.record(
    name: 'Read user by ID',
    passed:
        singleUser != null &&
        singleUser.id == singleId &&
        singleUser.username == singleUsername,
    failureDetail: 'Unexpected result: $singleUser.',
  );
  // ------------------------------------------------------------
  // READ BY NAME
  // ------------------------------------------------------------
  print('\n[READ BY NAME]');
  final singleUserByName = await uRepo.getByName(singleUsername);
  testResults.record(
    name: 'Read user by name',
    passed:
        singleUserByName != null &&
        singleUserByName.id == singleId &&
        singleUserByName.username == singleUsername,
    failureDetail: 'Unexpected result: $singleUserByName.',
  );
  // ------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------
  print('\n[UPDATE]');
  const updatedUsername = 'single_user_updated';
  final updateResult = await uRepo.updateUser(
    id: singleId,
    username: updatedUsername,
  );
  final updatedUser = await uRepo.getById(singleId);
  testResults.record(
    name: 'Update user',
    passed:
        updateResult == 1 &&
        updatedUser != null &&
        updatedUser.username == updatedUsername,
    failureDetail: 'Update result: $updateResult; user: $updatedUser.',
  );
  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------
  print('\n[DELETE]');
  final deleteResult = await uRepo.deleteById(id: singleId);
  final deletedUser = await uRepo.getById(singleId);
  testResults.record(
    name: 'Delete user',
    passed: deleteResult == 1 && deletedUser == null,
    failureDetail:
        'Delete result: $deleteResult; remaining user: $deletedUser.',
  );
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
  testResults.record(
    name: 'Create multiple users',
    passed: multiFound.length == 3,
    failureDetail: 'Expected 3 users, found ${multiFound.length}.',
  );
  print('\n[UPDATE ONE RECORD]');
  final updateMultiResult = await uRepo.updateUser(
    id: 'test_multi_002',
    username: 'multi_bob_updated',
  );
  final multiAlice = await uRepo.getById('test_multi_001');
  final multiBob = await uRepo.getById('test_multi_002');
  final multiCharlie = await uRepo.getById('test_multi_003');
  testResults.record(
    name: 'Update one user without affecting other users',
    passed:
        updateMultiResult == 1 &&
        multiAlice?.username == 'multi_alice' &&
        multiBob?.username == 'multi_bob_updated' &&
        multiCharlie?.username == 'multi_charlie',
    failureDetail: 'User records do not match expected values.',
  );
  print('\n[DELETE ONE RECORD]');
  final deleteMultiResult = await uRepo.deleteById(id: 'test_multi_002');
  final remainingAlice = await uRepo.getById('test_multi_001');
  final deletedBob = await uRepo.getById('test_multi_002');
  final remainingCharlie = await uRepo.getById('test_multi_003');
  testResults.record(
    name: 'Delete one user without affecting other users',
    passed:
        deleteMultiResult == 1 &&
        remainingAlice != null &&
        deletedBob == null &&
        remainingCharlie != null,
    failureDetail:
        'Delete result: $deleteMultiResult; '
        'remaining Alice: $remainingAlice; deleted Bob: $deletedBob; '
        'remaining Charlie: $remainingCharlie.',
  );
  await uRepo.deleteById(id: 'test_multi_001');
  await uRepo.deleteById(id: 'test_multi_003');
  // ============================================================
  // 4. MISSING ID
  // ============================================================
  print('\n${'=' * 80}\n4. CHECK MISSING ID\n${'=' * 80}');
  const missingId = 'test_missing_999';
  final missingUser = await uRepo.getById(missingId);
  testResults.record(
    name: 'Read user by missing ID',
    passed: missingUser == null,
    failureDetail: 'Unexpected result: $missingUser.',
  );
  final updateMissingResult = await uRepo.updateUser(
    id: missingId,
    username: 'should_not_exist',
  );
  testResults.record(
    name: 'Update user with missing ID',
    passed: updateMissingResult == 0,
    failureDetail: 'Expected 0 affected rows, got $updateMissingResult.',
  );
  final deleteMissingResult = await uRepo.deleteById(id: missingId);
  testResults.record(
    name: 'Delete user with missing ID',
    passed: deleteMissingResult == 0,
    failureDetail: 'Expected 0 affected rows, got $deleteMissingResult.',
  );
  // ============================================================
  // 5. DUPLICATE CONSTRAINTS
  // ============================================================
  print('\n${'=' * 80}\n5. CHECK DUPLICATE CONSTRAINTS\n${'=' * 80}');
  await uRepo.deleteById(id: duplicateId);
  await uRepo.createUser(id: duplicateId, username: 'duplicate_user_1');
  print('\n[DUPLICATE ID]');
  try {
    await uRepo.createUser(id: duplicateId, username: 'duplicate_user_2');
    testResults.record(
      name: 'Reject duplicate user ID',
      passed: false,
      failureDetail: 'Duplicate ID was accepted.',
    );
  } catch (_) {
    testResults.record(name: 'Reject duplicate user ID', passed: true);
  }
  final duplicateIdUser = await uRepo.getById(duplicateId);
  testResults.record(
    name: 'Preserve original user after duplicate insert',
    passed: duplicateIdUser?.username == 'duplicate_user_1',
    failureDetail: 'Unexpected original user: $duplicateIdUser.',
  );
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
      final createdUser = await uRepo.getById(testId);
      testResults.record(
        name: 'Create user persistence data',
        passed:
            result > 0 &&
            createdUser != null &&
            createdUser.id == testId &&
            createdUser.username == testUsername,
        failureDetail: 'Insert result: $result; user: $createdUser.',
      );
      print(
        'Created persistence data:\nUser: $createdUser\n\nIMPORTANT:\nClose the program and run this test again.\nThe second run should show:\nPersistence data: FOUND',
      );
    } catch (e) {
      testResults.record(
        name: 'Create user persistence data',
        passed: false,
        failureDetail: 'Unexpected exception: $e',
      );
    }
  } else {
    testResults.record(name: 'Find persisted user', passed: true);
    if (persistedUser.id == testId && persistedUser.username == testUsername) {
      testResults.record(name: 'Validate persisted user', passed: true);
    } else {
      testResults.record(
        name: 'Validate persisted user',
        passed: false,
        failureDetail: 'Unexpected persisted user: $persistedUser.',
      );
    }
  }
  print('\n${'=' * 80}\n=== USER REPO TEST END ===\n${'=' * 80}');
}

Future<void> testCategoryRepo(
  AppDatabase db,
  TestResultHelper testResults,
) async {
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
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
  if (currentCategories.isEmpty) {
    print('INFO: Database currently has no categories.');
  } else {
    print(
      'INFO: Database already contains ${currentCategories.length} categories.',
    );
  }
  print('\n[CREATE]');
  final result1 = await cRepo.createCategory(
    id: categorySingleId,
    name: categorySingleName,
    type: categorySingleType,
    userId: categoryTestUserId,
  );

  final createdCategory = await cRepo.getById(categorySingleId);
  final categoriesAfterInsert = await cRepo.getAll();

  testResults.record(
    name: 'Create category',
    passed:
        result1 > 0 &&
        createdCategory != null &&
        createdCategory.id == categorySingleId &&
        createdCategory.name == categorySingleName &&
        createdCategory.type == categorySingleType &&
        createdCategory.userId == categoryTestUserId &&
        categoriesAfterInsert.length == currentCategories.length + 1,
    failureDetail:
        'Insert result: $result1; category: $createdCategory; '
        'count: ${currentCategories.length} -> ${categoriesAfterInsert.length}.',
  );
  print('\n[READ BY ID]');
  final categoryById = await cRepo.getById(categorySingleId);
  testResults.record(
    name: 'Read category by ID',
    passed:
        categoryById != null &&
        categoryById.id == categorySingleId &&
        categoryById.name == categorySingleName &&
        categoryById.type == categorySingleType &&
        categoryById.userId == categoryTestUserId,
    failureDetail: 'Unexpected result: $categoryById.',
  );
  print('\n[READ BY NAME]');
  final categoryByName = await cRepo.getByName(categorySingleName);
  testResults.record(
    name: 'Read category by name',
    passed:
        categoryByName != null &&
        categoryByName.id == categorySingleId &&
        categoryByName.name == categorySingleName,
    failureDetail: 'Unexpected result: $categoryByName.',
  );
  print('\n[READ BY TYPE]');
  final expenseCategories = await cRepo.getByType(categorySingleType);
  final foundByType = expenseCategories.any(
    (category) => category.id == categorySingleId,
  );
  testResults.record(
    name: 'Filter categories by type',
    passed: foundByType,
    failureDetail: 'Expected category $categorySingleId in type results.',
  );
  print('\n[READ BY USER ID]');
  final userCategories = await cRepo.getByUserId(categoryTestUserId);
  final foundByUserId = userCategories.any(
    (category) => category.id == categorySingleId,
  );
  testResults.record(
    name: 'Filter categories by user ID',
    passed: foundByUserId,
    failureDetail: 'Expected category $categorySingleId in user results.',
  );
  print('\n[READ BY USER ID + NAME]');
  final userNameCategories = await cRepo.getByUserIdAndName(
    categoryTestUserId,
    categorySingleName,
  );
  testResults.record(
    name: 'Filter categories by user ID and name',
    passed:
        userNameCategories.length == 1 &&
        userNameCategories.first.id == categorySingleId,
    failureDetail: 'Unexpected result: $userNameCategories.',
  );
  print('\n[READ BY USER ID + TYPE]');
  final userTypeCategories = await cRepo.getByUserIdAndType(
    categoryTestUserId,
    categorySingleType,
  );
  final foundByUserAndType = userTypeCategories.any(
    (category) => category.id == categorySingleId,
  );
  testResults.record(
    name: 'Filter categories by user ID and type',
    passed: foundByUserAndType,
    failureDetail: 'Expected category $categorySingleId in filtered results.',
  );
  print('\n[UPDATE]');
  final updateCategoryResult = await cRepo.updateCategory(
    id: categorySingleId,
    name: updatedCategoryName,
    type: updatedCategoryType,
  );
  final updatedCategory = await cRepo.getById(categorySingleId);
  testResults.record(
    name: 'Update category',
    passed:
        updateCategoryResult == 1 &&
        updatedCategory != null &&
        updatedCategory.name == updatedCategoryName &&
        updatedCategory.type == updatedCategoryType &&
        updatedCategory.userId == categoryTestUserId,
    failureDetail:
        'Update result: $updateCategoryResult; category: $updatedCategory.',
  );
  print('\n[DELETE]');
  final deleteCategoryResult = await cRepo.deleteById(id: categorySingleId);
  final deletedCategory = await cRepo.getById(categorySingleId);
  testResults.record(
    name: 'Delete category',
    passed: deleteCategoryResult == 1 && deletedCategory == null,
    failureDetail:
        'Delete result: $deleteCategoryResult; remaining category: $deletedCategory.',
  );
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
    if (result <= 0) {
      testResults.record(
        name: 'Create category ${category.$1}',
        passed: false,
        failureDetail: 'Insert returned $result.',
      );
    }
  }
  print('\n[GET ALL]');
  final allCategories = await cRepo.getAll();
  final multiCategoriesFound = allCategories
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  testResults.record(
    name: 'Create multiple categories',
    passed: multiCategoriesFound.length == 4,
    failureDetail:
        'Expected 4 categories, found ${multiCategoriesFound.length}: '
        '$multiCategoriesFound.',
  );
  print('\n[FILTER BY TYPE]');
  final expenseResult = await cRepo.getByType('expense');
  final expenseMultiFound = expenseResult
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  testResults.record(
    name: 'Filter categories by type',
    passed: expenseMultiFound.length == 3,
    failureDetail:
        'Expected 3 expense categories, found ${expenseMultiFound.length}.',
  );
  print('\n[FILTER BY USER ID]');
  final userResult = await cRepo.getByUserId(categoryTestUserId);
  final userMultiFound = userResult
      .where((c) => c.id.startsWith('test_category_multi_'))
      .toList();
  testResults.record(
    name: 'Filter categories by user ID',
    passed: userMultiFound.length == 3,
    failureDetail:
        'Expected 3 categories for test user, found ${userMultiFound.length}.',
  );
  print('\n[FILTER BY USER ID + NAME]');
  final userNameResult = await cRepo.getByUserIdAndName(
    categoryTestUserId,
    'Food',
  );
  testResults.record(
    name: 'Filter categories by user ID and name',
    passed:
        userNameResult.length == 1 &&
        userNameResult.first.id == 'test_category_multi_001',
    failureDetail: 'Unexpected result: $userNameResult.',
  );
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
  testResults.record(
    name: 'Filter categories by user ID and type',
    passed: setEquals(actualUserTypeIds, expectedUserTypeIds),
    failureDetail: 'Unexpected category IDs: $actualUserTypeIds.',
  );
  print('\n${'=' * 80}\nCATEGORY getByAttribute\n${'=' * 80}');
  print('\n[ATTRIBUTE: ID]');
  final attrById = await cRepo.getByAttribute(id: 'test_category_multi_001');
  testResults.record(
    name: 'Filter categories by ID attribute',
    passed:
        attrById.length == 1 && attrById.first.id == 'test_category_multi_001',
    failureDetail: 'Unexpected result: $attrById.',
  );
  print('\n[ATTRIBUTE: NAME]');
  final attrByName = await cRepo.getByAttribute(name: 'Food');
  testResults.record(
    name: 'Filter categories by name attribute',
    passed: attrByName.length == 1 && attrByName.first.name == 'Food',
    failureDetail: 'Unexpected result: $attrByName.',
  );
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
  testResults.record(
    name: 'Filter categories by type attribute',
    passed: setEquals(attrExpenseIds, expectedExpenseIds),
    failureDetail: 'Unexpected category IDs: $attrExpenseIds.',
  );
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
  testResults.record(
    name: 'Filter categories by user ID attribute',
    passed: setEquals(attrUserIds, expectedUserIds),
    failureDetail: 'Unexpected category IDs: $attrUserIds.',
  );
  print('\n[ATTRIBUTE: USER ID + TYPE]');
  final attrByUserAndType = await cRepo.getByAttribute(
    userId: categoryTestUserId,
    type: 'expense',
  );
  final attrUserTypeIds = attrByUserAndType
      .where((category) => category.id.startsWith('test_category_multi_'))
      .map((category) => category.id)
      .toSet();
  testResults.record(
    name: 'Filter categories by user ID and type attributes',
    passed: setEquals(attrUserTypeIds, expectedUserTypeIds),
    failureDetail: 'Unexpected category IDs: $attrUserTypeIds.',
  );
  print('\n[ATTRIBUTE: USER ID + NAME + TYPE]');
  final attrAll = await cRepo.getByAttribute(
    userId: categoryTestUserId,
    name: 'Food',
    type: 'expense',
  );
  testResults.record(
    name: 'Filter categories by all attributes',
    passed:
        attrAll.length == 1 && attrAll.first.id == 'test_category_multi_001',
    failureDetail: 'Unexpected result: $attrAll.',
  );
  print('\n[ATTRIBUTE: NO ATTRIBUTE]');
  final attrNone = await cRepo.getByAttribute();
  final attrNoneTestCategories = attrNone
      .where((category) => category.id.startsWith('test_category_multi_'))
      .toList();
  testResults.record(
    name: 'Return no categories without filter attributes',
    passed: attrNoneTestCategories.isEmpty,
    failureDetail: 'Unexpected categories: $attrNoneTestCategories.',
  );
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
  if (beforeUpdate == null) {
    throw StateError('Modified test category was not created.');
  }
  await Future.delayed(const Duration(seconds: 10)); // for reassure update time
  final modifiedUpdateResult = await cRepo.updateCategory(
    id: modifiedTestId,
    name: 'Modified Test Updated',
    type: 'expense',
  );
  final afterUpdate = await cRepo.getById(modifiedTestId);
  testResults.record(
    name: 'Update category timestamps',
    passed:
        modifiedUpdateResult == 1 &&
        afterUpdate != null &&
        afterUpdate.name == 'Modified Test Updated' &&
        afterUpdate.createdAt == beforeUpdate.createdAt &&
        (afterUpdate.modifiedAt.isAfter(beforeUpdate.modifiedAt) ||
            afterUpdate.modifiedAt.isAtSameMomentAs(beforeUpdate.modifiedAt)),
    failureDetail:
        'Update result: $modifiedUpdateResult; '
        'before: $beforeUpdate; after: $afterUpdate.',
  );
  await cRepo.deleteById(id: modifiedTestId);
  // ============================================================
  // 4. MISSING ID
  // ============================================================
  print('\n${'=' * 80}\n4. CATEGORY MISSING ID\n${'=' * 80}');
  final missingCategory = await cRepo.getById(missingCategoryId);
  testResults.record(
    name: 'Read category by missing ID',
    passed: missingCategory == null,
    failureDetail: 'Unexpected result: $missingCategory.',
  );
  // UPDATE MISSING
  final updateMissingCategory = await cRepo.updateCategory(
    id: missingCategoryId,
    name: 'Should Not Exist',
    type: 'expense',
  );
  testResults.record(
    name: 'Update category with missing ID',
    passed: updateMissingCategory == 0,
    failureDetail: 'Expected 0 affected rows, got $updateMissingCategory.',
  );
  // DELETE MISSING
  final deleteMissingCategory = await cRepo.deleteById(id: missingCategoryId);
  testResults.record(
    name: 'Delete category with missing ID',
    passed: deleteMissingCategory == 0,
    failureDetail: 'Expected 0 affected rows, got $deleteMissingCategory.',
  );
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
    testResults.record(
      name: 'Reject duplicate category ID',
      passed: false,
      failureDetail: 'Duplicate category ID was accepted.',
    );
  } catch (_) {
    testResults.record(name: 'Reject duplicate category ID', passed: true);
  }
  final duplicateCategory = await cRepo.getById(duplicateCategoryId);
  testResults.record(
    name: 'Preserve original category after duplicate insert',
    passed:
        duplicateCategory != null &&
        duplicateCategory.name == 'Duplicate Original',
    failureDetail: 'Unexpected original category: $duplicateCategory.',
  );
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
      final createdCategory = await cRepo.getById(categoryPersistenceId);
      testResults.record(
        name: 'Create category persistence data',
        passed:
            result > 0 &&
            createdCategory != null &&
            createdCategory.id == categoryPersistenceId &&
            createdCategory.name == categoryPersistenceName &&
            createdCategory.userId == categoryTestUserId,
        failureDetail: 'Insert result: $result; category: $createdCategory.',
      );
      print(
        'Created persistence data:\n'
        'Category: $createdCategory\n\n'
        'IMPORTANT:\n'
        'Close the program and run this test again.\n'
        'The second run should show:\n'
        'Persistence data: FOUND',
      );
    } catch (e) {
      testResults.record(
        name: 'Create category persistence data',
        passed: false,
        failureDetail: 'Unexpected exception: $e',
      );
    }
  } else {
    testResults.record(name: 'Find persisted category', passed: true);
    if (persistedCategory.id == categoryPersistenceId &&
        persistedCategory.name == categoryPersistenceName &&
        persistedCategory.userId == categoryTestUserId) {
      testResults.record(name: 'Validate persisted category', passed: true);
    } else {
      testResults.record(
        name: 'Validate persisted category',
        passed: false,
        failureDetail: 'Unexpected persisted category: $persistedCategory.',
      );
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
}

Future<void> testTransactionRepo(
  AppDatabase db,
  TestResultHelper testResults,
) async {
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
  const transactionUserId = 'test_transaction_user_001';
  const transactionUsername = 'transaction_test_user';
  const transactionCategoryId = 'test_transaction_category_001';
  const transactionIds = [
    'test_transaction_001',
    'test_transaction_002',
    'test_transaction_003',
  ];
  final transactionIdSet = transactionIds.toSet();
  final transactionDates = [
    DateTime(2025, 1, 10),
    DateTime(2025, 1, 20),
    DateTime(2025, 2, 1),
  ];
  final tRepo = TransactionRepo(db: db);

  print('\n${'=' * 80}\n=== TRANSACTION REPO TEST START ===\n${'=' * 80}');

  // Clear only this test's data, in foreign-key order.
  await tRepo.deleteByUserId(id: transactionUserId);
  await cRepo.deleteById(id: transactionCategoryId);
  await uRepo.deleteById(id: transactionUserId);

  await uRepo.createUser(id: transactionUserId, username: transactionUsername);
  await cRepo.createCategory(
    id: transactionCategoryId,
    name: 'Transaction Test Category',
    type: 'income',
    userId: transactionUserId,
  );

  print('\n[CREATE AND READ]');
  final createdResult = await tRepo.createTransaction(
    id: transactionIds[0],
    amount: 1200,
    date: transactionDates[0],
    categoryId: transactionCategoryId,
    userId: transactionUserId,
  );
  final createdTransaction = await tRepo.getById(transactionIds[0]);
  testResults.record(
    name: 'Create transaction with category-derived type',
    passed:
        createdResult > 0 &&
        createdTransaction != null &&
        createdTransaction.amount == 1200 &&
        createdTransaction.type == 'income' &&
        createdTransaction.categoryId == transactionCategoryId &&
        createdTransaction.userId == transactionUserId &&
        createdTransaction.date == transactionDates[0],
    failureDetail:
        'Insert result: $createdResult; transaction: $createdTransaction.',
  );

  final secondResult = await tRepo.createTransaction(
    id: transactionIds[1],
    amount: 450,
    type: 'expense',
    date: transactionDates[1],
    categoryId: transactionCategoryId,
    userId: transactionUserId,
  );
  final thirdResult = await tRepo.createTransaction(
    id: transactionIds[2],
    amount: 2500,
    type: 'expense',
    date: transactionDates[2],
    userId: transactionUserId,
  );
  final allTransactions = await tRepo.getAll();
  final createdTransactions = allTransactions
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  testResults.record(
    name: 'Create multiple transactions',
    passed:
        secondResult > 0 &&
        thirdResult > 0 &&
        createdTransactions.length == transactionIds.length,
    failureDetail:
        'Insert results: $secondResult, $thirdResult; '
        'found ${createdTransactions.length} test transactions.',
  );

  print('\n[FILTER]');
  final incomeTransactions = (await tRepo.getByType('income'))
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  final byCategory = await tRepo.getByCategory(transactionCategoryId);
  final byUser = await tRepo.getByUser(transactionUserId);
  final amountRange = (await tRepo.getByAmount(
    amountMin: 400,
    amountMax: 1300,
  )).where((transaction) => transactionIdSet.contains(transaction.id)).toList();
  final minimumAmount = (await tRepo.getByAmount(amountMin: 2000))
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  final maximumAmount = (await tRepo.getByAmount(amountMax: 450))
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  final allByAmount = (await tRepo.getByAmount())
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  final exactDate = (await tRepo.getByDate(start: transactionDates[0]))
      .where((transaction) => transactionIdSet.contains(transaction.id))
      .toList();
  final dateRange = (await tRepo.getByDate(
    start: transactionDates[0],
    end: transactionDates[1],
  )).where((transaction) => transactionIdSet.contains(transaction.id)).toList();
  final byAttributes = (await tRepo.getByAttribute(
    amountMin: 400,
    amountMax: 1300,
    type: 'expense',
    start: transactionDates[0],
    end: transactionDates[1],
    categoryId: transactionCategoryId,
    userId: transactionUserId,
  )).toList();
  final allByAttributes = await tRepo.getByAttribute();
  testResults.record(
    name: 'Filter transactions by type',
    passed:
        incomeTransactions.length == 1 &&
        incomeTransactions.single.id == transactionIds[0],
    failureDetail: 'Unexpected income transactions: $incomeTransactions.',
  );
  testResults.record(
    name: 'Filter transactions by category and user',
    passed: byCategory.length == 2 && byUser.length == transactionIds.length,
    failureDetail: 'Category results: $byCategory; user results: $byUser.',
  );
  testResults.record(
    name: 'Filter transactions by amount and date range',
    passed:
        amountRange.length == 2 &&
        minimumAmount.length == 1 &&
        minimumAmount.single.id == transactionIds[2] &&
        maximumAmount.length == 1 &&
        maximumAmount.single.id == transactionIds[1] &&
        allByAmount.length == transactionIds.length &&
        exactDate.length == 1 &&
        exactDate.single.id == transactionIds[0] &&
        dateRange.length == 2 &&
        byAttributes.length == 1 &&
        byAttributes.single.id == transactionIds[1] &&
        allByAttributes
                .where(
                  (transaction) => transactionIdSet.contains(transaction.id),
                )
                .length ==
            transactionIds.length,
    failureDetail:
        'Amount results: $amountRange; date results: $dateRange; '
        'attribute results: $byAttributes; all attributes: $allByAttributes.',
  );

  print('\n[UPDATE]');
  final updatedDate = DateTime(2025, 1, 15);
  final updateResult = await tRepo.updateT(
    transactionIds[0],
    amount: 1350,
    type: 'expense',
    date: updatedDate,
  );
  final updatedTransaction = await tRepo.getById(transactionIds[0]);
  testResults.record(
    name: 'Update transaction',
    passed:
        updateResult == 1 &&
        updatedTransaction != null &&
        updatedTransaction.amount == 1350 &&
        updatedTransaction.type == 'expense' &&
        updatedTransaction.date == updatedDate,
    failureDetail:
        'Update result: $updateResult; transaction: $updatedTransaction.',
  );
  final negativeUpdateResult = await tRepo.updateT(
    transactionIds[0],
    amount: -1,
  );
  final afterNegativeUpdate = await tRepo.getById(transactionIds[0]);
  testResults.record(
    name: 'Ignore negative transaction amount on update',
    passed: negativeUpdateResult == 1 && afterNegativeUpdate?.amount == 1350,
    failureDetail:
        'Update result: $negativeUpdateResult; '
        'transaction: $afterNegativeUpdate.',
  );
  final negativeCreateResult = await tRepo.createTransaction(
    id: 'test_transaction_negative_001',
    amount: -1,
    userId: transactionUserId,
  );
  testResults.record(
    name: 'Reject negative transaction amount on create',
    passed:
        negativeCreateResult == -1 &&
        await tRepo.getById('test_transaction_negative_001') == null,
    failureDetail: 'Insert result: $negativeCreateResult.',
  );

  print('\n[DELETE]');
  final deleteMissingResult = await tRepo.deleteById(
    id: 'test_transaction_missing_999',
  );
  testResults.record(
    name: 'Delete transaction with missing ID',
    passed: deleteMissingResult == 0,
    failureDetail: 'Expected 0 affected rows, got $deleteMissingResult.',
  );
  final deleteByIdResult = await tRepo.deleteById(id: transactionIds[0]);
  testResults.record(
    name: 'Delete transaction by ID',
    passed:
        deleteByIdResult == 1 && await tRepo.getById(transactionIds[0]) == null,
    failureDetail: 'Delete result: $deleteByIdResult.',
  );
  final deleteByCategoryResult = await tRepo.deleteByCategoryId(
    id: transactionCategoryId,
  );
  final remainingCategoryTransactions = await tRepo.getByCategory(
    transactionCategoryId,
  );
  testResults.record(
    name: 'Delete transactions by category ID',
    passed:
        deleteByCategoryResult == 1 &&
        remainingCategoryTransactions.isEmpty &&
        await tRepo.getById(transactionIds[2]) != null,
    failureDetail:
        'Deleted $deleteByCategoryResult; remaining: '
        '$remainingCategoryTransactions.',
  );
  final deleteByUserResult = await tRepo.deleteByUserId(id: transactionUserId);
  final remainingUserTransactions = await tRepo.getByUser(transactionUserId);
  testResults.record(
    name: 'Delete transactions by user ID',
    passed: deleteByUserResult == 1 && remainingUserTransactions.isEmpty,
    failureDetail:
        'Deleted $deleteByUserResult; remaining: $remainingUserTransactions.',
  );

  await cRepo.deleteById(id: transactionCategoryId);
  await uRepo.deleteById(id: transactionUserId);
  print('\n${'=' * 80}\n=== TRANSACTION REPO TEST END ===\n${'=' * 80}');
}
