// ignore_for_file: avoid_print
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\data\repositories\test_relationship.dart
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\data\repositories\test_relationship.dart
import 'package:flutter/widgets.dart';

import '../database/app_database.dart';
import 'repo.dart';

const userIdFKTest = 'test_user_fk_001';
const userNameFKTest = 'FK Test User';
const categoryIdFKTest = 'test_category_fk_001';
const categoryNameFKTest = 'FK Test Category';
const expenseTypeFKTest = 'expense';
const categoryIdMisingTest = 'test_category_fk_invalid_001';
const missingUserId = 'test_user_fk_missing_001';

class TestResult {
  final String name;
  final String detail;
  final bool result;
  final String explain;
  final DateTime timestramp;
  TestResult({
    required this.name,
    required this.detail,
    required this.explain,
    required this.result,
    required this.timestramp,
  });

  TestResult.defaultTestResult(this.name, this.detail, this.result)
    : explain = '',
      timestramp = DateTime.now();

  String toStr() =>
      "test result: {name: $name, detail: $detail, explain: $explain, result: $result, timestramp: $timestramp}";
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final uRepo = UserRepo(db: db);
  final cRepo = CategoryRepo(db: db);
  Future.delayed(const Duration(seconds: 3));
  // TODO: Add summary test
  List<TestResult> summary = [];
  void updateSummary({
    required String name,
    required String detail,
    String explain = '',
    required bool result,
  }) {
    late final TestResult testResult;
    testResult = explain.isEmpty
        ? TestResult.defaultTestResult(name, detail, result)
        : TestResult(
            name: name,
            detail: detail,
            explain: explain,
            result: result,
            timestramp: DateTime.now(),
          );

    summary.add(testResult);
    print(testResult.toStr());
  }

  // ==================================================================
  // ========= TEST RELATIONSHIP USER -> CATEGORY =====================
  // ==================================================================
  // CHECK FK KEYS
  print('${'-' * 15} [PRE-CHECK FK KEYS] ${'-' * 15}');
  final fkStatus = await db.customSelect('PRAGMA foreign_keys').getSingle();
  final enabled = fkStatus.data['foreign_keys'] == 1;
  final String n1 = 'SQLite foreign-key enforcement';
  final bool r1 = enabled;
  final String d1 =
      'SQLite foreign-key enforcement is ${enabled ? 'enabled' : 'disabled'}.';
  updateSummary(name: n1, detail: d1, result: r1);
  print('${r1 ? 'PASS' : 'FAIL'}: $d1');
  print('FOREIGN KEY STATUS: ${fkStatus.data['foreign_keys']}');
  final categoryFks = await db
      .customSelect('PRAGMA foreign_key_list(categories)')
      .get();
  print('CATEGORY FOREIGN KEYS:');
  for (final row in categoryFks) {
    print(row.data);
  }
  // CLEAN UP
  print('${'-' * 15} [PRE-CLEAN DATABASE] ${'-' * 15}');
  try {
    await cRepo.deleteById(id: categoryIdFKTest);
    await cRepo.deleteById(id: categoryIdMisingTest);
    await uRepo.deleteById(id: userIdFKTest);
    await uRepo.deleteById(id: missingUserId);
  } catch (e) {
    print('Clean up got unexpected exception: $e');
  }
  print(
    '\n${'=' * 80}\n${' ' * 15}[START] TEST RELATIONSHIP: USER -> CATEGORY\n${'=' * 80}\n',
  );
  print('\n${'-' * 80}\n[RELATIONSHIP - VALID FK]\n${'-' * 80}\n');
  final n2 = 'Create User and Category with valid foreign key';
  late final String d2;
  late final bool r2;
  await uRepo.createUser(id: userIdFKTest, username: userNameFKTest);
  final result = await cRepo.createCategory(
    id: categoryIdFKTest,
    name: categoryNameFKTest,
    type: expenseTypeFKTest,
    userId: userIdFKTest,
  );
  final category = await cRepo.getById(categoryIdFKTest);
  if (result > 0 && category != null && category.userId == userIdFKTest) {
    r2 = true;
    d2 = 'Category created with valid foreign key.';
  } else {
    r2 = false;
    d2 = 'Failed to create category with valid foreign key.';
  }
  print('${r2 ? 'PASS' : 'FAIL'}: $d2');
  updateSummary(name: n2, detail: d2, result: r2);
  // TODO: continue here, still add summary for each test case
  // TODO: add test for transaction table, which has a foreign key to category table
  print('\n${'-' * 80}\n[RELATIONSHIP - MISING PARENT]\n${'-' * 80}\n');
  try {
    await cRepo.createCategory(
      id: categoryIdMisingTest,
      name: 'Invalid FK Category',
      type: 'expense',
      userId: missingUserId,
    );
    print('FAIL: Category was inserted with a non-existing userId.');
  } catch (e) {
    print('PASS: Invalid foreign key was rejected.\nException: $e');
  }
  print('\n${'-' * 80}\n[RELATIONSHIP - DELETE PARENT]\n${'-' * 80}\n');
  try {
    await uRepo.deleteById(id: userIdFKTest);
    print('FAIL: Parent User was deleted while Categories still reference it.');
  } catch (e) {
    print(
      'PASS: Parent deletion was rejected because child records exist.\nException: $e',
    );
  }
  print('\n${'-' * 80}\n[RELATIONSHIP - ORPHANS CHECK]\n${'-' * 80}\n');
  var orphanCount = 0;
  final categories = await cRepo.getAll();
  for (final category in categories) {
    final user = await uRepo.getById(category.userId);
    if (user == null) {
      print('FAIL: Orphan Category found: ${category.id}');
      orphanCount++;
    }
  }
  if (orphanCount == 0) {
    print('PASS: No Orphan Category found');
  }
  print(
    '\n${'=' * 80}\n${' ' * 15}[END] TEST RELATIONSHIP: USER -> CATEGORY\n${'=' * 80}\n',
  );
  // CLEAN UP
  print('${'-' * 15} [POST-CLEAN DATABASE] ${'-' * 15}');
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
