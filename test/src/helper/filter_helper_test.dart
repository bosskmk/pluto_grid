import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/row_helper.dart';
import '../../mock/mock_build_context.dart';
import '../../mock/mock_on_change_listener.dart';
import 'filter_helper_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
])
void main() {
  group('createFilterRow', () {
    test(
      'When called without arguments,'
      'Should be returned a row filled with default values.',
      () {
        var row = FilterHelper.createFilterRow();

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn]!.value,
          FilterHelper.filterFieldAllColumns,
        );

        expect(
          row.cells[FilterHelper.filterFieldType]!.value,
          isA<PlutoFilterTypeContains>(),
        );

        expect(
          row.cells[FilterHelper.filterFieldValue]!.value,
          '',
        );
      },
    );

    test(
      'When called with arguments,'
      'Should be returned a row filled with arguments.',
      () {
        var filter = const PlutoFilterTypeEndsWith();

        var row = FilterHelper.createFilterRow(
          columnField: 'filterColumnField',
          filterType: filter,
          filterValue: 'abc',
        );

        expect(row.cells.length, 3);

        expect(
          row.cells[FilterHelper.filterFieldColumn]!.value,
          'filterColumnField',
        );

        expect(
          row.cells[FilterHelper.filterFieldType]!.value,
          filter,
        );

        expect(
          row.cells[FilterHelper.filterFieldValue]!.value,
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
      List<PlutoColumn>? columns;

      PlutoRow? row;

      setUp(() {
        columns = ColumnHelper.textColumn('column', count: 3);

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

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
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

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
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
              filterType: const PlutoFilterTypeStartsWith(),
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isTrue,
          );
        },
      );

      test(
        'column1 이 enabledFilterColumns 에 존재하지 않을 때, '
        'filterFieldColumn : column1, '
        'filterFieldType : Contains, '
        'filterFieldValue : column1, '
        'false',
        () {
          var filterRows = [
            FilterHelper.createFilterRow(
              columnField: 'column1',
              filterType: const PlutoFilterTypeContains(),
              filterValue: 'column1',
            )
          ];

          columns!.removeWhere((element) => element.field == 'column1');

          var enabledFilterColumns = columns;

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
            isFalse,
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
              filterType: const PlutoFilterTypeStartsWith(),
              filterValue: 'column1',
            )
          ];

          var enabledFilterColumns = columns!
              .where(
                (element) => element.field == 'column3',
              )
              .toList();

          expect(
            FilterHelper.convertRowsToFilter(
              filterRows,
              enabledFilterColumns,
            )!(row),
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
    late bool Function(dynamic a, dynamic b) Function(
      PlutoFilterType filterType, {
      PlutoColumn? column,
    }) makeCompareFunction;

    setUp(() {
      makeCompareFunction = (
        PlutoFilterType filterType, {
        PlutoColumn? column,
      }) {
        column ??= PlutoColumn(
          title: 'column',
          field: 'column',
          type: PlutoColumnType.text(),
        );

        return (dynamic a, dynamic b) {
          return FilterHelper.compareByFilterType(
            filterType: filterType,
            base: a.toString(),
            search: b.toString(),
            column: column,
          );
        };
      };
    });

    group('Contains', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeContains());
      });

      test('apple contains le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not contains banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('Equals', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeEquals());
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

    group('StartsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeStartsWith());
      });

      test('apple startsWith ap', () {
        expect(compare('apple', 'ap'), isTrue);
      });

      test('apple is not startsWith banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('EndsWith', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeEndsWith());
      });

      test('apple endsWith le', () {
        expect(compare('apple', 'le'), isTrue);
      });

      test('apple is not endsWith app', () {
        expect(compare('apple', 'app'), isFalse);
      });
    });

    group('GreaterThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeGreaterThan());
      });

      test('banana GreaterThan apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('apple is not GreaterThan banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('GreaterThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(
          const PlutoFilterTypeGreaterThanOrEqualTo(),
        );
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'apple'), isTrue);
      });

      test('banana GreaterThanOrEqualTo apple', () {
        expect(compare('banana', 'banana'), isTrue);
      });

      test('apple is not GreaterThanOrEqualTo banana', () {
        expect(compare('apple', 'banana'), isFalse);
      });
    });

    group('LessThan', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeLessThan());
      });

      test('A LessThan B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('B is not LessThan A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });

    group('LessThanOrEqualTo', () {
      late Function compare;

      setUp(() {
        compare = makeCompareFunction(const PlutoFilterTypeLessThanOrEqualTo());
      });

      test('A LessThanOrEqualTo B', () {
        expect(compare('A', 'B'), isTrue);
      });

      test('A LessThanOrEqualTo A', () {
        expect(compare('A', 'A'), isTrue);
      });

      test('B is not LessThanOrEqualTo A', () {
        expect(compare('B', 'A'), isFalse);
      });
    });
  });

  group('FilterPopupState', () {
    test(
      'columns should not be empty.',
      () {
        expect(
          () {
            FilterPopupState(
              context: MockBuildContext(),
              configuration: const PlutoGridConfiguration(),
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

    group('onLoaded', () {
      test(
        'should be called setSelectingMode, addListener.',
        () {
          final List<PlutoRow> filterRows = [];

          var filterPopupState = FilterPopupState(
            context: MockBuildContext(),
            configuration: const PlutoGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: ColumnHelper.textColumn('column'),
            filterRows: filterRows,
            focusFirstFilterValue: false,
          );

          var stateManager = MockPlutoGridStateManager();

          when(stateManager.rows).thenReturn(filterRows);

          filterPopupState.onLoaded(
            PlutoGridOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setSelectingMode(
            PlutoGridSelectingMode.row,
            notify: false,
          )).called(1);

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
            configuration: const PlutoGridConfiguration(),
            handleAddNewFilter: (_) {},
            handleApplyFilter: (_) {},
            columns: columns,
            filterRows: [
              FilterHelper.createFilterRow(
                columnField: columns[0].enableFilterMenuItem
                    ? columns[0].field
                    : FilterHelper.filterFieldAllColumns,
                filterType: columns[0].defaultFilter,
              ),
            ],
            focusFirstFilterValue: true,
          );

          var stateManager = MockPlutoGridStateManager();

          when(stateManager.rows).thenReturn(rows);

          filterPopupState.onLoaded(
            PlutoGridOnLoadedEvent(stateManager: stateManager),
          );

          verify(stateManager.setKeepFocus(true, notify: false)).called(1);

          verify(stateManager.setCurrentCell(
            rows.first.cells[FilterHelper.filterFieldValue],
            0,
            notify: false,
          )).called(1);

          verify(stateManager.setEditing(true, notify: false)).called(1);

          verify(stateManager.notifyListeners()).called(1);
        },
      );
    });

    test('onChanged', () {
      var mock = MockOnChangeListener();

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const PlutoGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: mock.onChangeOneParamListener,
        columns: ColumnHelper.textColumn('column'),
        filterRows: [],
        focusFirstFilterValue: true,
      );

      filterPopupState.onChanged(PlutoGridOnChangedEvent());

      verify(mock.onChangeOneParamListener(any)).called(1);
    });

    test('onSelected', () {
      final List<PlutoRow> filterRows = [];

      var filterPopupState = FilterPopupState(
        context: MockBuildContext(),
        configuration: const PlutoGridConfiguration(),
        handleAddNewFilter: (_) {},
        handleApplyFilter: (_) {},
        columns: ColumnHelper.textColumn('column'),
        filterRows: filterRows,
        focusFirstFilterValue: false,
      );

      var stateManager = MockPlutoGridStateManager();

      when(stateManager.rows).thenReturn(filterRows);

      filterPopupState.onLoaded(
        PlutoGridOnLoadedEvent(stateManager: stateManager),
      );

      filterPopupState.onSelected(PlutoGridOnSelectedEvent());

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
          configuration: const PlutoGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.onChangeOneParamListener,
          columns: columns,
          filterRows: filterRows,
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoGridStateManager();

        when(stateManager.rows).thenReturn([...filterRows]);

        filterPopupState.onLoaded(
          PlutoGridOnLoadedEvent(stateManager: stateManager),
        );

        filterPopupState.stateListener();

        verifyNever(mock.onChangeOneParamListener(stateManager));
      });

      test('filterRows 가 변경 되었으면 handleApplyFilter 가 호출 되어야 한다.', () {
        var mock = MockOnChangeListener();

        var columns = ColumnHelper.textColumn('column');

        var filterPopupState = FilterPopupState(
          context: MockBuildContext(),
          configuration: const PlutoGridConfiguration(),
          handleAddNewFilter: (_) {},
          handleApplyFilter: mock.onChangeOneParamListener,
          columns: columns,
          filterRows: [],
          focusFirstFilterValue: false,
        );

        var stateManager = MockPlutoGridStateManager();

        when(stateManager.rows).thenReturn(RowHelper.count(1, columns));

        filterPopupState.onLoaded(
          PlutoGridOnLoadedEvent(stateManager: stateManager),
        );

        filterPopupState.stateListener();

        verify(mock.onChangeOneParamListener(stateManager)).called(1);
      });
    });

    group('makeColumns', () {
      var columns = ColumnHelper.textColumn('column', count: 3);

      var configuration = const PlutoGridConfiguration();

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

        // formatter (column 의 field 가 값으로써 formatter 에서 title 로 반환한다.)
        expect(
          filterColumn.formatter!(FilterHelper.filterFieldAllColumns),
          configuration.localeText.filterAllColumns,
        );

        for (var i = 0; i < columns.length; i += 1) {
          expect(
            filterColumn.formatter!(columns[i].field),
            columns[i].title,
          );
        }
      });

      test('filterColumns 의 두번째 컬럼이 select type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[1];

        expect(filterColumn.type, isA<PlutoColumnTypeSelect>());

        var columnType = filterColumn.type as PlutoColumnTypeSelect;

        // configuration 의 필터 수 만큼 생성 되어야 한다. (기본 8개)
        expect(configuration.columnFilterConfig.filters.length, 8);
        expect(columnType.items.length,
            configuration.columnFilterConfig.filters.length);

        // formatter (filter 가 값으로 써 formatter 에서 title 을 반환한다.)
        for (var i = 0;
            i < configuration.columnFilterConfig.filters.length;
            i += 1) {
          expect(
            filterColumn
                .formatter!(configuration.columnFilterConfig.filters[i]),
            configuration.columnFilterConfig.filters[i].title,
          );
        }
      });

      test('filterColumns 의 세번째 컬럼이 text type 으로 생성 되어야 한다.', () {
        var filterColumn = filterColumns[2];

        expect(filterColumn.type, isA<PlutoColumnTypeText>());
      });
    });
  });
}
