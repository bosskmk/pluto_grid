import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';

main() {
  group('currentCellPosition', () {
    testWidgets(
        'currentCellPosition - currentCell 이 선택되지 않은 경우 null 을 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, fixed: PlutoColumnFixed.Left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, fixed: PlutoColumnFixed.Right),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      PlutoCellPosition currentCellPosition = stateManager.currentCellPosition;

      // when
      expect(currentCellPosition, null);
    });

    testWidgets('currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, fixed: PlutoColumnFixed.Left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, fixed: PlutoColumnFixed.Right),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.setLayout(
          BoxConstraints(maxWidth: 1900, maxHeight: 500), 0, 0);

      String selectColumnField = 'body1';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoCellPosition currentCellPosition = stateManager.currentCellPosition;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      expect(currentCellPosition.columnIdx, 4);
    });

    testWidgets(
        'currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.'
        '컬럼 고정 상태가 바뀌고, body 최소 넓이가 작은 경우', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Left);
      stateManager.toggleFixedColumn(columns[4].key, PlutoColumnFixed.Right);

      stateManager.setLayout(
          BoxConstraints(maxWidth: 300, maxHeight: 500), 0, 0);

      String selectColumnField = 'body2';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoCellPosition currentCellPosition = stateManager.currentCellPosition;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      // 3번 째 컬럼을 왼쪽으로 옴겨 첫번 째 컬럼이 되었지만 그리드 최소 넓이가 300으로
      // 충분하지 않아 고정 컬럼이 풀리고 원래 순서대로 노출 된다.
      expect(currentCellPosition.columnIdx, 2);
    });

    testWidgets(
        'currentCellPosition - currentCell 이 선택된 경우 선택 된 위치를 리턴해야 한다.'
        '컬럼 고정 상태가 바뀌고, body 최소 넓이가 충분한 경우', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 10, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.toggleFixedColumn(columns[2].key, PlutoColumnFixed.Left);
      stateManager.toggleFixedColumn(columns[4].key, PlutoColumnFixed.Right);

      stateManager.setLayout(
          BoxConstraints(maxWidth: 1900, maxHeight: 500), 0, 0);

      String selectColumnField = 'body2';
      stateManager.setCurrentCell(rows[5].cells[selectColumnField], 5);

      PlutoCellPosition currentCellPosition = stateManager.currentCellPosition;

      // when
      expect(currentCellPosition, isNot(null));
      expect(currentCellPosition.rowIdx, 5);
      // 3번 째 컬럼을 왼쪽으로 고정 후 넓이가 충분하여 첫번 째 컬럼이 된다.
      expect(currentCellPosition.columnIdx, 0);
    });
  });

  group('filteredCellValue', () {
    testWidgets(
        'select column'
        'WHEN newValue is not contained in select items'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'four';

      const String oldValue = 'one';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.select(['one', 'two', 'three']),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'select column'
        'WHEN newValue is contained in select items'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'four';

      const String oldValue = 'one';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.select(['one', 'two', 'three', 'four']),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, newValue);
    });

    testWidgets(
        'date column'
        'WHEN newValue is not parsed to DateTime'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'not date';

      const String oldValue = '2020-01-01';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.date(),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'date column'
        'WHEN newValue is parsed to DateTime'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = '2020-12-12';

      const String oldValue = '2020-01-01';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.date(),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, newValue);
    });

    testWidgets(
        'time column'
        'WHEN newValue is not in 00:00 format'
        'THEN the return value should be oldValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = 'not 00:00';

      const String oldValue = '23:59';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.time(),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, oldValue);
    });

    testWidgets(
        'time column'
        'WHEN newValue is in the 00:00 format'
        'THEN the return value should be newValue.',
        (WidgetTester tester) async {
      // given
      const String newValue = '12:59';

      const String oldValue = '23:59';

      PlutoColumn column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.time(),
      );

      PlutoStateManager stateManager = PlutoStateManager(
        columns: [column],
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final String filteredValue = stateManager.filteredCellValue(
        column: column,
        newValue: newValue,
        oldValue: oldValue,
      );

      // then
      expect(filteredValue, newValue);
    });
  });
}
