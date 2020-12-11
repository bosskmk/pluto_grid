part of '../../pluto_grid.dart';

typedef SetFilterPopupHandler = void Function(PlutoStateManager stateManager);

class FilterHelper {
  static const filterFieldAllColumns = 'plutoFilterAllColumns';

  static const filterFieldColumn = 'column';

  static const filterFieldType = 'type';

  static const filterFieldValue = 'value';

  static PlutoRow createFilterRow({
    String columnField,
    PlutoFilterType filterType,
    String filterValue,
  }) {
    return PlutoRow(
      cells: {
        filterFieldColumn:
            PlutoCell(value: columnField ?? filterFieldAllColumns),
        filterFieldType:
            PlutoCell(value: filterType ?? PlutoFilterType.contains),
        filterFieldValue: PlutoCell(value: filterValue ?? ''),
      },
    );
  }

  static FilteredListFilter<PlutoRow> convertRowsToFilter(
    List<PlutoRow> rows,
    List<String> enabledFilterColumnFields,
  ) {
    if (rows.isEmpty) {
      return null;
    }

    return (PlutoRow row) {
      bool flag;

      for (var _row in rows) {
        final filterType = _row.cells[filterFieldType].value;

        if (_row.cells[filterFieldColumn].value == filterFieldAllColumns) {
          bool flagAllColumns;

          row.cells.forEach((key, value) {
            if (enabledFilterColumnFields.contains(key)) {
              flagAllColumns = compareOr(
                flagAllColumns,
                compareByFilterType(
                  filterType,
                  value.value,
                  _row.cells[filterFieldValue].value,
                ),
              );
            }
          });

          flag = compareAnd(flag, flagAllColumns);
        } else {
          flag = compareAnd(
            flag,
            compareByFilterType(
              filterType,
              row.cells[_row.cells[filterFieldColumn].value].value,
              _row.cells[filterFieldValue].value,
            ),
          );
        }
      }

      return flag == true;
    };
  }

  static bool isFilteredColumn(
    PlutoColumn column,
    List<PlutoRow> filteredRows,
  ) {
    assert(column != null);

    if (filteredRows == null || filteredRows.isEmpty) {
      return false;
    }

    for (var row in filteredRows) {
      if (row.cells[filterFieldColumn].value == filterFieldAllColumns ||
          row.cells[filterFieldColumn].value == column.field) {
        return true;
      }
    }

    return false;
  }

  static void filterPopup(FilterPopupState popupState) {
    PlutoGridPopup(
      width: popupState.width,
      height: popupState.height,
      context: popupState.context,
      createHeader: popupState.createHeader,
      columns: popupState.makeColumns(),
      rows: popupState.filterRows,
      configuration: popupState.configuration,
      onLoaded: popupState.onLoaded,
      onChanged: popupState.onChanged,
      onSelected: popupState.onSelected,
      mode: PlutoGridMode.popup,
    );
  }

  static bool compareOr(bool a, bool b) {
    return a != true ? a == true || b : true;
  }

  static bool compareAnd(bool a, bool b) {
    return a != false ? b : false;
  }

  static bool compareByFilterType(
    PlutoFilterType filterType,
    dynamic base,
    dynamic target,
  ) {
    return filterType.compare(base, target);
  }

  static bool compareStartsWith(dynamic base, dynamic target) {
    return base.toString().startsWith(target.toString());
  }

  static bool compareEndsWith(dynamic base, dynamic target) {
    return base.toString().endsWith(target.toString());
  }

  static bool compareContains(dynamic base, dynamic target) {
    return base.toString().contains(target.toString());
  }

  static bool compareEquals(dynamic base, dynamic target) {
    if (base is String || base is int || base is double || base is bool) {
      return base.runtimeType == target.runtimeType && base == target;
    }

    return identical(base, target);
  }
}

class FilterPopupState {
  final BuildContext context;
  final PlutoConfiguration configuration;
  final SetFilterPopupHandler handleAddNewFilter;
  final SetFilterPopupHandler handleApplyFilter;
  final List<PlutoColumn> columns;
  final List<PlutoRow> filterRows;
  final bool focusFirstFilterValue;
  final double width;
  final double height;

  FilterPopupState({
    @required this.context,
    @required this.configuration,
    @required this.handleAddNewFilter,
    @required this.handleApplyFilter,
    @required this.columns,
    @required this.filterRows,
    @required this.focusFirstFilterValue,
    this.width = 600,
    this.height = 450,
  })  : assert(context != null),
        assert(handleAddNewFilter != null),
        assert(handleApplyFilter != null),
        assert(columns.isNotEmpty),
        assert(filterRows != null),
        assert(configuration != null),
        _previousFilterRows = [...filterRows];

  PlutoStateManager _stateManager;
  List<PlutoRow> _previousFilterRows;

  void onLoaded(e) {
    _stateManager = e.stateManager;

    _stateManager.setSelectingMode(PlutoSelectingMode.row);

    if (focusFirstFilterValue && _stateManager.rows.isNotEmpty) {
      _stateManager.setKeepFocus(true);

      _stateManager.setCurrentCell(
        _stateManager.rows.first.cells[FilterHelper.filterFieldValue],
        0,
        notify: false,
      );

      _stateManager.setEditing(true);
    }

    _stateManager.addListener(stateListener);
  }

  void onChanged(e) {
    applyFilter();
  }

  void onSelected(e) {
    _stateManager.removeListener(stateListener);
  }

  void stateListener() {
    if (listEquals(_previousFilterRows, _stateManager.rows) == false) {
      _previousFilterRows = [..._stateManager.rows];
      applyFilter();
    }
  }

  void applyFilter() {
    handleApplyFilter(_stateManager);
  }

  _FilterPopupHeader createHeader(_stateManager) {
    return _FilterPopupHeader(
      stateManager: _stateManager,
      configuration: configuration,
      handleAddNewFilter: handleAddNewFilter,
    );
  }

  List<PlutoColumn> makeColumns() {
    return _makeFilterColumns(configuration: configuration, columns: columns);
  }

  Map<String, String> _makeFilterColumnMap({
    @required PlutoConfiguration configuration,
    @required List<PlutoColumn> columns,
  }) {
    Map<String, String> columnMap = {
      FilterHelper.filterFieldAllColumns:
          configuration.localeText.filterAllColumns,
    };

    columns.where((element) => element.enableFilterMenuItem).forEach((element) {
      columnMap[element.field] = element.title;
    });

    return columnMap;
  }

  Map<PlutoFilterType, String> _makeFilterTypeMap({
    @required PlutoConfiguration configuration,
  }) {
    return {
      PlutoFilterType.contains: configuration.localeText.filterContains,
      PlutoFilterType.equals: configuration.localeText.filterEquals,
      PlutoFilterType.startsWith: configuration.localeText.filterStartsWith,
      PlutoFilterType.endsWith: configuration.localeText.filterEndsWith,
    };
  }

  List<PlutoColumn> _makeFilterColumns({
    @required PlutoConfiguration configuration,
    @required List<PlutoColumn> columns,
  }) {
    Map<String, String> columnMap = _makeFilterColumnMap(
      configuration: configuration,
      columns: columns,
    );

    Map<PlutoFilterType, String> filterMap = _makeFilterTypeMap(
      configuration: configuration,
    );

    return [
      PlutoColumn(
        title: configuration.localeText.filterColumn,
        field: FilterHelper.filterFieldColumn,
        type: PlutoColumnType.select(columnMap.keys.toList(growable: false)),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return columnMap[value] ?? '';
        },
      ),
      PlutoColumn(
        title: configuration.localeText.filterType,
        field: FilterHelper.filterFieldType,
        type: PlutoColumnType.select(filterMap.keys.toList(growable: false)),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return filterMap[value] ?? '';
        },
      ),
      PlutoColumn(
        title: configuration.localeText.filterValue,
        field: FilterHelper.filterFieldValue,
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
      ),
    ];
  }
}

class _FilterPopupHeader extends StatelessWidget {
  final PlutoStateManager stateManager;
  final PlutoConfiguration configuration;
  final SetFilterPopupHandler handleAddNewFilter;

  const _FilterPopupHeader({
    Key key,
    this.stateManager,
    this.configuration,
    this.handleAddNewFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            color: configuration.iconColor,
            iconSize: configuration.iconSize,
            onPressed: () => handleAddNewFilter(stateManager),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: configuration.iconColor,
            iconSize: configuration.iconSize,
            onPressed: () {
              if (stateManager.currentSelectingRows.isEmpty) {
                stateManager.removeCurrentRow();
              } else {
                stateManager.removeRows(stateManager.currentSelectingRows);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_sharp),
            color: Colors.red,
            iconSize: configuration.iconSize,
            onPressed: () => stateManager.removeRows(stateManager.rows),
          ),
        ],
      ),
    );
  }
}

enum PlutoFilterType {
  contains,
  equals,
  startsWith,
  endsWith,
}

typedef PlutoCompareFunction = bool Function(dynamic a, dynamic b);

extension PlutoFilterTypeExtension on PlutoFilterType {
  PlutoCompareFunction get compare {
    switch (this) {
      case PlutoFilterType.contains:
        return FilterHelper.compareContains;
      case PlutoFilterType.equals:
        return FilterHelper.compareEquals;
      case PlutoFilterType.startsWith:
        return FilterHelper.compareStartsWith;
      case PlutoFilterType.endsWith:
        return FilterHelper.compareEndsWith;
    }

    throw Exception('Not implements $this');
  }
}
