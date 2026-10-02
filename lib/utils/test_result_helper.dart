// ignore_for_file: avoid_print

class TestResultHelper {
  int _passed = 0;
  int _failed = 0;

  void record({
    required String name,
    required bool passed,
    String? failureDetail,
  }) {
    if (passed) {
      _passed++;
    } else {
      _failed++;
    }

    final status = passed ? 'PASS' : 'FAIL';
    final detail = !passed && failureDetail != null ? ' - $failureDetail' : '';
    print('[$status] $name$detail');
  }

  void printSummary() {
    final total = _passed + _failed;
    print('Summary: $_passed passed, $_failed failed ($total total)');
  }
}
