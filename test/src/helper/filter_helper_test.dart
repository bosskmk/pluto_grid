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
          isA<PlutoFilterTypeContains>(),
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
        var filter = PlutoFilterTypeEndsWith();

        var row = FilterHelper.createFilterRow(
          columnField: 'filterColumnField',
          filterType: filter,
          filterValue: 'abc',
        );

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn].value,
          'filterColumnField',
        );

        expect(
          row.cells[FilterHelper.filterFieldType].value,
          filter,
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
              filterType: PlutoFilterTypeStartsWith(),
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
              filterType: PlutoFilterTypeStartsWith(),
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
        compare = makeCompareFunction(PlutoFilterTypeStartsWith());
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
        compare = makeCompareFunction(PlutoFilterTypeEndsWith());
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
        compare = makeCompareFunction(PlutoFilterTypeContains());
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
        compare = makeCompareFunction(PlutoFilterTypeEquals());
      });

      test('apple equals apple', () {
        expect(compare('apple', 'apple'), isTrue);
      });

      test('apple is not equals banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });

      test('0 equals "0"', () {
        expect(compare(0, '0'), isTrue);
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
              columns: ColumnHelper.textColumn('column'),
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
              columns: ColumnHelper.textColumn('column'),
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

    group('stateListener', () {
      test('filterRows 가 변경되지 않았으면 handleApplyFilter 가 호출되지 않아야 한다.', () {
        var mock = MockOnChangeListener();

        var columns = ColumnHelper.textColumn('column');

        var filterRows = RowHelper.count(1, columns);

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: PlutoConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.onChangeOneParamListener,
          columns: columns,
          filterRows: filterRows,
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoStateManager();

        filterPopupState.onLoaded(
          PlutoOnLoadedEvent(stateManager: stateManager),
        );

        when(stateManager.rows).thenReturn([...filterRows]);

        filterPopupState.stateListener();

        verifyNever(mock.onChangeOneParamListener(stateManager));
      });

      test('filterRows 가 변경 되었으면 handleApplyFilter 가 호출 되어야 한다.', () {
        var mock = MockOnChangeListener();

        var columns = ColumnHelper.textColumn('column');

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: PlutoConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.onChangeOneParamListener,
          columns: columns,
          filterRows: [],
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoStateManager();

        filterPopupState.onLoaded(
          PlutoOnLoadedEvent(stateManager: stateManager),
        );

        when(stateManager.rows).thenReturn(RowHelper.count(1, columns));

        filterPopupState.stateListener();

        verify(mock.onChangeOneParamListener(stateManager)).called(1);
      });
    });

    group('makeColumns', () {
      var columns = ColumnHelper.textColumn('column', count: 3);

      var configuration = PlutoConfiguration();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: configuration,
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: columns,
        filterRows: [],
        focusFirstFilterValue: false,
      );

      var filterColumns = filterPopupState.makeColumns();

      test('3개의 컬럼이 생성 되어야 한다.', () {
        expect(filterColumns.length, 3);
        expect(filterColumns[0].field, FilterHelper.filterFieldColumn);
        expect(filterColumns[1].field, FilterHelper.filterFieldType);
        expect(filterColumns[2].field, FilterHelper.filterFieldValue);
      });

      test('filterColumns 의 첫번째 컬럼이 select type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[0];

        expect(filterColumn.type, isA<PlutoColumnTypeSelect>());

        var columnType = filterColumn.type as PlutoColumnTypeSelect;

        // 전체 검색 필드가 추가 되어 +1 (FilterHelper.filterFieldAllColumns)
        expect(columnType.items.length, columns.length + 1);

        expect(columnType.items[0], FilterHelper.filterFieldAllColumns);
        expect(columnType.items[1], columns[0].field);
        expect(columnType.items[2], columns[1].field);
        expect(columnType.items[3], columns[2].field);

        // formatter
        expect(
          filterColumn.formatter(FilterHelper.filterFieldAllColumns),
          configuration.localeText.filterAllColumns,
        );

        expect(
          filterColumn.formatter(columns[0].field),
          columns[0].title,
        );

        expect(
          filterColumn.formatter(columns[1].field),
          columns[1].title,
        );

        expect(
          filterColumn.formatter(columns[2].field),
          columns[2].title,
        );
      });

      test('filterColumns 의 두번째 컬럼이 select type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[1];

        expect(filterColumn.type, isA<PlutoColumnTypeSelect>());

        var columnType = filterColumn.type as PlutoColumnTypeSelect;

        // configuration 의 필터 수 만큼 생성 되어야 한다. (기본 4개)
        expect(configuration.columnFilters.length, 4);
        expect(columnType.items.length, configuration.columnFilters.length);

        // formatter
        expect(
          filterColumn.formatter(configuration.columnFilters[0]),
          configuration.columnFilters[0].title,
        );

        expect(
          filterColumn.formatter(configuration.columnFilters[1]),
          configuration.columnFilters[1].title,
        );

        expect(
          filterColumn.formatter(configuration.columnFilters[2]),
          configuration.columnFilters[2].title,
        );

        expect(
          filterColumn.formatter(configuration.columnFilters[3]),
          configuration.columnFilters[3].title,
        );
      });

      test('filterColumns 의 세번째 컬럼이 text type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[2];

        expect(filterColumn.type, isA<PlutoColumnTypeText>());
      });
    });
  });
}
