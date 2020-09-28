import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';

void main() {
  group('currentSelectingText', () {
    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'The values of the selected rows should be returned.',
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

      stateManager.setLayout(BoxConstraints(maxHeight: 300, maxWidth: 50));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          ClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(transformedSelectingText[0][0], rows[1].cells['text0'].value);
      expect(transformedSelectingText[0][1], rows[1].cells['text1'].value);
      expect(transformedSelectingText[0][2], rows[1].cells['text2'].value);

      expect(transformedSelectingText[1][0], rows[2].cells['text0'].value);
      expect(transformedSelectingText[1][1], rows[2].cells['text1'].value);
      expect(transformedSelectingText[1][2], rows[2].cells['text2'].value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'The value of the row selected with toggleSelectingRow should be returned.',
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

      stateManager.setLayout(BoxConstraints(maxHeight: 300, maxWidth: 50));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      stateManager.toggleSelectingRow(1);
      stateManager.toggleSelectingRow(3);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          ClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(transformedSelectingText[0][0], rows[1].cells['text0'].value);
      expect(transformedSelectingText[0][1], rows[1].cells['text1'].value);
      expect(transformedSelectingText[0][2], rows[1].cells['text2'].value);

      expect(
          transformedSelectingText[1][0], isNot(rows[2].cells['text0'].value));
      expect(
          transformedSelectingText[1][1], isNot(rows[2].cells['text1'].value));
      expect(
          transformedSelectingText[1][2], isNot(rows[2].cells['text2'].value));

      expect(transformedSelectingText[1][0], rows[3].cells['text0'].value);
      expect(transformedSelectingText[1][1], rows[3].cells['text1'].value);
      expect(transformedSelectingText[1][2], rows[3].cells['text2'].value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length == 0'
        'currentCellPosition == null'
        'currentSelectingPosition == null'
        'THEN'
        'The values of the selected rows should be returned as an empty value.',
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

      stateManager.setLayout(BoxConstraints(maxHeight: 300, maxWidth: 50));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText, '');
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length == 0'
        'currentCellPosition != null'
        'currentSelectingPosition == null'
        'THEN'
        'The values of the selected rows should be returned as an empty value.',
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

      stateManager.setLayout(BoxConstraints(maxHeight: 300, maxWidth: 50));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      final currentCell = rows[3].cells['text2'];

      stateManager.setCurrentCell(currentCell, 3);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText, currentCell.value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has fixed column In a state of sufficient width'
        'THEN'
        'The values of the selected rows should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          fixed: PlutoColumnFixed.Left,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          fixed: PlutoColumnFixed.Right,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // 최소 넓이(고정 컬럼 2개 + PlutoDefaultSettings.bodyMinWidth) 충분
      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 600));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          ClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFixedColumn, true);

      expect(transformedSelectingText[0][0], rows[1].cells['left0'].value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0'].value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1'].value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2'].value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0'].value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0'].value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0'].value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1'].value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2'].value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0'].value);
    });

    testWidgets(
        'WHEN'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'has fixed column In a narrow area'
        'THEN'
        'The values of the selected rows should be returned.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          width: 150,
          fixed: PlutoColumnFixed.Left,
        ),
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          width: 150,
          fixed: PlutoColumnFixed.Right,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(5, columns);

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      // 최소 넓이(고정 컬럼 2개 + PlutoDefaultSettings.bodyMinWidth) 부족
      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      stateManager.setCurrentSelectingRowsByRange(1, 2);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      final transformedSelectingText =
          ClipboardTransformation.stringToList(currentSelectingText);

      // then
      expect(stateManager.showFixedColumn, false);

      expect(transformedSelectingText[0][0], rows[1].cells['left0'].value);
      expect(transformedSelectingText[0][1], rows[1].cells['text0'].value);
      expect(transformedSelectingText[0][2], rows[1].cells['text1'].value);
      expect(transformedSelectingText[0][3], rows[1].cells['text2'].value);
      expect(transformedSelectingText[0][4], rows[1].cells['right0'].value);

      expect(transformedSelectingText[1][0], rows[2].cells['left0'].value);
      expect(transformedSelectingText[1][1], rows[2].cells['text0'].value);
      expect(transformedSelectingText[1][2], rows[2].cells['text1'].value);
      expect(transformedSelectingText[1][3], rows[2].cells['text2'].value);
      expect(transformedSelectingText[1][4], rows[2].cells['right0'].value);
    });
  });

  group('setSelecting', () {
    testWidgets(
      'selectingMode == None 면 isSelecting 가 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoStateManager stateManager = PlutoStateManager(
          columns: columns,
          rows: null,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setSelectingMode(PlutoSelectingMode.None);

        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Square'
      'currentCell == null 이면'
      'isSelecting 이 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoStateManager stateManager = PlutoStateManager(
          columns: columns,
          rows: null,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setSelectingMode(PlutoSelectingMode.Square);

        expect(stateManager.currentCell, null);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell == null 이면'
      'isSelecting 이 변경 되지 않아야 한다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        PlutoStateManager stateManager = PlutoStateManager(
          columns: columns,
          rows: null,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setSelectingMode(PlutoSelectingMode.Row);

        expect(stateManager.currentCell, null);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, false);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell != null 이면'
      'isSelecting 이 변경 된다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoStateManager stateManager = PlutoStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setSelectingMode(PlutoSelectingMode.Row);
        stateManager.setCurrentCell(rows.first.cells['text1'], 0);

        expect(stateManager.currentCell, isNot(null));
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, true);
      },
    );

    testWidgets(
      'selectingMode == Row'
      'currentCell != null 이면'
      'isSelecting 이 변경 된다.'
      'isEditing 이 true 면 isEditing 이 false 로 변경 된다.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = [
          ...ColumnHelper.textColumn('text', count: 3, width: 150),
        ];

        List<PlutoRow> rows = RowHelper.count(10, columns);

        PlutoStateManager stateManager = PlutoStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
        );

        stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

        stateManager.setSelectingMode(PlutoSelectingMode.Row);
        stateManager.setCurrentCell(rows.first.cells['text1'], 0);
        stateManager.setEditing(true);

        expect(stateManager.currentCell, isNot(null));
        expect(stateManager.isEditing, true);
        expect(stateManager.isSelecting, false);
        // when
        stateManager.setSelecting(true);

        // then
        expect(stateManager.isSelecting, true);
        expect(stateManager.isEditing, false);
      },
    );
  });

  group('setAllCurrentSelecting', () {
    testWidgets(
        'WHEN '
        'rows == null '
        'THEN'
        '', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets(
        'WHEN '
        'rows.length < 1 '
        'THEN'
        '', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('text', count: 3, width: 150),
      ];

      PlutoStateManager stateManager = PlutoStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });

    testWidgets(
        'WHEN '
        'selectingMode.Square '
        'rows.length > 0 '
        'THEN '
        '현재 셀은 처음 셀로, 선택 된 셀 위치는 마지막 셀 위치로 설정 되어야 한다.',
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setSelectingMode(PlutoSelectingMode.Square);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, rows.first.cells['text0']);
      expect(stateManager.currentSelectingPosition.rowIdx, 4);
      expect(stateManager.currentSelectingPosition.columnIdx, 2);
    });

    testWidgets(
        'WHEN '
        'selectingMode.Row '
        'rows.length > 0 '
        'THEN '
        '선택 된 Row 의 개수가 맞아야 한다.', (WidgetTester tester) async {
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell.value, rows.first.cells['text0'].value);
      expect(stateManager.currentSelectingPosition.columnIdx, 2);
      expect(stateManager.currentSelectingPosition.rowIdx, 4);
      expect(stateManager.currentSelectingRows.length, 5);
    });

    testWidgets(
        'WHEN'
        'selectingMode.None'
        'rows.length > 0'
        'THEN'
        '아무것도 선택되지 않아야 한다.', (WidgetTester tester) async {
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setSelectingMode(PlutoSelectingMode.None);

      // when
      stateManager.setAllCurrentSelecting();

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.currentSelectingPosition, null);
      expect(stateManager.currentSelectingRows.length, 0);
    });
  });

  group('isSelectedCell', () {
    testWidgets(
        'WHEN'
        '아무것도 선택되지 않음.'
        'THEN'
        '모든 셀이 false.', (WidgetTester tester) async {
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      // when
      expect(stateManager.selectingMode.isSquare, isTrue);
      
      // then
      for (var i = 0; i < rows.length; i += 1) {
        columns.forEach((column) {
          expect(
              stateManager.isSelectedCell(
                  rows[i].cells[column.field], column, i),
              false);
        });
      }
    });

    testWidgets(
        'WHEN '
        '현재 셀이 0번 Row, 0번 Column 이고 '
        '0번 Row, 1번 Column 이 선택 됨. '
        'THEN '
        '해당 셀이 true.', (WidgetTester tester) async {
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setCurrentCell(stateManager.firstCell, 0);

      stateManager.setCurrentSelectingPosition(columnIdx: 1, rowIdx: 0);

      // when
      expect(stateManager.selectingMode.isSquare, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        columns.forEach((column) {
          if (i == 0 && (column.field == 'text0' || column.field == 'text1')) {
            expect(
                stateManager.isSelectedCell(
                    rows[i].cells[column.field], column, i),
                true);
          } else {
            expect(
                stateManager.isSelectedCell(
                    rows[i].cells[column.field], column, i),
                false);
          }
        });
      }
    });

    testWidgets(
        'WHEN '
        '현재 셀이 1번 Row, 1번 Column 이고 '
        '3번 Row, 2번 Column 이 선택 됨. '
        'THEN '
        '해당 셀이 true.', (WidgetTester tester) async {
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

      stateManager.setLayout(BoxConstraints(maxHeight: 500, maxWidth: 400));

      stateManager.setCurrentCell(rows[1].cells['text1'], 1);

      stateManager.setCurrentSelectingPosition(rowIdx: 3, columnIdx: 2);

      // when
      expect(stateManager.selectingMode.isSquare, isTrue);

      // then
      for (var i = 0; i < rows.length; i += 1) {
        columns.forEach((column) {
          if ((i >= 1 && i <= 3) &&
              (column.field == 'text1' || column.field == 'text2')) {
            expect(
                stateManager.isSelectedCell(
                    rows[i].cells[column.field], column, i),
                true);
          } else {
            expect(
                stateManager.isSelectedCell(
                    rows[i].cells[column.field], column, i),
                false);
          }
        });
      }
    });
  });
}
