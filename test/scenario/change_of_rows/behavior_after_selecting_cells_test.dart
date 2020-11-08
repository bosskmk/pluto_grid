import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

/**
 * 셀 선택 상태 이후의 동작 테스트
 */
void main() {
  final PlutoSelectingMode selectingMode = PlutoSelectingMode.Square;

  PlutoStateManager stateManager;

  final buildRowsWithSelectingCells = ({
    int countRows = 10,
    int columnIdx = 0,
    int rowIdx = 0,
    int columnIdxToSelect = 1,
    int rowIdxToSelect = 0,
  }) {
    // given
    final columns = ColumnHelper.textColumn('header', count: 10);
    final rows = RowHelper.count(countRows, columns);

    return PlutoWidgetTestHelper(
      'build with selecting cells.',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Container(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoOnLoadedEvent event) {
                    stateManager = event.stateManager;
                    stateManager.setSelectingMode(selectingMode);

                    stateManager.setCurrentCell(
                      stateManager.rows[rowIdx].cells['header$columnIdx'],
                      rowIdx,
                    );

                    stateManager.setCurrentSelectingPosition(
                      cellPosition: PlutoCellPosition(
                        columnIdx: columnIdxToSelect,
                        rowIdx: rowIdxToSelect,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(stateManager.currentCell, isNotNull);
        expect(stateManager.currentCellPosition.columnIdx, columnIdx);
        expect(stateManager.currentCellPosition.rowIdx, rowIdx);

        expect(stateManager.currentSelectingPosition, isNotNull);
        expect(
            stateManager.currentSelectingPosition.columnIdx, columnIdxToSelect);
        expect(stateManager.currentSelectingPosition.rowIdx, rowIdxToSelect);
      },
    );
  };

  group('(0, 1) 부터 (1, 2) 셀 선택', () {
    const COUNT_TOTAL_ROWS = 10;
    const CURRENT_COLUMN_IDX = 0;
    const CURRENT_ROW_IDX = 1;
    const COLUMN_IDX_TO_SELECT = 1;
    const ROW_IDX_TO_SELECT = 2;

    final selectCells = () {
      return buildRowsWithSelectingCells(
        countRows: COUNT_TOTAL_ROWS,
        columnIdx: CURRENT_COLUMN_IDX,
        rowIdx: CURRENT_ROW_IDX,
        columnIdxToSelect: COLUMN_IDX_TO_SELECT,
        rowIdxToSelect: ROW_IDX_TO_SELECT,
      );
    };

    selectCells().test(
      '0번 행에 새로운 행을 추가하면, '
      '선택 된 셀이 (0, 2), (1, 3) 로 변경 되어야 한다.',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition.columnIdx, CURRENT_COLUMN_IDX);
        expect(stateManager.currentCellPosition.rowIdx, CURRENT_ROW_IDX);

        expect(stateManager.currentSelectingPosition.columnIdx,
            COLUMN_IDX_TO_SELECT);
        expect(stateManager.currentSelectingPosition.rowIdx, ROW_IDX_TO_SELECT);

        final rowToInsert = stateManager.getNewRow();

        stateManager.insertRows(0, [rowToInsert]);

        // after
        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 2);

        expect(stateManager.currentSelectingPosition.columnIdx, 1);
        expect(stateManager.currentSelectingPosition.rowIdx, 3);
      },
    );

    selectCells().test(
      '0번 행을 삭제 하면, '
      '선택 된 셀이 (0, 0), (1, 1) 로 변경 되어야 한다.',
      (tester) async {
        // before
        expect(stateManager.currentCellPosition.columnIdx, CURRENT_COLUMN_IDX);
        expect(stateManager.currentCellPosition.rowIdx, CURRENT_ROW_IDX);

        expect(stateManager.currentSelectingPosition.columnIdx,
            COLUMN_IDX_TO_SELECT);
        expect(stateManager.currentSelectingPosition.rowIdx, ROW_IDX_TO_SELECT);

        final rowToDelete = stateManager.rows.first;

        stateManager.removeRows([rowToDelete]);

        // after
        expect(stateManager.currentCellPosition.columnIdx, 0);
        expect(stateManager.currentCellPosition.rowIdx, 0);

        expect(stateManager.currentSelectingPosition.columnIdx, 1);
        expect(stateManager.currentSelectingPosition.rowIdx, 1);
      },
    );
  });
}
