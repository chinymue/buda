// ignore_for_file: avoid_print
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_relationship.dart
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\data\repositories\test_relationship.dart
import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import '../../utils/test_result_helper.dart';
import 'repo.dart';

const userIdFKTest = 'test_user_fk_001';
const userNameFKTest = 'FK Test User';
const categoryIdFKTest = 'test_category_fk_001';
const categoryNameFKTest = 'FK Test Category';
const expenseTypeFKTest = 'expense';
const categoryIdMisingTest = 'test_category_fk_invalid_001';
const missingUserId = 'test_user_fk_missing_001';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
  final testResults = TestResultHelper();

  // ==================================================================
  // ========= TEST RELATIONSHIP USER -> CATEGORY =====================
  // ==================================================================
  // CHECK FK KEYS
  final fkStatus = await db.customSelect('PRAGMA foreign_keys').getSingle();
  final enabled = fkStatus.data['foreign_keys'] == 1;
  testResults.record(
    name: 'SQLite foreign-key enforcement',
    passed: enabled,
    failureDetail: 'Foreign-key enforcement is disabled.',
  );

  // CLEAN UP
  try {
    await cRepo.deleteById(id: categoryIdFKTest);
    await cRepo.deleteById(id: categoryIdMisingTest);
    await uRepo.deleteById(id: userIdFKTest);
    await uRepo.deleteById(id: missingUserId);
  } catch (e) {
    print('Clean up got unexpected exception: $e');
  }

  await uRepo.createUser(id: userIdFKTest, username: userNameFKTest);
  final result = await cRepo.createCategory(
    id: categoryIdFKTest,
    name: categoryNameFKTest,
    type: expenseTypeFKTest,
    userId: userIdFKTest,
  );
  final category = await cRepo.getById(categoryIdFKTest);
  testResults.record(
    name: 'Create category with a valid user foreign key',
    passed: result > 0 && category != null && category.userId == userIdFKTest,
    failureDetail: 'Category was not created with the expected user.',
  );

  // TODO: add test for transaction table, which has a foreign key to category table
  try {
    await cRepo.createCategory(
      id: categoryIdMisingTest,
      name: 'Invalid FK Category',
      type: 'expense',
      userId: missingUserId,
    );
    testResults.record(
      name: 'Reject category with a missing parent user',
      passed: false,
      failureDetail: 'Category was inserted with a non-existing user.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject category with a missing parent user',
      passed: true,
    );
  }

  try {
    await uRepo.deleteById(id: userIdFKTest);
    testResults.record(
      name: 'Reject deleting a user referenced by categories',
      passed: false,
      failureDetail: 'Parent user was deleted while child records exist.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject deleting a user referenced by categories',
      passed: true,
    );
  }

  var orphanCount = 0;
  final categories = await cRepo.getAll();
  for (final category in categories) {
    final user = await uRepo.getById(category.userId);
    if (user == null) {
      orphanCount++;
    }
  }
  testResults.record(
    name: 'No orphan categories',
    passed: orphanCount == 0,
    failureDetail: 'Found $orphanCount orphan categories.',
  );
  testResults.printSummary();

  // CLEAN UP
  try {
    await cRepo.deleteById(id: categoryIdFKTest);
    await cRepo.deleteById(id: categoryIdMisingTest);
    await uRepo.deleteById(id: userIdFKTest);
    await uRepo.deleteById(id: missingUserId);
  } catch (e) {
    print('Clean up got unexpected exception: $e');
  }
  // ============================================================
  // CLOSE DATABASE
  // ============================================================
  await db.close();
}
