import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/pluto_widget_test_helper.dart';
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
    expect(stateManager.showFixedColumn, false);

    // Fix the 3rd column
    stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Right);

    // Await re-build by toggleFixedColumn
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Check showFixedColumn after fixing column.
    expect(stateManager.showFixedColumn, true);

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

  group('applyColumnRowOnInit', () {
    testWidgets(
        'number column'
        'WHEN applyFormatOnInit value of Column is true(default value)'
        'THEN cell value of the column should be changed to format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 'not a number')}),
        PlutoRow(cells: {'header': PlutoCell(value: 12)}),
        PlutoRow(cells: {'header': PlutoCell(value: '12')}),
        PlutoRow(cells: {'header': PlutoCell(value: -10)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 12.12345)}),
      ];

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

      // then
      expect(stateManager.rows[0].cells['header'].value, 0);
      expect(stateManager.rows[1].cells['header'].value, 12);
      expect(stateManager.rows[2].cells['header'].value, 12);
      expect(stateManager.rows[3].cells['header'].value, -10);
      expect(stateManager.rows[4].cells['header'].value, 1234567);
      expect(stateManager.rows[5].cells['header'].value, 12);
    });

    testWidgets(
        'number column'
        'WHEN applyFormatOnInit value of Column is false'
        'THEN cell value of the column should not be changed to format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(applyFormatOnInit: false),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 'not a number')}),
        PlutoRow(cells: {'header': PlutoCell(value: 12)}),
        PlutoRow(cells: {'header': PlutoCell(value: '12')}),
        PlutoRow(cells: {'header': PlutoCell(value: -10)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 12.12345)}),
      ];

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

      // then
      expect(stateManager.rows[0].cells['header'].value, 'not a number');
      expect(stateManager.rows[1].cells['header'].value, 12);
      expect(stateManager.rows[2].cells['header'].value, '12');
      expect(stateManager.rows[3].cells['header'].value, -10);
      expect(stateManager.rows[4].cells['header'].value, 1234567);
      expect(stateManager.rows[5].cells['header'].value, 12.12345);
    });

    testWidgets(
        'number column'
        'WHEN format allows prime numbers'
        'THEN cell value should be displayed as a decimal number according to the number of digits in the format.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(format: '#,###.#####'),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 1234567)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.1234)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: 1234567.123456)}),
      ];

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

      // then
      expect(stateManager.rows[0].cells['header'].value, 1234567);
      expect(stateManager.rows[1].cells['header'].value, 1234567.1234);
      expect(stateManager.rows[2].cells['header'].value, 1234567.12345);
      expect(stateManager.rows[3].cells['header'].value, 1234567.12346);
    });

    testWidgets(
        'number column'
        'WHEN negative is false'
        'THEN negative numbers should not be displayed in the cell value.',
        (WidgetTester tester) async {
      // given
      final columns = [
        PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.number(negative: false),
        ),
      ];

      final rows = [
        PlutoRow(cells: {'header': PlutoCell(value: 12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: -12345)}),
        PlutoRow(cells: {'header': PlutoCell(value: 333.333)}),
        PlutoRow(cells: {'header': PlutoCell(value: -333.333)}),
        PlutoRow(cells: {'header': PlutoCell(value: 0)}),
        PlutoRow(cells: {'header': PlutoCell(value: -0)}),
      ];

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

      // then
      expect(stateManager.rows[0].cells['header'].value, 12345);
      expect(stateManager.rows[1].cells['header'].value, 0);
      expect(stateManager.rows[2].cells['header'].value, 333);
      expect(stateManager.rows[3].cells['header'].value, 0);
      expect(stateManager.rows[4].cells['header'].value, 0);
      expect(stateManager.rows[5].cells['header'].value, 0);
    });

    testWidgets(
        'WHEN Row does not have sortIdx'
        'THEN sortIdx must be set in Row', (WidgetTester tester) async {
      // given
      final columns = [
        ...ColumnHelper.textColumn('header', count: 1),
      ];
      final rows = [
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(cells: {'header0': PlutoCell(value: 'value')}),
      ];

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
                createHeader: (stateManager) => Text('grid header'),
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].sortIdx, 0);
      expect(stateManager.rows[1].sortIdx, 1);
      expect(stateManager.rows[2].sortIdx, 2);
      expect(stateManager.rows[3].sortIdx, 3);
      expect(stateManager.rows[4].sortIdx, 4);
    });

    testWidgets(
        'WHEN Row has sortIdx'
        'THEN sortIdx is not changed', (WidgetTester tester) async {
      // given
      final columns = [
        ...ColumnHelper.textColumn('header', count: 1),
      ];
      final rows = [
        PlutoRow(sortIdx: 5, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 6, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 7, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 8, cells: {'header0': PlutoCell(value: 'value')}),
        PlutoRow(sortIdx: 9, cells: {'header0': PlutoCell(value: 'value')}),
      ];

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
                createHeader: (stateManager) => Text('grid header'),
              ),
            ),
          ),
        ),
      );

      // then
      expect(stateManager.rows[0].sortIdx, 5);
      expect(stateManager.rows[1].sortIdx, 6);
      expect(stateManager.rows[2].sortIdx, 7);
      expect(stateManager.rows[3].sortIdx, 8);
      expect(stateManager.rows[4].sortIdx, 9);
    });
  });

  group('moveColumn', () {
    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '0번 컬럼을 2번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

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

      // when
      stateManager.moveColumn(columns[0].key, 250);

      // then
      expect(columns[0].title, 'body1');
      expect(columns[1].title, 'body2');
      expect(columns[2].title, 'body0');
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '9번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

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

      // when
      stateManager.moveColumn(columns[9].key, 50);

      // then
      expect(columns[0].title, 'body9');
      expect(columns[1].title, 'body0');
      expect(columns[2].title, 'body1');
      expect(columns[3].title, 'body2');
      expect(columns[4].title, 'body3');
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body5');
      expect(columns[7].title, 'body6');
      expect(columns[8].title, 'body7');
      expect(columns[9].title, 'body8');
    });

    testWidgets(
        '넓이가 충분하고 '
        '고정 컬럼이 없는 상태에서 '
        '3번 컬럼을 고정 왼쪽 토글 하고 '
        '5번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 500,
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
      stateManager.toggleFixedColumn(columns[3].key, PlutoColumnFixed.Left);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      stateManager.moveColumn(columns[5].key, 50);
      //
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 3번 컬럼을 토글하면 컬럼 위치는 바뀌지 않고 고정 컬럼으로 상태만 바뀜.
      // 그리고 5번 컬럼을 이동 시키면 고정 컬럼이 노출 되는 상태에서 3번 컬럼 앞으로 이동.
      // 0, 1, 2, 5, 3, 4, 6, 7, 8, 9 상태가 됨.

      // then
      expect(columns[0].title, 'body0');
      expect(columns[1].title, 'body1');
      expect(columns[2].title, 'body2');
      expect(columns[3].title, 'body5');
      expect(columns[3].fixed, PlutoColumnFixed.Left);
      expect(columns[4].title, 'body3');
      expect(columns[4].fixed, PlutoColumnFixed.Left);
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body6');
      expect(columns[7].title, 'body7');
      expect(columns[8].title, 'body8');
      expect(columns[9].title, 'body9');
    });

    testWidgets(
        '넓이가 충분하지 않고 '
        '고정 컬럼이 없는 상태에서 '
        '3번 컬럼을 고정 왼쪽 토글 하고 '
        '5번 컬럼을 0번 컬럼으로 이동.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 100),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager;

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              width: 50,
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

      stateManager.setLayout(BoxConstraints(maxWidth: 50, maxHeight: 300));

      // when
      stateManager.toggleFixedColumn(columns[3].key, PlutoColumnFixed.Left);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      stateManager.setLayout(BoxConstraints(maxWidth: 50, maxHeight: 300));

      stateManager.moveColumn(columns[5].key, 50);
      //
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 3번 컬럼을 토글하면 컬럼 위치는 바뀌지 않고 고정 컬럼으로 상태만 바뀜.
      // 그리고 5번 컬럼을 이동 시키면 넓이가 충분하지 않은 상태에서
      // 왼쪽 끝에는 0번 컬럼이 위치하게 되고, 5번 컬럼이 0번 컬럼 앞으로 이동.
      // 0번 컬럼이 고정 컬럼이 아니어서 5번도 고정 컬럼이 아니게 됨.

      // then
      expect(columns[0].title, 'body5');
      expect(columns[0].fixed, PlutoColumnFixed.None);
      expect(columns[1].title, 'body0');
      expect(columns[2].title, 'body1');
      expect(columns[3].title, 'body2');
      expect(columns[4].title, 'body3');
      expect(columns[4].fixed, PlutoColumnFixed.Left);
      expect(columns[5].title, 'body4');
      expect(columns[6].title, 'body6');
      expect(columns[7].title, 'body7');
      expect(columns[8].title, 'body8');
      expect(columns[9].title, 'body9');
    });

    group('Date column', () {
      testWidgets(
          '날짜 선택 팝업에서 위로 한칸 이동 시 '
          '일주일 이전 날짜가 선택 되어야 한다.', (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.dateColumn('date', count: 10, width: 100),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

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

        Finder firstCell = find.byKey(rows.first.cells['date0'].key);

        // 셀 선택
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        expect(stateManager.isEditing, false);

        // 수정 상태로 변경
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        // 수정 상태 확인
        expect(stateManager.isEditing, true);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 날짜 입력 팝업 호출
        await tester.tap(
            find.descendant(of: firstCell, matching: find.byType(TextField)));

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 현재 선택 된 날짜
        final DateTime currentDate =
            DateTime.parse(stateManager.currentCell.value);

        // 선택 된 날짜의 day 렌더링
        Finder popupCell = find.text(DateFormat('d').format(currentDate));
        expect(popupCell, findsOneWidget);

        // 팝업에서 한칸 위로 이동
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 일주일 전 날짜 선택
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 엔터키 입력 후 자동으로 아래 이동, 다시 원래 셀인 위로 이동.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        final DateTime selectedDate =
            DateTime.parse(stateManager.currentCell.value);

        expect(currentDate.add(Duration(days: -7)), selectedDate);
      });

      testWidgets(
          '날짜 선택 팝업에서 위로 여섯칸 이동 시 '
          '6주 이전 날짜가 선택 되어야 한다.', (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.dateColumn('date', count: 10, width: 100),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

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

        Finder firstCell = find.byKey(rows.first.cells['date0'].key);

        // 셀 선택
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        expect(stateManager.isEditing, false);

        // 수정 상태로 변경
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        // 수정 상태 확인
        expect(stateManager.isEditing, true);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 날짜 입력 팝업 호출
        await tester.tap(
            find.descendant(of: firstCell, matching: find.byType(TextField)));

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 현재 선택 된 날짜
        final DateTime currentDate =
            DateTime.parse(stateManager.currentCell.value);

        // 선택 된 날짜의 day 렌더링
        Finder popupCell = find.text(DateFormat('d').format(currentDate));
        expect(popupCell, findsOneWidget);

        // 팝업에서 여섯 칸 위로 이동
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 일주일 전 날짜 선택
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 엔터키 입력 후 자동으로 아래 이동, 다시 원래 셀인 위로 이동.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        final DateTime selectedDate =
            DateTime.parse(stateManager.currentCell.value);

        expect(currentDate.add(Duration(days: -(7 * 6))), selectedDate);
      });

      testWidgets(
          '날짜 선택 팝업에서 위로 10 칸 이동 시 '
          '10주 이전 날짜가 선택 되어야 한다.', (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.dateColumn('date', count: 10, width: 100),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

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

        Finder firstCell = find.byKey(rows.first.cells['date0'].key);

        // 셀 선택
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        expect(stateManager.isEditing, false);

        // 수정 상태로 변경
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        // 수정 상태 확인
        expect(stateManager.isEditing, true);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 날짜 입력 팝업 호출
        await tester.tap(
            find.descendant(of: firstCell, matching: find.byType(TextField)));

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 현재 선택 된 날짜
        final DateTime currentDate =
            DateTime.parse(stateManager.currentCell.value);

        // 선택 된 날짜의 day 렌더링
        Finder popupCell = find.text(DateFormat('d').format(currentDate));
        expect(popupCell, findsOneWidget);

        // 팝업에서 10 칸 위로 이동
        for (var i = 0; i < 10; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        }

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 일주일 전 날짜 선택
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 엔터키 입력 후 자동으로 아래 이동, 다시 원래 셀인 위로 이동.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        final DateTime selectedDate =
            DateTime.parse(stateManager.currentCell.value);

        expect(currentDate.add(Duration(days: -(7 * 10))), selectedDate);
      });

      testWidgets(
          '날짜 선택 팝업에서 아래로 10 칸 이동 시 '
          '10주 이후 날짜가 선택 되어야 한다.', (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.dateColumn('date', count: 10, width: 100),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

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

        Finder firstCell = find.byKey(rows.first.cells['date0'].key);

        // 셀 선택
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        expect(stateManager.isEditing, false);

        // 수정 상태로 변경
        await tester.tap(find.descendant(
            of: firstCell, matching: find.byType(GestureDetector)));

        // 수정 상태 확인
        expect(stateManager.isEditing, true);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 날짜 입력 팝업 호출
        await tester.tap(
            find.descendant(of: firstCell, matching: find.byType(TextField)));

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 현재 선택 된 날짜
        final DateTime currentDate =
            DateTime.parse(stateManager.currentCell.value);

        // 선택 된 날짜의 day 렌더링
        Finder popupCell = find.text(DateFormat('d').format(currentDate));
        expect(popupCell, findsOneWidget);

        // 팝업에서 10 칸 아래로 이동
        for (var i = 0; i < 10; i += 1) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        }

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 일주일 전 날짜 선택
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 엔터키 입력 후 자동으로 아래 이동, 다시 원래 셀인 위로 이동.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        await tester.pumpAndSettle(const Duration(seconds: 1));

        final DateTime selectedDate =
            DateTime.parse(stateManager.currentCell.value);

        expect(currentDate.add(Duration(days: 7 * 10)), selectedDate);
      });
    });
  });

  testWidgets('editing 상태에서 shift + 우측 방향키 입력 시 셀이 선택 되지 않아야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    expect(stateManager.isEditing, true);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태에서 shift + 방향키 입력 시 셀이 선택 되지 않아야 한다.
    expect(stateManager.currentSelectingPosition, null);
    // 이동도 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태에서 shift + 좌측 방향키 입력 시 셀이 선택 되지 않아야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    expect(stateManager.isEditing, true);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태에서 shift + 방향키 입력 시 셀이 선택 되지 않아야 한다.
    expect(stateManager.currentSelectingPosition, null);
    // 이동도 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태에서 shift + 위쪽 방향키 입력 시 셀이 선택 되지 않아야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    expect(stateManager.isEditing, true);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태에서 shift + 방향키 입력 시 셀이 선택 되지 않아야 한다.
    expect(stateManager.currentSelectingPosition, null);
    // 이동도 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태에서 shift + 아래쪽 방향키 입력 시 셀이 선택 되지 않아야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    expect(stateManager.isEditing, true);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태에서 shift + 방향키 입력 시 셀이 선택 되지 않아야 한다.
    expect(stateManager.currentSelectingPosition, null);
    // 이동도 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태가 아니면, shift + 우측 방향키 입력 시 셀이 선택 되어야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태가 아니면 shift + 방향키 입력 시 셀이 선택 되어야 한다.
    expect(stateManager.currentSelectingPosition.columnIdx, 3);
    expect(stateManager.currentSelectingPosition.rowIdx, 1);
    // 현재 선택 셀은 이동 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태가 아니면, shift + 좌측 방향키 입력 시 셀이 선택 되어야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태가 아니면 shift + 방향키 입력 시 셀이 선택 되어야 한다.
    expect(stateManager.currentSelectingPosition.columnIdx, 1);
    expect(stateManager.currentSelectingPosition.rowIdx, 1);
    // 현재 선택 셀은 이동 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태가 아니면, shift + 위쪽 방향키 입력 시 셀이 선택 되어야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태가 아니면 shift + 방향키 입력 시 셀이 선택 되어야 한다.
    expect(stateManager.currentSelectingPosition.columnIdx, 2);
    expect(stateManager.currentSelectingPosition.rowIdx, 0);
    // 현재 선택 셀은 이동 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  testWidgets('editing 상태가 아니면, shift + 아래쪽 방향키 입력 시 셀이 선택 되어야 한다.',
      (WidgetTester tester) async {
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

    // 1 번 컬럼의 1번 행의 셀 선택
    Finder currentCell = find.text('headerB1 value 1');

    await tester.tap(currentCell);

    expect(stateManager.currentCell.value, 'headerB1 value 1');

    // editing true
    expect(stateManager.isEditing, false);

    // 쉬프트 + 우측 키 입력
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

    expect(stateManager.currentCell.value, 'headerB1 value 1');
    // editing 상태가 아니면 shift + 방향키 입력 시 셀이 선택 되어야 한다.
    expect(stateManager.currentSelectingPosition.columnIdx, 2);
    expect(stateManager.currentSelectingPosition.rowIdx, 2);
    // 현재 선택 셀은 이동 되지 않아야 한다.
    expect(stateManager.currentCellPosition.columnIdx, 2);
    expect(stateManager.currentCellPosition.rowIdx, 1);
  });

  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final toLeftColumn1 = PlutoWidgetTestHelper(
      '1번 컬럼의 셀 하나를 선택하고 1번 컬럼을 왼쪽 고정',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header1 value 3'));

        stateManager.toggleFixedColumn(columns[1].key, PlutoColumnFixed.Left);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 의 columnIdx 가 0 이어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '좌측 키 이동 시 currentCellPosition 의 columnIdx 가 그대로 0 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '우측 키 이동 시 currentCellPosition 의 columnIdx 가 1 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager.currentCellPosition.columnIdx, 1);
        expect(stateManager.currentCellPosition.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '하단 키 이동 시 currentCellPosition 의 rowIdx 가 4 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 4);
      },
    );

    toLeftColumn1.test(
      '상단 키 이동 시 currentCellPosition 의 rowIdx 가 2 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 2);
      },
    );

    toLeftColumn1.test(
      '탭키 이동 시 currentCellPosition 의 columnIdx 가 1 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager.currentCellPosition.columnIdx, 1);
        expect(stateManager.currentCellPosition.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '쉬프트 + 탭키 이동 시 currentCellPosition 의 columnIdx 가 그대로 0 이어야 한다.',
      (tester) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 3);
      },
    );
  });

  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final toLeftColumn1 = PlutoWidgetTestHelper(
      '3번 컬럼의 셀 하나를 선택하고 3번 컬럼을 오른쪽 고정',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header3 value 5'));

        stateManager.toggleFixedColumn(columns[3].key, PlutoColumnFixed.Right);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 의 columnIdx 가 9 이어야 한다.',
      (tester) async {
        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '좌측 키 이동 시 currentCellPosition 의 columnIdx 가 8 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager.currentCellPosition.columnIdx, 8);
        expect(stateManager.currentCellPosition.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '우측 키 이동 시 currentCellPosition 의 columnIdx 가 그대로 9 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '하단 키 이동 시 currentCellPosition 의 rowIdx 가 6 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 6);
      },
    );

    toLeftColumn1.test(
      '상단 키 이동 시 currentCellPosition 의 rowIdx 가 4 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 4);
      },
    );

    toLeftColumn1.test(
      '탭키 이동 시 currentCellPosition 의 columnIdx 가 그대로 9 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '쉬프트 + 탭키 이동 시 currentCellPosition 의 columnIdx 가 8 이어야 한다.',
      (tester) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);

        expect(stateManager.currentCellPosition.columnIdx, 8);
        expect(stateManager.currentCellPosition.rowIdx, 5);
      },
    );
  });

  group('Enter 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '3, 3 셀이 선택 된 상태에서',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header3 value 3'));
      },
    );

    withTheCellSelected.test(
      'editing 상태에서 shift + enter 입력 시 위 셀로 이동 되어야 한다.',
      (tester) async {
        stateManager.setEditing(true);
        expect(stateManager.currentCell.value, 'header3 value 3');
        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 3);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager.currentCell.value, 'header3 value 2');
        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 2);
      },
    );

    withTheCellSelected.test(
      'editing 상태에서 enter 입력 시 아래 셀로 이동 되어야 한다.',
          (tester) async {
        stateManager.setEditing(true);
        expect(stateManager.currentCell.value, 'header3 value 3');
        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 3);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        expect(stateManager.currentCell.value, 'header3 value 4');
        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 4);
      },
    );
  });

  group('ESC 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '0, 0 셀이 선택 된 상태에서',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header0 value 0'));
      },
    );

    withTheCellSelected.test(
      '그리드가 Select 모드 라면 onSelected 이벤트가 발생 되어야 한다.',
      (tester) async {
        stateManager.setGridMode(PlutoMode.Select);

        stateManager.setOnSelected((event) {
          expect(event.row, null);
          expect(event.cell, null);
        });

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      },
    );

    withTheCellSelected.test(
      '그리드가 Select 모드가 아니고, '
      'editing true 상태라면 editing 이 false 가 되어야 한다.',
      (tester) async {
        expect(stateManager.mode.isSelect, isFalse);

        stateManager.setEditing(true);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager.isEditing, false);
      },
    );

    withTheCellSelected.test(
      '그리드가 Select 모드가 아니고,'
      'Cell 값이 변경 된 상태라면 원래 셀 값으로 되돌려 져야 한다.',
      (tester) async {
        expect(stateManager.mode.isSelect, isFalse);

        expect(stateManager.currentCell.value, 'header0 value 0');

        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);

        expect(stateManager.currentCell.value, 'a');

        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        expect(stateManager.currentCell.value, isNot('a'));

        expect(stateManager.currentCell.value, 'header0 value 0');
      },
    );
  });

  group('F2 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '0, 0 셀이 선택 된 상태에서',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header0 value 0'));
      },
    );

    withTheCellSelected.test(
      'F2 키 입력 시 편집 상태가 아니면 편집 상태로 변경 되어야 한다.',
      (tester) async {
        expect(stateManager.isEditing, false);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(stateManager.isEditing, true);
      },
    );
  });

  group('Ctrl + A 키 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoStateManager stateManager;

    final withTheCellSelected = PlutoWidgetTestHelper(
      '0, 0 셀이 선택 된 상태에서',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

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

        await tester.tap(find.text('header0 value 0'));
      },
    );

    withTheCellSelected.test(
      'editing 상태가 아니면 Ctrl + A 키 입력 시 전체 셀이 선택 되어야 한다.',
      (tester) async {
        expect(stateManager.selectingMode.isSquare, true);
        expect(stateManager.isEditing, false);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 0);

        expect(stateManager.currentSelectingPosition.rowIdx, 9);
        expect(stateManager.currentSelectingPosition.columnIdx, 9);
      },
    );

    withTheCellSelected.test(
      'editing 상태가 맞다면 Ctrl + A 키 입력 시 셀 선택이 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.selectingMode.isSquare, true);
        stateManager.setEditing(true);
        expect(stateManager.isEditing, true);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 0);

        expect(stateManager.currentSelectingPosition, null);
      },
    );
  });
}
