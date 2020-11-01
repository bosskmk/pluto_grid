import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_pluto_scroll_controller.dart';

void main() {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoScrollController scrollController;

  PlutoStateManager stateManager;

  final withColumnAndRows =
      PlutoWidgetTestHelper('컬럼 10개와 행 10개 인 상태에서, ', (tester) async {
    columns = [
      ...ColumnHelper.textColumn('column', count: 10, width: 100),
    ];

    rows = RowHelper.count(10, columns);

    scrollController = MockPlutoScrollController();

    when(scrollController.verticalOffset).thenReturn(100);

    stateManager = PlutoStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scrollController,
    );

    stateManager.setLayout(BoxConstraints(maxWidth: 500, maxHeight: 500));
  });

  group('moveCurrentCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'MoveDirection 이 Up 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Up);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Down 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Down);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 null 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Right);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          MoveDirection.Right,
          force: true,
        );

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Left 면 왼쪽 끝으로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          MoveDirection.Left,
        );

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 면 오른쪽 끝으로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(rows.first.cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition.columnIdx, 3);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfColumns(
          MoveDirection.Right,
        );

        expect(stateManager.currentCellPosition.columnIdx, 9);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );
  });

  group('moveCurrentCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'MoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(MoveDirection.Left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellToEdgeOfRows(MoveDirection.Right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(MoveDirection.Down);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        stateManager.moveCurrentCellToEdgeOfRows(
          MoveDirection.Down,
          force: true,
        );

        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Up 이면 맨 위 Row 로 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition.columnIdx, 7);
        expect(stateManager.currentCellPosition.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          MoveDirection.Up,
        );

        expect(stateManager.currentCellPosition.columnIdx, 7);
        expect(stateManager.currentCellPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Down 이면 맨 아래 Row 로 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column7'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentCellPosition.columnIdx, 7);
        expect(stateManager.currentCellPosition.rowIdx, 4);

        stateManager.moveCurrentCellToEdgeOfRows(
          MoveDirection.Down,
        );

        expect(stateManager.currentCellPosition.columnIdx, 7);
        expect(stateManager.currentCellPosition.rowIdx, 9);
      },
    );
  });

  group('moveCurrentCellByRowIdx', () {
    withColumnAndRows.test(
      'MoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, MoveDirection.Left);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(0, MoveDirection.Right);

        expect(stateManager.currentCell, isNull);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0보다 작으면 0번 행으로 이동 되어야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(-1, MoveDirection.Down);

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 0);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 전체 행 인덱스보다 많으면 마지막 행으로 이동 되어야 한다.',
      (tester) async {
        stateManager.moveCurrentCellByRowIdx(11, MoveDirection.Down);

        expect(stateManager.currentCellPosition.rowIdx, 9);
        expect(stateManager.currentCellPosition.columnIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfColumns', () {
    withColumnAndRows.test(
      'MoveDirection 이 Up 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(MoveDirection.Up);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Down 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfColumns(MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(MoveDirection.Right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          MoveDirection.Right,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 9);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Left 면 현재 셀 부터 왼쪽 끝까지 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          MoveDirection.Left,
        );

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 0);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Left 이고 현재 선택 된 셀이 있다면 선택 된 셀이 왼쪽 끝으로 변경 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(columnIdx: 2, rowIdx: 0);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 2);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          MoveDirection.Left,
        );

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 0);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 면 현재 셀 부터 오른쪽 끝까지 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfColumns(
          MoveDirection.Right,
        );

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 9);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 이고 현재 선택 된 셀이 있다면 선택 된 셀이 오른쪽 끝으로 변경 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[0].cells['column3'], 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(columnIdx: 2, rowIdx: 0);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 2);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);

        stateManager.moveSelectingCellToEdgeOfColumns(
          MoveDirection.Right,
        );

        expect(stateManager.currentCellPosition.rowIdx, 0);
        expect(stateManager.currentCellPosition.columnIdx, 3);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 9);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );
  });

  group('moveSelectingCellToEdgeOfRows', () {
    withColumnAndRows.test(
      'MoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(MoveDirection.Left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellToEdgeOfRows(MoveDirection.Right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 면 셀이 이동 되지 않아야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'isEditing 이 true 라도 force 가 true 면 셀이 이동 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(true);

        expect(stateManager.isEditing, isTrue);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          MoveDirection.Down,
          force: true,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 0);
        expect(stateManager.currentSelectingPosition.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 없으면 셀 선택이 되지 않아야 한다.',
      (tester) async {
        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          MoveDirection.Down,
        );

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Down 이면 가장 아래 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          MoveDirection.Down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 0);
        expect(stateManager.currentSelectingPosition.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Up 이면 가장 위의 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.rows[4].cells['column3'], 4);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellToEdgeOfRows(
          MoveDirection.Up,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 3);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Down 이고 선택 된 셀이 있으면 컬럼은 유지하고 가장 아래로 이동 해야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        stateManager.setEditing(false);

        expect(stateManager.isEditing, isFalse);

        stateManager.setCurrentSelectingPosition(columnIdx: 3, rowIdx: 2);

        expect(stateManager.currentSelectingPosition.columnIdx, 3);
        expect(stateManager.currentSelectingPosition.rowIdx, 2);

        stateManager.moveSelectingCellToEdgeOfRows(
          MoveDirection.Down,
        );

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 3);
        expect(stateManager.currentSelectingPosition.rowIdx, 9);
      },
    );
  });

  group('moveSelectingCellByRowIdx', () {
    withColumnAndRows.test(
      'MoveDirection 이 Left 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, MoveDirection.Left);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'MoveDirection 이 Right 이면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        stateManager.moveSelectingCellByRowIdx(0, MoveDirection.Right);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'currentCell 이 없으면 셀이 선택 되지 않아야 한다.',
      (tester) async {
        expect(stateManager.currentCell, isNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(0, MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNull);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0 보다 작으면 0번 행이 선택 되어야 한다.',
          (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(-1, MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 3);
        expect(stateManager.currentSelectingPosition.rowIdx, 0);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 0 보다 크면 마지막 행이 선택 되어야 한다.',
          (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 3);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(11, MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 3);
        expect(stateManager.currentSelectingPosition.rowIdx, 9);
      },
    );

    withColumnAndRows.test(
      'rowIdx 가 3이면 3번 행의 셀이 선택 되어야 한다.',
      (tester) async {
        stateManager.setCurrentCell(stateManager.firstCell, 0);

        expect(stateManager.currentCell, isNotNull);

        expect(stateManager.currentSelectingPosition, isNull);

        stateManager.moveSelectingCellByRowIdx(3, MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 0);
        expect(stateManager.currentSelectingPosition.rowIdx, 3);
      },
    );

    withColumnAndRows.test(
      '선택 된 셀이 있으면 컬럼 위치가 유지되어야 한다.',
          (tester) async {
        stateManager.setCurrentCell(stateManager.rows[3].cells['column3'], 0);

        expect(stateManager.currentCell, isNotNull);

        stateManager.setCurrentSelectingPosition(columnIdx: 5, rowIdx: 3);

        expect(stateManager.currentSelectingPosition.columnIdx, 5);
        expect(stateManager.currentSelectingPosition.rowIdx, 3);

        stateManager.moveSelectingCellByRowIdx(6, MoveDirection.Down);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(stateManager.currentSelectingPosition.columnIdx, 5);
        expect(stateManager.currentSelectingPosition.rowIdx, 6);
      },
    );
  });
}
