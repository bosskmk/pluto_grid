import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/mock_build_context.dart';
import '../../mock/mock_on_change_listener.dart';
import '../../mock/mock_pluto_state_manager.dart';

void main() {
  group('createFilterRow', () {
    test(
      'When called without arguments,'
      'Should be returned a row filled with default values.',
      () {
        var row = FilterHelper.createFilterRow();

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn].value,
          FilterHelper.filterFieldAllColumns,
        );

        expect(
          row.cells[FilterHelper.filterFieldType].value,
          PlutoFilterType.contains,
        );

        expect(
          row.cells[FilterHelper.filterFieldValue].value,
          '',
        );
      },
    );

    test(
      'When called with arguments,'
      'Should be returned a row filled with arguments.',
      () {
        var row = FilterHelper.createFilterRow(
          columnField: 'filterColumnField',
          filterType: PlutoFilterType.endsWith,
          filterValue: 'abc',
        );

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn].value,
          'filterColumnField',
        );

        expect(
          row.cells[FilterHelper.filterFieldType].value,
          PlutoFilterType.endsWith,
        );

        expect(
          row.cells[FilterHelper.filterFieldValue].value,
          'abc',
        );
      },
    );
  });

  group('convertRowsToFilter', () {
    test(
      'When called with empty rows, '
      'Should be returned null.',
      () {
        expect(FilterHelper.convertRowsToFilter([], []), isNull);
      },
    );

    group('with rows.', () {
      PlutoRow row;

      setUp(() {
        row = PlutoRow(
          cells: {
            'column1': PlutoCell(value: 'column1 value'),
            'column2': PlutoCell(value: 'column2 value'),
            'column3': PlutoCell(value: 'column3 value'),
          },
        );
      });

      test(
        'filterFieldColumn : All, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'true',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumnFields = ['column1', 'column2', 'column3'];

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumnFields,
            )(row),
            isTrue,
          );
        },
      );

      test(
        'filterFieldColumn : column2, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column2',
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumnFields = ['column1', 'column2', 'column3'];

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumnFields,
            )(row),
            isFalse,
          );
        },
      );

      test(
        'filterFieldColumn : column1, '
        'filterFieldType : StartsWith, '
        'filterFieldValue : column1, '
        'true',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterType: PlutoFilterType.startsWith,
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumnFields = ['column1', 'column2', 'column3'];

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumnFields,
            )(row),
            isTrue,
          );
        },
      );

      test(
        'filterFieldColumn : All, '
        'filterFieldType : StartsWith, '
        'filterFieldValue : column1, '
        'enabledFilterColumnFields : [column3]'
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              filterType: PlutoFilterType.startsWith,
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumnFields = ['column3'];

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumnFields,
            )(row),
            isFalse,
          );
        },
      );
    });
  });

  group('isFilteredColumn', () {
    test(
      'filterRows : null, empty, '
      'Should be returned false.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            null,
          ),
          isFalse,
        );

        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [],
          ),
          isFalse,
        );
      },
    );

    test(
      'filterRows : [All columns], '
      'Should be returned true.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow()],
          ),
          isTrue,
        );
      },
    );

    test(
      'filterRows : [column], '
      'Should be returned true.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow(columnField: 'column')],
          ),
          isTrue,
        );
      },
    );

    test(
      'filterRows : [non_exists_column], '
      'Should be returned false.',
      () {
        expect(
          FilterHelper.isFilteredColumn(
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
            [FilterHelper.createFilterRow(columnField: 'non_exists_column')],
          ),
          isFalse,
        );
      },
    );
  });

  group('compareByFilterType', () {
    Function makeCompareFunction;

    setUp(() {
      makeCompareFunction = (PlutoFilterType filterType) {
        return (dynamic a, dynamic b) {
          return FilterHelper.compareByFilterType(filterType, a, b);
        };
      };
    });

    group('startsWith', () {
      Function compare;

      setUp(() {
        compare = makeCompareFunction(PlutoFilterType.startsWith);
      });

      test('apple startsWith ap', () {
        expect(compare('apple', 'ap'), isTrue);
      });

      test('apple is not startsWith banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('endsWith', () {
      Function compare;

      setUp(() {
        compare = makeCompareFunction(PlutoFilterType.endsWith);
      });

      test('apple endsWith le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not endsWith app', () {
        expect(compare('apple', 'app'), isFalse);
      });
    });

    group('contains', () {
      Function compare;

      setUp(() {
        compare = makeCompareFunction(PlutoFilterType.contains);
      });

      test('apple contains le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not contains banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('equals', () {
      Function compare;

      setUp(() {
        compare = makeCompareFunction(PlutoFilterType.equals);
      });

      test('apple equals apple', () {
        expect(compare('apple', 'apple'), isTrue);
      });

      test('apple is not equals banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });
  });

  group('FilterPopupState', () {
    test(
      'context should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: null,
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: ColumnHelper.textColumn('column'),
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'configuration should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: null,
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: ColumnHelper.textColumn('column'),
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'handleAddNewFilter should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: null,
              handleApplyFilter: (_) {},
              columns: ColumnHelper.textColumn('column'),
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'handleApplyFilter should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: null,
              columns: ColumnHelper.textColumn('column'),
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'columns should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: null,
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'columns should not be empty.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: [],
              filterRows: [],
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'filterRows should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: [],
              filterRows: null,
              focusFirstFilterValue: false,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'focusFirstFilterValue should not be null.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: PlutoConfiguration(),
              handleAddNewFilter: (_) {},
              handleApplyFilter: (_) {},
              columns: [],
              filterRows: [],
              focusFirstFilterValue: null,
            );
          },
          throwsA(isA<AssertionError>()),
        );
      },
    );

    group('onLoaded', () {
      test(
        'should be called setSelectingMode, addListener.',
        () {
          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: PlutoConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: ColumnHelper.textColumn('column'),
            filterRows: [],
            focusFirstFilterValue: false,
          );

          var stateManager = MockPlutoStateManager();

          filterPopupState.onLoaded(
            PlutoOnLoadedEvent(stateManager: stateManager),
          );

          verify(
            stateManager.setSelectingMode(PlutoSelectingMode.row),
          ).called(1);

          verify(
            stateManager.addListener(filterPopupState.stateListener),
          ).called(1);
        },
      );

      test(
        'if focusFirstFilterValue is true and stateManager has rows, '
        'then setKeepFocus, setCurrentCell and setEditing should be called.',
        () {
          var columns = ColumnHelper.textColumn('column');
          var rows = RowHelper.count(1, columns);

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: PlutoConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: columns,
            filterRows: [],
            focusFirstFilterValue: true,
          );

          var stateManager = MockPlutoStateManager();

          when(stateManager.rows).thenReturn(rows);

          filterPopupState.onLoaded(
            PlutoOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setKeepFocus(true)).called(1);

          verify(stateManager.setCurrentCell(
            rows.first.cells[FilterHelper.filterFieldValue],
            0,
            notify: false,
          )).called(1);

          verify(stateManager.setEditing(true)).called(1);
        },
      );
    });

    test('onChanged', () {
      var mock = MockOnChangeListener();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: PlutoConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: mock.onChangeOneParamListener,
        columns: ColumnHelper.textColumn('column'),
        filterRows: [],
        focusFirstFilterValue: true,
      );

      filterPopupState.onChanged(PlutoOnChangedEvent());

      verify(mock.onChangeOneParamListener(any)).called(1);
    });

    test('onSelected', () {
      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: PlutoConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: ColumnHelper.textColumn('column'),
        filterRows: [],
        focusFirstFilterValue: false,
      );

      var stateManager = MockPlutoStateManager();

      filterPopupState.onLoaded(
        PlutoOnLoadedEvent(stateManager: stateManager),
      );

      filterPopupState.onSelected(PlutoOnSelectedEvent());

      verify(
        stateManager.removeListener(filterPopupState.stateListener),
      ).called(1);
    });
  });
}
