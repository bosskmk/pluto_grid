import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets('cell 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );

    // then
    final cell1 = find.text('header0 value 0');
    expect(cell1, findsOneWidget);

    final cell2 = find.text('header0 value 1');
    expect(cell2, findsOneWidget);

    final cell3 = find.text('header0 value 2');
    expect(cell3, findsOneWidget);
  });

  testWidgets('header 탭 후 정렬 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
            ),
          ),
        ),
      ),
    );

    Finder headerInkWell = find.descendant(
        of: find.byKey(columns.first.key), matching: find.byType(InkWell));

    // then
    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header0'].value, 'header0 value 0');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header0'].value, 'header0 value 2');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 0');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header0'].value, 'header0 value 0');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');
  });

  testWidgets('셀 값 변경 후 헤더를 탭하면 변경 된 값에 맞게 정렬 되어야 한다.',
      (WidgetTester tester) async {
    // given
    final columns = ColumnHelper.textColumn('header');
    final rows = RowHelper.count(3, columns);

    PlutoStateManager stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // 셀 선택
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    expect(stateManager.isEditing, false);

    // 수정 상태로 변경
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // 수정 상태 확인
    expect(stateManager.isEditing, true);

    // TODO : 셀 값 변경 (1) 안되서 (2) 강제로
    // (1)
    // await tester.pump(Duration(milliseconds:800));
    //
    // await tester.enterText(
    //     find.descendant(of: firstCell, matching: find.byType(TextField)),
    //     'cell value4');
    // (2)
    stateManager.changeCellValue(
        stateManager.currentCell.key, 'header0 value 4');

    // 다음 행으로 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');

    Finder headerInkWell = find.descendant(
        of: find.byKey(columns.first.key), matching: find.byType(InkWell));

    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header0'].value, 'header0 value 1');
    expect(rows[1].cells['header0'].value, 'header0 value 2');
    expect(rows[2].cells['header0'].value, 'header0 value 4');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 2');
    expect(rows[2].cells['header0'].value, 'header0 value 1');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header0'].value, 'header0 value 4');
    expect(rows[1].cells['header0'].value, 'header0 value 1');
    expect(rows[2].cells['header0'].value, 'header0 value 2');
  });

  testWidgets(
      '0,4번 컬림이 고정 된 상태에서'
      '2번 컬럼 고정 후 방향키 이동시 정상적으로 이동 되어야 한다.', (WidgetTester tester) async {
    // given
    final columns = [
      ColumnHelper.textColumn('headerL', fixed: PlutoColumnFixed.Left).first,
      ...ColumnHelper.textColumn('headerB', count: 3),
      ColumnHelper.textColumn('headerR', fixed: PlutoColumnFixed.Right).first,
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // 세번 째 컬럼 왼쪽 고정
    stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Left);

    // 첫번 째 컬럼의 첫번 째 셀
    Finder firstCell = find.byKey(rows.first.cells['headerL0'].key);

    // 셀 선택
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // 첫번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerL0 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 시킨 두번 째 컬럼(headerB1)의 첫번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB1 value 0');

    // 셀 우측 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 왼쪽 고정 컬럼 두개 다음에 Body 의 첫번 째 컬럼의 값 확인
    expect(stateManager.currentCell.value, 'headerB0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 고정 컬럼 두번 째 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB1 value 0');

    // 셀 우측 끝으로 이동해서 우측 고정 된 셀 값 확인
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // 우측 끝 고정 컬럼 값 확인
    expect(stateManager.currentCell.value, 'headerR0 value 0');

    // 셀 다시 왼쪽 이동
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

    // 우측 고정 컬럼 바로 전 컬럼인 Body 의 마지막 컬럼 셀 값 확인
    expect(stateManager.currentCell.value, 'headerB2 value 0');
  });

  testWidgets(
      'WHEN Fixed one column on the right when there are no fixed columns in the grid.'
      'THEN showFixedColumn changes to true and the column is moved to the right and should disappear from its original position.',
      (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    // Check first cell value of first column
    expect(stateManager.currentCell.value, 'header0 value 0');

    // Check showFixedColumn before fixing column.
    expect(stateManager.layout.showFixedColumn, false);

    // Fix the 3rd column
    stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Right);

    // Await re-build by toggleFixedColumn
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Check showFixedColumn after fixing column.
    expect(stateManager.layout.showFixedColumn, true);

    // Move current cell position to 3rd column (0 -> 1 -> 2)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager.currentColumn.title, isNot('header2'));
    expect(stateManager.currentColumn.title, 'header3');

    // Move current cell position to 10rd column (2 -> 9)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

    // Check currentColumn
    expect(stateManager.currentColumn.title, 'header2');
  });

  testWidgets(
      'WHEN selecting a specific cell without grid header'
      'THEN That cell should be selected.', (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    Offset selectedCellOffset =
        tester.getCenter(find.byKey(rows[7].cells['header5'].key));

    stateManager.setCurrentSelectingPositionWithOffset(selectedCellOffset);

    // then
    expect(stateManager.currentSelectingPosition.rowIdx, 7);
    expect(stateManager.currentSelectingPosition.columnIdx, 5);
  });

  testWidgets(
      'WHEN selecting a specific cell with grid header'
      'THEN That cell should be selected.', (WidgetTester tester) async {
    // given
    final columns = [
      ...ColumnHelper.textColumn('header', count: 10),
    ];
    final rows = RowHelper.count(10, columns);

    PlutoStateManager stateManager;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
              createHeader: (stateManager) => Text('grid header'),
            ),
          ),
        ),
      ),
    );

    // when
    // first cell of first column
    Finder firstCell = find.byKey(rows.first.cells['header0'].key);

    // select first cell
    await tester.tap(
        find.descendant(of: firstCell, matching: find.byType(GestureDetector)));

    Offset selectedCellOffset =
        tester.getCenter(find.byKey(rows[5].cells['header3'].key));

    stateManager.setCurrentSelectingPositionWithOffset(selectedCellOffset);

    // then
    expect(stateManager.currentSelectingPosition.rowIdx, 5);
    expect(stateManager.currentSelectingPosition.columnIdx, 3);
  });
}
