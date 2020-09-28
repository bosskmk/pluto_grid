import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';

void main() {
  group('속성 값 테스트.', () {
    PlutoStateManager stateManager;

    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    final makeFixedColumnByMaxWidth = (String description, double maxWidth) {
      return PlutoWidgetTestHelper(
        '고정 컬럼이 있고 $description',
        (tester) async {
          columns = [
            ...ColumnHelper.textColumn(
              'left',
              count: 1,
              fixed: PlutoColumnFixed.Left,
              width: 150,
            ),
            ...ColumnHelper.textColumn(
              'body',
              count: 3,
              width: 150,
            ),
            ...ColumnHelper.textColumn(
              'right',
              count: 1,
              fixed: PlutoColumnFixed.Right,
              width: 150,
            ),
          ];

          rows = RowHelper.count(10, columns);

          stateManager = PlutoStateManager(
            columns: columns,
            rows: rows,
            gridFocusNode: null,
            scroll: null,
          );

          stateManager
              .setLayout(BoxConstraints(maxWidth: maxWidth, maxHeight: 500));
          stateManager.setGridGlobalOffset(Offset.zero);
        },
      );
    };

    final hasFixedColumnAndWidthEnough = makeFixedColumnByMaxWidth(
      '넓이가 충분한 경우',
      600,
    );

    hasFixedColumnAndWidthEnough.test(
      'bodyLeftOffset 값은 왼쪽 고정 컬럼 넓이 + 1 이어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyLeftOffset,
          stateManager.leftFixedColumnsWidth + 1,
        );
      },
    );

    hasFixedColumnAndWidthEnough.test(
      'bodyRightOffset 값은 우측 고정 컬럼 넓이 + 1 이어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyRightOffset,
          stateManager.rightFixedColumnsWidth + 1,
        );
      },
    );

    hasFixedColumnAndWidthEnough.test(
      'bodyLeftScrollOffset 값에 왼쪽 고정 컬럼 넓이가 포함 되어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyLeftScrollOffset,
          stateManager.gridGlobalOffset.dx +
              PlutoDefaultSettings.gridPadding +
              PlutoDefaultSettings.gridBorderWidth +
              stateManager.leftFixedColumnsWidth +
              PlutoDefaultSettings.offsetScrollingFromEdge,
        );
      },
    );

    hasFixedColumnAndWidthEnough.test(
      'bodyRightScrollOffset 값에 우측 고정 컬럼 넓이가 포함 되어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyRightScrollOffset,
          (stateManager.gridGlobalOffset.dx + stateManager.maxWidth) -
              stateManager.rightFixedColumnsWidth -
              PlutoDefaultSettings.offsetScrollingFromEdge,
        );
      },
    );

    final hasFixedColumnAndWidthNotEnough = makeFixedColumnByMaxWidth(
      '넓이가 부족한 경우',
      450,
    );

    hasFixedColumnAndWidthNotEnough.test(
      'bodyLeftOffset 값은 0 이어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyLeftOffset,
          0,
        );
      },
    );

    hasFixedColumnAndWidthNotEnough.test(
      'bodyRightOffset 값은 0 이어야 한다.',
      (tester) async {
        expect(
          stateManager.bodyRightOffset,
          0,
        );
      },
    );

    hasFixedColumnAndWidthNotEnough.test(
      'bodyLeftScrollOffset 값에 왼쪽 고정 컬럼 넓이가 포함 되지 않아야 한다.',
      (tester) async {
        expect(
          stateManager.bodyLeftScrollOffset,
          stateManager.gridGlobalOffset.dx +
              PlutoDefaultSettings.gridPadding +
              PlutoDefaultSettings.gridBorderWidth +
              // stateManager.leftFixedColumnsWidth +
              PlutoDefaultSettings.offsetScrollingFromEdge,
        );
      },
    );

    hasFixedColumnAndWidthNotEnough.test(
      'bodyRightScrollOffset 값에 우측 고정 컬럼 넓이가 포함 되지 않아야 한다.',
      (tester) async {
        expect(
          stateManager.bodyRightScrollOffset,
          (stateManager.gridGlobalOffset.dx + stateManager.maxWidth) -
              // stateManager.rightFixedColumnsWidth -
              PlutoDefaultSettings.offsetScrollingFromEdge,
        );
      },
    );
  });
}
