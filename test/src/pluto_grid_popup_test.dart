import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = PlutoGridSettings.columnWidth;

  late PlutoGridStateManager stateManager;

  Future<void> _build(tester, columns, rows, textDirection) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: 1000,
      height: 450,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Directionality(
            textDirection: textDirection,
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    PlutoGridPopup(
                      context: context,
                      columns: columns,
                      rows: rows,
                      onLoaded: (event) => stateManager = event.stateManager,
                    );
                  },
                  child: const Text(buttonText),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'Directionality.ltr 인 경우, '
      'stateManager.isLTR, isRTL 이 적용 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await _build(tester, columns, rows, TextDirection.ltr);

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, true);
    expect(stateManager.isRTL, false);
  });

  testWidgets(
      'Directionality.rtl 인 경우, '
      'stateManager.isLTR, isRTL 이 적용 되어야 한다.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await _build(tester, columns, rows, TextDirection.rtl);

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, false);
    expect(stateManager.isRTL, true);
  });

  testWidgets(
    'Directionality.rtl 인 경우 컬럼의 위치가 RTL 적용 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await _build(tester, columns, rows, TextDirection.rtl);

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstColumn = find.text('title0');
      final firstStartPosition = tester.getTopRight(firstColumn);

      final secondColumn = find.text('title1');
      final secondStartPosition = tester.getTopRight(secondColumn);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll!.horizontal!.offset;

      final lastColumn = find.text('title9');
      final lastStartPosition = tester.getTopRight(lastColumn);

      // 처음 컬럼의 dx 가 우측에 위치해 가장 크고 두번째 컬럼은 컬럼 넓이 만큼 작다.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // 마지막 컬럼은 앞의 9개 컬럼의 넓이에서 스크롤을 뺀 위치에 있다.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets(
    'Directionality.rtl 인 경우 셀의 위치가 RTL 적용 되어야 한다.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await _build(tester, columns, rows, TextDirection.rtl);

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstCell = find.text('title0 value 0');
      final firstStartPosition = tester.getTopRight(firstCell);

      final secondCell = find.text('title1 value 0');
      final secondStartPosition = tester.getTopRight(secondCell);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll!.horizontal!.offset;

      final lastCell = find.text('title9 value 0');
      final lastStartPosition = tester.getTopRight(lastCell);

      // 처음 셀의 dx 가 우측에 위치해 가장 크고 두번째 셀은 컬럼 넓이 만큼 작다.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // 마지막 셀은 앞의 9개 셀의 넓이에서 스크롤을 뺀 위치에 있다.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );
}
