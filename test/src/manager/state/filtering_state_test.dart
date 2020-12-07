import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_on_change_listener.dart';

void main() {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  MockOnChangeListener listener;

  setUp(() {
    columns = [
      ...ColumnHelper.textColumn('column', count: 2, width: 150),
    ];

    rows = RowHelper.count(10, columns);

    stateManager = PlutoStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: null,
    );

    listener = MockOnChangeListener();

    stateManager.addListener(listener.onChangeVoidNoParamListener);
  });

  group('hasFilter', () {
    test(
      'when filter is not set, '
      'should be returned false.',
      () {
        expect(stateManager.hasFilter, isFalse);
      },
    );

    test(
      'when filter is set, '
      'should be returned true.',
      () {
        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        stateManager.setFilter(filter);

        expect(stateManager.hasFilter, isTrue);
      },
    );
  });

  group('setFilter', () {
    test(
      'should be changed to none of state of row.',
      () {
        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          stateManager.rows[i].setState(PlutoRowState.updated);
        }

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          expect(stateManager.rows[i].state, PlutoRowState.updated);
        }

        stateManager.setFilter(filter);

        for (var i = 0; i < stateManager.rows.length; i += 1) {
          expect(stateManager.rows[i].state, PlutoRowState.none);
        }
      },
    );

    test(
      'when filter is null, filterRows should be set to an empty List',
      () {
        expect(stateManager.filterRows.length, 0);

        stateManager.setFilterWithFilterRows([FilterHelper.createFilterRow()]);

        expect(stateManager.filterRows.length, 1);

        stateManager.setFilter(null);

        expect(stateManager.filterRows.length, 0);
      },
    );
  });

  group('isFilteredColumn', () {
    test(
      'when there is no filter, should be returned false.',
      () {
        var column = stateManager.columns.first;

        expect(stateManager.hasFilter, isFalse);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when filterRows is empty, should be returned false.',
      () {
        var column = stateManager.columns.first;

        expect(stateManager.filterRows.length, 0);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when filterRows is empty, should be returned false.',
      () {
        var column = stateManager.columns.first;

        var filter = FilterHelper.convertRowsToFilter(
          [FilterHelper.createFilterRow()],
          [],
        );

        stateManager.setFilter(filter);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 0);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );

    test(
      'when the column is filtered, should be returned true.',
      () {
        var column = stateManager.columns.first;

        stateManager.setFilterWithFilterRows(
            [FilterHelper.createFilterRow(columnField: column.field)]);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 1);

        expect(stateManager.isFilteredColumn(column), isTrue);
      },
    );

    test(
      'when the column is not filtered, should be returned false.',
      () {
        var column = stateManager.columns.first;

        stateManager.setFilterWithFilterRows([
          FilterHelper.createFilterRow(
            columnField: stateManager.columns.last.field,
          ),
        ]);

        expect(stateManager.hasFilter, isTrue);

        expect(stateManager.filterRows.length, 1);

        expect(stateManager.isFilteredColumn(column), isFalse);
      },
    );
  });
}
