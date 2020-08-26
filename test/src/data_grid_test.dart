import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  PlutoColumn column;
  List<PlutoRow> rows;

  setUp(() {
    column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    rows = [
      PlutoRow(
        cells: {'header': PlutoCell(value: 'cell value1')},
      ),
      PlutoRow(
        cells: {'header': PlutoCell(value: 'cell value2')},
      ),
      PlutoRow(
        cells: {'header': PlutoCell(value: 'cell value3')},
      ),
    ];
  });

  testWidgets('cell 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: [column],
              rows: rows,
            ),
          ),
        ),
      ),
    );

    // then
    final cell1 = find.text('cell value1');
    expect(cell1, findsOneWidget);

    final cell2 = find.text('cell value2');
    expect(cell2, findsOneWidget);

    final cell3 = find.text('cell value3');
    expect(cell3, findsOneWidget);
  });

  testWidgets('header 탭 후 정렬 되어야 한다.', (WidgetTester tester) async {
    // given
    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: [column],
              rows: rows,
            ),
          ),
        ),
      ),
    );

    Finder headerInkWell = find.descendant(
        of: find.byKey(column.key), matching: find.byType(InkWell));

    // then
    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header'].value, 'cell value1');
    expect(rows[1].cells['header'].value, 'cell value2');
    expect(rows[2].cells['header'].value, 'cell value3');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header'].value, 'cell value3');
    expect(rows[1].cells['header'].value, 'cell value2');
    expect(rows[2].cells['header'].value, 'cell value1');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header'].value, 'cell value1');
    expect(rows[1].cells['header'].value, 'cell value2');
    expect(rows[2].cells['header'].value, 'cell value3');
  });

  testWidgets('셀 값 변경 후 헤더를 탭하면 변경 된 값에 맞게 정렬 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoStateManager stateManager;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoGrid(
              columns: [column],
              rows: rows,
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
              },
            ),
          ),
        ),
      ),
    );

    Finder firstCell = find.byKey(rows.first.cells['header'].key);

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
    stateManager.changeCellValue(stateManager.currentCell.key, 'cell value4');

    // 다음 행으로 이동
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);

    expect(rows[0].cells['header'].value, 'cell value4');
    expect(rows[1].cells['header'].value, 'cell value2');
    expect(rows[2].cells['header'].value, 'cell value3');

    Finder headerInkWell = find.descendant(
        of: find.byKey(column.key), matching: find.byType(InkWell));

    await tester.tap(headerInkWell);
    // Ascending
    expect(rows[0].cells['header'].value, 'cell value2');
    expect(rows[1].cells['header'].value, 'cell value3');
    expect(rows[2].cells['header'].value, 'cell value4');

    await tester.tap(headerInkWell);
    // Descending
    expect(rows[0].cells['header'].value, 'cell value4');
    expect(rows[1].cells['header'].value, 'cell value3');
    expect(rows[2].cells['header'].value, 'cell value2');

    await tester.tap(headerInkWell);
    // Original
    expect(rows[0].cells['header'].value, 'cell value4');
    expect(rows[1].cells['header'].value, 'cell value2');
    expect(rows[2].cells['header'].value, 'cell value3');
  });
}
