import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

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

        await tester.tap(find.text('header1 value 3'));

        stateManager!
            .toggleFrozenColumn(columns[1].key, PlutoColumnFrozen.left);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 의 columnIdx 가 0 이어야 한다.',
      (tester) async {
        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '좌측 키 이동 시 currentCellPosition 의 columnIdx 가 그대로 0 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '우측 키 이동 시 currentCellPosition 의 columnIdx 가 1 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '하단 키 이동 시 currentCellPosition 의 rowIdx 가 4 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 4);
      },
    );

    toLeftColumn1.test(
      '상단 키 이동 시 currentCellPosition 의 rowIdx 가 2 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 2);
      },
    );

    toLeftColumn1.test(
      '탭키 이동 시 currentCellPosition 의 columnIdx 가 1 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager!.currentCellPosition!.columnIdx, 1);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
      },
    );

    toLeftColumn1.test(
      '쉬프트 + 탭키 이동 시 currentCellPosition 의 columnIdx 가 그대로 0 이어야 한다.',
      (tester) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.currentCellPosition!.columnIdx, 0);
        expect(stateManager!.currentCellPosition!.rowIdx, 3);
      },
    );
  });

  group('고정 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

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

        await tester.tap(find.text('header3 value 5'));

        stateManager!
            .toggleFrozenColumn(columns[3].key, PlutoColumnFrozen.right);
      },
    );

    toLeftColumn1.test(
      'currentCellPosition 의 columnIdx 가 9 이어야 한다.',
      (tester) async {
        expect(stateManager!.currentCellPosition!.columnIdx, 9);
        expect(stateManager!.currentCellPosition!.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '좌측 키 이동 시 currentCellPosition 의 columnIdx 가 8 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        expect(stateManager!.currentCellPosition!.columnIdx, 8);
        expect(stateManager!.currentCellPosition!.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '우측 키 이동 시 currentCellPosition 의 columnIdx 가 그대로 9 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        expect(stateManager!.currentCellPosition!.columnIdx, 9);
        expect(stateManager!.currentCellPosition!.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '하단 키 이동 시 currentCellPosition 의 rowIdx 가 6 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

        expect(stateManager!.currentCellPosition!.columnIdx, 9);
        expect(stateManager!.currentCellPosition!.rowIdx, 6);
      },
    );

    toLeftColumn1.test(
      '상단 키 이동 시 currentCellPosition 의 rowIdx 가 4 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);

        expect(stateManager!.currentCellPosition!.columnIdx, 9);
        expect(stateManager!.currentCellPosition!.rowIdx, 4);
      },
    );

    toLeftColumn1.test(
      '탭키 이동 시 currentCellPosition 의 columnIdx 가 그대로 9 이어야 한다.',
      (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);

        expect(stateManager!.currentCellPosition!.columnIdx, 9);
        expect(stateManager!.currentCellPosition!.rowIdx, 5);
      },
    );

    toLeftColumn1.test(
      '쉬프트 + 탭키 이동 시 currentCellPosition 의 columnIdx 가 8 이어야 한다.',
      (tester) async {
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);

        expect(stateManager!.currentCellPosition!.columnIdx, 8);
        expect(stateManager!.currentCellPosition!.rowIdx, 5);
      },
    );
  });
}
