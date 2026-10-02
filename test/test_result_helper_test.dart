import 'package:buda_mvp/utils/test_result_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('records concise results and prints an aggregate summary', () async {
    final results = TestResultHelper();

    await expectLater(
      () {
        results.record(name: 'valid relationship', passed: true);
        results.record(
          name: 'missing parent',
          passed: false,
          failureDetail: 'Foreign key was not enforced.',
        );
        results.printSummary();
      },
      prints(
        '[PASS] valid relationship\n'
        '[FAIL] missing parent - Foreign key was not enforced.\n'
        'Summary: 1 passed, 1 failed (2 total)\n',
      ),
    );
  });
}
