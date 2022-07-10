import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  testWidgets(
      '0,4번 컬림이 고정 된 상태에서'
      '2번 컬럼 고정 후 방향키 이동시 정상적으로 이동 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = [
      ColumnHelper.textColumn('headerL', frozen: PlutoColumnFrozen.left).first,
      ...ColumnHelper.textColumn('headerB', count: 3),
      ColumnHelper.textColumn('headerR', frozen: PlutoColumnFrozen.right).first,
    ];
    final rows = RowHelper.count(10, columns);

    PlutoGridStateManager? stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pump();

    // 세번 째 컬럼 왼쪽 고정
    stateManager!.toggleFrozenColumn(columns[2].key, PlutoColumnFrozen.left);

    // 첫번 째 컬럼의 첫번 째 셀
    Finder firstCell = find.byKey(rows.first.cells['headerL0']!.key);

    // 셀 선택
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // 첫번 째 셀 값 확인
    expect(stateManager!.currentCell!.value, 'headerL0 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 시킨 두번 째 컬럼(headerB1)의 첫번 째 셀 값 확인
    expect(stateManager!.currentCell!.value, 'headerB1 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 컬럼 두개 다음에 Body 의 첫번 째 컬럼의 값 확인
    expect(stateManager!.currentCell!.value, 'headerB0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 고정 컬럼 두번 째 셀 값 확인
    expect(stateManager!.currentCell!.value, 'headerB1 value 0');

    // 셀 우측 끝으로 이동해서 우측 고정 된 셀 값 확인
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 우측 끝 고정 컬럼 값 확인
    expect(stateManager!.currentCell!.value, 'headerR0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 우측 고정 컬럼 바로 전 컬럼인 Body 의 마지막 컬럼 셀 값 확인
    expect(stateManager!.currentCell!.value, 'headerB2 value 0');
  });

  testWidgets(
      'WHEN frozen one column on the right when there are no frozen columns in the grid.'
      'THEN showFrozenColumn changes to true and the column is moved to the right and should disappear from its original position.',
      (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoGridStateManager? stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
          ),
        ),
      ),
    );

    await tester.pump();

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0']!.key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // Check first cell value of first column
    expect(stateManager!.currentCell!.value, 'header0 value 0');

    // Check showFrozenColumn before freezing column.
    expect(stateManager!.showFrozenColumn, false);

    // Freeze the 3rd column
    stateManager!.toggleFrozenColumn(columns[2].key, PlutoColumnFrozen.right);

    // Await re-build by toggleFrozenColumn
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Check showFrozenColumn after freezing column.
    expect(stateManager!.showFrozenColumn, true);

    // Move current cell position to 3rd column (0 -> 1 -> 2)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager!.currentColumn!.title, isNot('header2'));
    expect(stateManager!.currentColumn!.title, 'header3');

    // Move current cell position to 10rd column (2 -> 9)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager!.currentColumn!.title, 'header2');
  });
}
