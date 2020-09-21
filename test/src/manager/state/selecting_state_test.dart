import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';

main() {
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

      stateManager.setLayout(
          BoxConstraints(maxHeight: 300, maxWidth: 50), 0, 0);

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

      stateManager.setLayout(
          BoxConstraints(maxHeight: 300, maxWidth: 50), 0, 0);

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

      stateManager.setLayout(
          BoxConstraints(maxHeight: 300, maxWidth: 50), 0, 0);

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

      stateManager.setLayout(
          BoxConstraints(maxHeight: 300, maxWidth: 50), 0, 0);

      stateManager.setSelectingMode(PlutoSelectingMode.Row);

      final currentCell = rows[3].cells['text2'];

      stateManager.setCurrentCell(currentCell, 3);

      // when
      final currentSelectingText = stateManager.currentSelectingText;

      // then
      expect(currentSelectingText, currentCell.value);
    });
  });
}
