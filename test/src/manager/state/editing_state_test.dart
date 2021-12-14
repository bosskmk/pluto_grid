import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_on_change_listener.dart';

void main() {
  group('pasteCellValue', () {
    testWidgets(
        'WHEN'
        'currentCellPosition != null'
        'selectingMode.Row'
        'currentSelectingRows.length > 0'
        'THEN'
        'Values should be filled in the selected rows by _pasteCellValueIntoSelectingRows.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = PlutoGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      final currentCell = rows[2].cells['body2'];

      stateManager.setCurrentCell(currentCell, 2);

      stateManager.setCurrentSelectingRowsByRange(2, 4);

      // when
      stateManager.pasteCellValue([
        ['changed']
      ]);

      // then
      [0, 1, 5, 6, 7, 8, 9].forEach((rowIdx) {
        ['left', 'body', 'right'].forEach((column) {
          [0, 1, 2].forEach((idx) {
            expect(rows[rowIdx].cells['$column$idx']!.value,
                '$column$idx value $rowIdx');
            expect(rows[rowIdx].cells['$column$idx']!.value, isNot('changed'));
          });
        });
      });

      [2, 3, 4].forEach((rowIdx) {
        ['left', 'body', 'right'].forEach((column) {
          [0, 1, 2].forEach((idx) {
            expect(rows[rowIdx].cells['$column$idx']!.value, 'changed');
          });
        });
      });
    });

    testWidgets(
        'WHEN'
        'currentCellPosition != null'
        'selectingMode.Row'
        'currentSelectingRows.length < 1'
        '_currentSelectingPosition == null'
        'THEN'
        'Values should be filled in the selected rows by _pasteCellValueInOrder.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = PlutoGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.row);

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      final currentCell = rows[2].cells['body2'];

      stateManager.setCurrentCell(currentCell, 2);

      // when
      stateManager.pasteCellValue([
        ['changed1-1', 'changed1-2'],
        ['changed2-1', 'changed2-2'],
      ]);

      // then
      [0, 1, 4, 5, 6, 7, 8, 9].forEach((rowIdx) {
        ['left', 'body', 'right'].forEach((column) {
          [0, 1, 2].forEach((idx) {
            expect(rows[rowIdx].cells['$column$idx']!.value,
                '$column$idx value $rowIdx');
          });
        });
      });

      expect(rows[2].cells['left0']!.value, 'left0 value 2');
      expect(rows[2].cells['left1']!.value, 'left1 value 2');
      expect(rows[2].cells['left2']!.value, 'left2 value 2');

      expect(rows[2].cells['body0']!.value, 'body0 value 2');
      expect(rows[2].cells['body1']!.value, 'body1 value 2');
      expect(rows[2].cells['body2']!.value, 'changed1-1');

      expect(rows[2].cells['right0']!.value, 'changed1-2');
      expect(rows[2].cells['right1']!.value, 'right1 value 2');
      expect(rows[2].cells['right2']!.value, 'right2 value 2');

      expect(rows[3].cells['left0']!.value, 'left0 value 3');
      expect(rows[3].cells['left1']!.value, 'left1 value 3');
      expect(rows[3].cells['left2']!.value, 'left2 value 3');

      expect(rows[3].cells['body0']!.value, 'body0 value 3');
      expect(rows[3].cells['body1']!.value, 'body1 value 3');
      expect(rows[3].cells['body2']!.value, 'changed2-1');

      expect(rows[3].cells['right0']!.value, 'changed2-2');
      expect(rows[3].cells['right1']!.value, 'right1 value 3');
      expect(rows[3].cells['right2']!.value, 'right2 value 3');
    });

    testWidgets(
        'WHEN'
        'currentCellPosition != null'
        'selectingMode.Square'
        'currentSelectingRows.length < 1'
        '_currentSelectingPosition != null'
        'THEN'
        'Values should be filled in the selected rows by _pasteCellValueInOrder.',
        (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = PlutoGridStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: null,
      );

      stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

      stateManager
          .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

      final currentCell = rows[2].cells['body2'];

      stateManager.setCurrentCell(currentCell, 2);

      stateManager.setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: 6,
          rowIdx: 4,
        ),
      );

      // when
      stateManager.pasteCellValue([
        ['changed1-1', 'changed1-2'],
        ['changed2-1', 'changed2-2'],
      ]);

      // then
      [0, 1, 5, 6, 7, 8, 9].forEach((rowIdx) {
        ['left', 'body', 'right'].forEach((column) {
          [0, 1, 2].forEach((idx) {
            expect(rows[rowIdx].cells['$column$idx']!.value,
                '$column$idx value $rowIdx');
          });
        });
      });

      expect(rows[2].cells['left0']!.value, 'left0 value 2');
      expect(rows[2].cells['left1']!.value, 'left1 value 2');
      expect(rows[2].cells['left2']!.value, 'left2 value 2');

      expect(rows[2].cells['body0']!.value, 'body0 value 2');
      expect(rows[2].cells['body1']!.value, 'body1 value 2');
      expect(rows[2].cells['body2']!.value, 'changed1-1');

      expect(rows[2].cells['right0']!.value, 'changed1-2');
      expect(rows[2].cells['right1']!.value, 'right1 value 2');
      expect(rows[2].cells['right2']!.value, 'right2 value 2');

      expect(rows[3].cells['left0']!.value, 'left0 value 3');
      expect(rows[3].cells['left1']!.value, 'left1 value 3');
      expect(rows[3].cells['left2']!.value, 'left2 value 3');

      expect(rows[3].cells['body0']!.value, 'body0 value 3');
      expect(rows[3].cells['body1']!.value, 'body1 value 3');
      expect(rows[3].cells['body2']!.value, 'changed2-1');

      expect(rows[3].cells['right0']!.value, 'changed2-2');
      expect(rows[3].cells['right1']!.value, 'right1 value 3');
      expect(rows[3].cells['right2']!.value, 'right2 value 3');

      expect(rows[4].cells['left0']!.value, 'left0 value 4');
      expect(rows[4].cells['left1']!.value, 'left1 value 4');
      expect(rows[4].cells['left2']!.value, 'left2 value 4');

      expect(rows[4].cells['body0']!.value, 'body0 value 4');
      expect(rows[4].cells['body1']!.value, 'body1 value 4');
      expect(rows[4].cells['body2']!.value, 'changed1-1');

      expect(rows[4].cells['right0']!.value, 'changed1-2');
      expect(rows[4].cells['right1']!.value, 'right1 value 4');
      expect(rows[4].cells['right2']!.value, 'right2 value 4');
    });
  });

  group('setEditing', () {
    MockOnChangeListener? mock;
    List<PlutoColumn> columns;
    List<PlutoRow> rows;
    late PlutoGridStateManager stateManager;

    late Function({
      PlutoGridMode? mode,
      bool? enableEditingMode,
      bool? setCurrentCell,
      bool? setIsEditing,
    }) buildState;

    setUp(() {
      buildState = ({
        mode = PlutoGridMode.normal,
        enableEditingMode = true,
        setCurrentCell = false,
        setIsEditing = false,
      }) {
        mock = MockOnChangeListener();

        columns = [
          PlutoColumn(
            title: 'column',
            field: 'column',
            type: PlutoColumnType.text(),
            enableEditingMode: enableEditingMode,
          ),
        ];

        rows = RowHelper.count(10, columns);

        stateManager = PlutoGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: mode,
        );

        stateManager.addListener(mock!.onChangeVoidNoParamListener);

        stateManager
            .setLayout(const BoxConstraints(maxHeight: 300, maxWidth: 50));

        if (setCurrentCell!) {
          stateManager.setCurrentCell(rows.first.cells['column'], 0);
        }

        if (setIsEditing!) {
          stateManager.setEditing(true);
        }

        clearInteractions(mock);
      };
    });

    test(
      'PlutoMode = select, '
      'enableEditingMode = true, '
      'setCurrentCell = true, '
      'setIsEditing = false, '
      'notifyListener 가 호출 되지 않아야 한다.',
      () {
        // given
        buildState(
          mode: PlutoGridMode.select,
          enableEditingMode: true,
          setCurrentCell: true,
          setIsEditing: false,
        );

        // when
        stateManager.setEditing(true);

        // then
        verifyNever(mock!.onChangeVoidNoParamListener());
      },
    );

    test(
      'PlutoMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = true, '
      'setIsEditing = false, '
      'notifyListener 가 호출 되어야 한다.',
      () {
        // given
        buildState(
          mode: PlutoGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: true,
          setIsEditing: false,
        );

        // when
        stateManager.setEditing(true);

        // then
        verify(mock!.onChangeVoidNoParamListener()).called(1);
      },
    );

    test(
      'PlutoMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = false, '
      'setIsEditing = false, '
      'notifyListener 가 호출 되지 않아야 한다.',
      () {
        // given
        buildState(
          mode: PlutoGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: false,
          setIsEditing: false,
        );

        // when
        stateManager.setEditing(true);

        // then
        verifyNever(mock!.onChangeVoidNoParamListener());
      },
    );

    test(
      'PlutoMode = normal, '
      'enableEditingMode = true, '
      'setCurrentCell = true, '
      'setIsEditing = true, '
      'notifyListener 가 호출 되지 않아야 한다.',
      () {
        // given
        buildState(
          mode: PlutoGridMode.normal,
          enableEditingMode: true,
          setCurrentCell: true,
          setIsEditing: true,
        );

        // when
        stateManager.setEditing(true);

        // then
        verifyNever(mock!.onChangeVoidNoParamListener());
      },
    );
  });

  group('changeCellValue', () {
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('column', count: 3, width: 150),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoBaseCell Function(PlutoGridStateManager stateManager) getCellWidget =
        (PlutoGridStateManager stateManager) {
      return PlutoBaseCell(
        stateManager: stateManager,
        cell: rows.first.cells['column0']!,
        column: columns.first,
        rowIdx: 0,
        row: rows.first,
      );
    };

    test(
      'force 가 false(기본값) 일 때, canNotChangeCellValue 가 true 면'
      'onChanged 콜백이 호출 되지 않아야 한다.',
      () {
        final mock = MockOnChangeListener();

        PlutoGridStateManager stateManager = PlutoGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: PlutoGridMode.select,
          onChangedEventCallback: mock.onChangeOneParamListener,
        );

        final columnField = 'column0';

        final rowIdx = 0;

        final column = columns.first;

        rows.first.cells[columnField]!
            .updateContext(getCellWidget(stateManager));

        final bool canNotChangeCellValue = stateManager.canNotChangeCellValue(
          column: column,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(canNotChangeCellValue, isTrue);

        stateManager.changeCellValue(
          rows[rowIdx].cells[columnField]!,
          'DEF',
          // force: false,
        );

        verifyNever(mock.onChangeOneParamListener(any));
      },
    );

    test(
      'force 가 true 일 때, canNotChangeCellValue 가 true 라도'
      'onChanged 콜백이 호출 되어야 한다.',
      () {
        final mock = MockOnChangeListener();

        PlutoGridStateManager stateManager = PlutoGridStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: null,
          mode: PlutoGridMode.select,
          onChangedEventCallback: mock.onChangeOneParamListener,
        );

        final columnField = 'column0';

        final rowIdx = 0;

        final column = columns.first;

        rows.first.cells[columnField]!
            .updateContext(getCellWidget(stateManager));

        final bool canNotChangeCellValue = stateManager.canNotChangeCellValue(
          column: column,
          newValue: 'abc',
          oldValue: 'ABC',
        );

        expect(canNotChangeCellValue, isTrue);

        stateManager.changeCellValue(
          rows[rowIdx].cells[columnField]!,
          'DEF',
          force: true,
        );

        verify(mock.onChangeOneParamListener(any)).called(1);
      },
    );
  });
}
