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
const transactionIdFKTest = 'test_transaction_fk_001';
const transactionIdMissingUserTest = 'test_transaction_fk_missing_user_001';
const transactionIdMissingCategoryTest =
    'test_transaction_fk_missing_category_001';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
  final tRepo = TransactionRepo(db: db);
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
    await tRepo.deleteById(id: transactionIdFKTest);
    await tRepo.deleteById(id: transactionIdMissingUserTest);
    await tRepo.deleteById(id: transactionIdMissingCategoryTest);
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

  final transactionResult = await tRepo.createTransaction(
    id: transactionIdFKTest,
    amount: 1250,
    categoryId: categoryIdFKTest,
    userId: userIdFKTest,
  );
  final transaction = await tRepo.getById(transactionIdFKTest);
  testResults.record(
    name: 'Create transaction with valid user and category foreign keys',
    passed:
        transactionResult > 0 &&
        transaction != null &&
        transaction.userId == userIdFKTest &&
        transaction.categoryId == categoryIdFKTest,
    failureDetail: 'Transaction was not created with the expected parents.',
  );

  try {
    await tRepo.createTransaction(
      id: transactionIdMissingUserTest,
      amount: 1250,
      categoryId: categoryIdFKTest,
      userId: missingUserId,
    );
    testResults.record(
      name: 'Reject transaction with a missing parent user',
      passed: false,
      failureDetail: 'Transaction was inserted with a non-existing user.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject transaction with a missing parent user',
      passed: true,
    );
  }

  try {
    await tRepo.createTransaction(
      id: transactionIdMissingCategoryTest,
      amount: 1250,
      categoryId: categoryIdMisingTest,
      userId: userIdFKTest,
    );
    testResults.record(
      name: 'Reject transaction with a missing parent category',
      passed: false,
      failureDetail: 'Transaction was inserted with a non-existing category.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject transaction with a missing parent category',
      passed: true,
    );
  }

  try {
    await cRepo.deleteById(id: categoryIdFKTest);
    testResults.record(
      name: 'Reject deleting a category referenced by transactions',
      passed: false,
      failureDetail:
          'Parent category was deleted while child transactions exist.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject deleting a category referenced by transactions',
      passed: true,
    );
  }

  try {
    await uRepo.deleteById(id: userIdFKTest);
    testResults.record(
      name: 'Reject deleting a user referenced by transactions',
      passed: false,
      failureDetail: 'Parent user was deleted while child records exist.',
    );
  } catch (_) {
    testResults.record(
      name: 'Reject deleting a user referenced by transactions',
      passed: true,
    );
  }

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

  var orphanTransactionCount = 0;
  final transactions = await tRepo.getAll();
  for (final transaction in transactions) {
    final user = await uRepo.getById(transaction.userId);
    final category = transaction.categoryId == null
        ? null
        : await cRepo.getById(transaction.categoryId!);
    if (user == null || (transaction.categoryId != null && category == null)) {
      orphanTransactionCount++;
    }
  }
  testResults.record(
    name: 'No orphan transactions',
    passed: orphanTransactionCount == 0,
    failureDetail: 'Found $orphanTransactionCount orphan transactions.',
  );
  testResults.printSummary();

  // CLEAN UP
  try {
    await tRepo.deleteById(id: transactionIdFKTest);
    await tRepo.deleteById(id: transactionIdMissingUserTest);
    await tRepo.deleteById(id: transactionIdMissingCategoryTest);
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
