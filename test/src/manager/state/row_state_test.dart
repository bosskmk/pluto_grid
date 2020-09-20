import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';

main() {
  group('currentRowIdx', () {
    testWidgets('currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
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
      int currentRowIdx = stateManager.currentRowIdx;

      // when
      expect(currentRowIdx, null);
    });

    testWidgets('currentCell 이 선택 된 경우 선택 된 셀의 rowIdx 를 리턴해야 한다.',
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
      String selectColumnField = 'right1';
      stateManager.setCurrentCell(rows[7].cells[selectColumnField], 7);

      int currentRowIdx = stateManager.currentRowIdx;

      // when
      expect(currentRowIdx, 7);
    });
  });

  group('currentRow', () {
    testWidgets('currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
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
      PlutoRow currentRow = stateManager.currentRow;

      // when
      expect(currentRow, null);
    });

    testWidgets('currentCell 이 선택 된 경우 선택 된 row 를 리턴해야 한다.',
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
      String selectColumnField = 'left1';
      stateManager.setCurrentCell(rows[3].cells[selectColumnField], 3);

      PlutoRow currentRow = stateManager.currentRow;

      // when
      expect(currentRow, isNot(null));
      expect(currentRow.key, rows[3].key);
    });
  });

  group('setSortIdxOfRows', () {
    testWidgets(
        'The sortIdx value of rows should be increased from 0 and filled.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final rowsFilledSortIdx = stateManager.setSortIdxOfRows(rows);

      // then
      expect(rowsFilledSortIdx[0].sortIdx, 0);
      expect(rowsFilledSortIdx[1].sortIdx, 1);
      expect(rowsFilledSortIdx[2].sortIdx, 2);
      expect(rowsFilledSortIdx[3].sortIdx, 3);
      expect(rowsFilledSortIdx[4].sortIdx, 4);
    });

    testWidgets(
        'The sortIdx value of rows should be decrease from 4 and filled.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final rowsFilledSortIdx = stateManager.setSortIdxOfRows(
        rows,
        increase: false,
        start: 4,
      );

      // then
      expect(rowsFilledSortIdx[0].sortIdx, 4);
      expect(rowsFilledSortIdx[1].sortIdx, 3);
      expect(rowsFilledSortIdx[2].sortIdx, 2);
      expect(rowsFilledSortIdx[3].sortIdx, 1);
      expect(rowsFilledSortIdx[4].sortIdx, 0);
    });
  });

  group('prependRows', () {
    testWidgets('A new row must be added before the existing row.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      PlutoRow newRow = RowHelper.count(1, columns).first;

      // when
      stateManager.prependRows([newRow]);

      // then
      expect(stateManager.rows[0].key, newRow.key);
      expect(stateManager.rows.length, 6);
    });

    testWidgets('Row is not added when passing an empty array.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.prependRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });
  });

  group('appendRows', () {
    testWidgets('New rows must be added after the existing row.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      List<PlutoRow> newRows = RowHelper.count(2, columns);

      // when
      stateManager.appendRows(newRows);

      // then
      expect(stateManager.rows[5].key, newRows[0].key);
      expect(stateManager.rows[6].key, newRows[1].key);
      expect(stateManager.rows.length, 7);
    });

    testWidgets('Row is not added when passing an empty array.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.appendRows([]);

      // then
      expect(stateManager.rows.length, 5);
    });
  });

  group('removeCurrentRow', () {
    testWidgets('Should not be removed rows, when currentRow is null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed currentRow, when currentRow is not null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final currentRowKey = rows[3].key;

      stateManager.setCurrentCell(rows[3].cells['text1'], 3);

      stateManager.removeCurrentRow();

      // then
      expect(stateManager.rows.length, 4);
      expect(stateManager.rows[0].key, isNot(currentRowKey));
      expect(stateManager.rows[1].key, isNot(currentRowKey));
      expect(stateManager.rows[2].key, isNot(currentRowKey));
      expect(stateManager.rows[3].key, isNot(currentRowKey));
    });
  });

  group('removeRows', () {
    testWidgets('Should not be removed rows, when rows parameter is null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.removeRows(null);

      // then
      expect(stateManager.rows.length, 5);
    });

    testWidgets('Should be removed rows, when rows parameter is not null.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final deleteRows = [rows[0], rows[1]];

      stateManager.removeRows(deleteRows);

      // then
      final deleteRowKeys =
          deleteRows.map((e) => e.key).toList(growable: false);

      expect(stateManager.rows.length, 3);
      expect(deleteRowKeys.contains(stateManager.rows[0].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[1].key), false);
      expect(deleteRowKeys.contains(stateManager.rows[2].key), false);
    });

    testWidgets('Should be removed all rows',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final deleteRows = [...rows];

      stateManager.removeRows(deleteRows);

      // then
      expect(stateManager.rows.length, 0);
    });
  });

  group('updateCurrentRowIdx', () {
    testWidgets('When cellKey is passed, the _currentRowIdx value must be set.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      stateManager.updateCurrentRowIdx(rows[3].cells['text1'].key);

      // then
      expect(stateManager.currentRowIdx, 3);
    });
  });
}
