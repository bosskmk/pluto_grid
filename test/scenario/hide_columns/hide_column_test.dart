import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void main() {
  group('숨김 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager stateManager;

    final withTenColumns = PlutoWidgetTestHelper(
      '10개의 컬럼을 생성',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Container(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    withTenColumns.test(
      'hideColumn 으로 header1 을 숨기면 header1 컬럼이 숨겨져야 한다.',
      (tester) async {
        var column = find.text('header1');

        expect(column, findsOneWidget);

        stateManager.hideColumn(columns[1].key, true);

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(column, findsNothing);
      },
    );

    withTenColumns.test(
      'showSetColumnsPopup 을 호출 하면 컬럼 설정 팝업이 호출 되어야 한다.',
      (tester) async {
        stateManager.showSetColumnsPopup(stateManager.gridFocusNode.context);

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        var columnTitleOfPopup = find.text(
          stateManager.configuration.localeText.setColumnsTitle,
        );

        expect(columnTitleOfPopup, findsOneWidget);
      },
    );
  });

  group('숨김 컬럼이 없는 상태에서', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager stateManager;

    final withTenColumns = PlutoWidgetTestHelper(
      '10개의 컬럼을 생성하고 0, 5번 컬럼을 숨김',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 10),
        ];

        rows = RowHelper.count(10, columns);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Container(
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                  },
                ),
              ),
            ),
          ),
        );

        stateManager.hideColumn(columns[0].key, true, notify: false);
        stateManager.hideColumn(columns[5].key, true);
      },
    );

    withTenColumns.test(
      'hideColumn 으로 header0 을 숨김 해제 하면 컬럼이 나타나야 한다.',
      (tester) async {
        var column = find.text('header0');

        expect(column, findsNothing);

        stateManager.hideColumn(
          stateManager.refColumns.originalList[0].key,
          false,
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        expect(column, findsOneWidget);
      },
    );
  });
}
