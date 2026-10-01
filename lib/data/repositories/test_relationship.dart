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

  void printSummary() {
    var cnt = 0;
    for (final testResult in summary) {
      if (!testResult.result) {
        print(testResult.toStr());
      } else {
        cnt++;
      }
    }
    print(
      'Summary: ${summary.length} tests, $cnt passed, ${summary.length - cnt} failed.',
    );
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
  final n2 = 'RELATIONSHIP - VALID FK';
  late final String d2;
  late final bool r2;
  print('\n${'-' * 80}\n[$n2]\n${'-' * 80}\n');
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
  final n3 = 'RELATIONSHIP - MISING PARENT';
  late final String d3, e3;
  late final bool r3;
  print('\n${'-' * 80}\n[$n3]\n${'-' * 80}\n');
  try {
    await cRepo.createCategory(
      id: categoryIdMisingTest,
      name: 'Invalid FK Category',
      type: 'expense',
      userId: missingUserId,
    );
    r3 = false;
    d3 = 'Category was inserted with a non-existing userId.';
    e3 = 'No exception was thrown for invalid foreign key.';
  } catch (e) {
    r3 = true;
    d3 = 'Invalid foreign key was rejected.';
    e3 = e.toString();
  }
  print('${r3 ? 'PASS' : 'FAIL'}: $d3\nException: $e3');
  updateSummary(name: n3, detail: d3, explain: e3, result: r3);
  final n4 = 'RELATIONSHIP - DELETE PARENT';
  late final String d4, e4;
  late final bool r4;
  print('\n${'-' * 80}\n[$n4]\n${'-' * 80}\n');
  try {
    await uRepo.deleteById(id: userIdFKTest);
    r4 = false;
    d4 = 'Parent User was deleted while Categories still reference it.';
    e4 = 'No exception was thrown for deleting parent with existing child records.';
  } catch (e) {
    r4 = true;
    d4 = 'Parent deletion was rejected because child records exist.';
    e4 = e.toString();
  }
  print('${r4 ? 'PASS' : 'FAIL'}: $d4\nException: $e4');
  final n5 = 'RELATIONSHIP - ORPHANS CHECK';
  late final String d5;
  late final bool r5;
  print('\n${'-' * 80}\n[$n5]\n${'-' * 80}\n');
  var orphanCount = 0;
  final categories = await cRepo.getAll();
  for (final category in categories) {
    final user = await uRepo.getById(category.userId);
    if (user == null) {
      r5 = false;
      d5 = d5.isEmpty
          ? 'Orphan Category found: ${category.id}'
          : '$d5, ${category.id}';
      print('FAIL: Orphan Category found: ${category.id}');
      orphanCount++;
    }
  }
  if (orphanCount == 0) {
    r5 = true;
    d5 = 'No Orphan Category found.';
  }
  print('${r5 ? 'PASS' : 'FAIL'}: $d5');
  updateSummary(name: n5, detail: d5, result: r5);
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
  printSummary();
}
