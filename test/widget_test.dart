import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:buda_mvp/views/list_tpl_copy.dart';

// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d chrome --web-port 3000 D:\Project\Flutter\buda_mvp\test\widget_test.dart 2>&1 | Tee-Object -FilePath capture_log/test/"web_build_$time.txt"
// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d window D:\Project\Flutter\buda_mvp\test\widget_test.dart 2>&1 | Tee-Object -FilePath capture_log/test/"window_build_$time.txt"

void main() {
  testWidgets('list template scrolls and dispatches typed actions on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ListItemAction? selectedAction;
    String? selectedItem;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TListTemplate<String>(
              maxWidth: 288,
              items: List.generate(100, (index) => 'Item $index'),
              item2String: (item) => item,
              title: 'Items',
              actions: const [ListItemAction.remove, ListItemAction.filter],
              onChanged: (item, action) {
                selectedItem = item;
                selectedAction = action;
              },
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 99'), findsNothing);

    await tester.tap(find.byTooltip('Filter').first);
    expect(selectedItem, 'Item 0');
    expect(selectedAction, ListItemAction.filter);
  });

  testWidgets('action buttons wrap to fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 288,
            child: ListActionTemplate(
              actions: [
                ('Add user', _noop),
                ('Add category', _noop),
                ('Add Transaction', _noop),
                ('Clear all data', _noop),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Add user'), findsOneWidget);
    expect(find.text('Clear all data'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Add user')).dy,
      lessThan(tester.getTopLeft(find.text('Clear all data')).dy),
    );
  });
}

void _noop() {}
