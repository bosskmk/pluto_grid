import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_filtered_list/pluto_filtered_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef SetFilterPopupHandler = void Function(PlutoStateManager stateManager);

class FilterHelper {
  /// A value to identify all column searches when searching filters.
  static const filterFieldAllColumns = 'plutoFilterAllColumns';

  /// The field name of the column that includes the field values of the column
  /// when searching for a filter.
  static const filterFieldColumn = 'column';

  /// The field name of the column including the filter type
  /// when searching for a filter.
  static const filterFieldType = 'type';

  /// The field name of the column containing the value to be searched
  /// when searching for a filter.
  static const filterFieldValue = 'value';

  /// Create a row to contain filter information.
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
            PlutoCell(value: filterType ?? PlutoFilterTypeContains()),
        filterFieldValue: PlutoCell(value: filterValue ?? ''),
      },
    );
  }

  /// Converts rows containing filter information into comparison functions.
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

  /// Whether [column] is included in [filteredRows].
  ///
  /// That is, check if it is a filtered column.
  /// If there is a search condition for all columns in [filteredRows],
  /// it is regarded as a filtering column.
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

  /// Opens a pop-up for filtering.
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

  /// 'or' comparison with null values
  static bool compareOr(bool a, bool b) {
    return a != true ? a == true || b : true;
  }

  /// 'and' comparison with null values
  static bool compareAnd(bool a, bool b) {
    return a != false ? b : false;
  }

  /// Compare [base] and [search] with [PlutoFilterType.compare].
  static bool compareByFilterType(
    PlutoFilterType filterType,
    dynamic base,
    dynamic search,
  ) {
    return filterType.compare(base, search);
  }

  /// Whether [search] is contains in [base].
  static bool compareContains(dynamic base, dynamic search) {
    return _compareWithRegExp(
      RegExp.escape(search.toString()),
      base.toString(),
    );
  }

  /// Whether [search] is equals to [base].
  static bool compareEquals(dynamic base, dynamic search) {
    if (base is String || base is int || base is double || base is bool) {
      return _compareWithRegExp(
        // ignore: prefer_interpolation_to_compose_strings
        r'^' + RegExp.escape(search.toString()) + r'$',
        base.toString(),
      );
    }

    return identical(base, search);
  }

  /// Whether [base] starts with [search].
  static bool compareStartsWith(dynamic base, dynamic search) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      r'^' + RegExp.escape(search.toString()),
      base.toString(),
    );
  }

  /// Whether [base] ends with [search].
  static bool compareEndsWith(dynamic base, dynamic search) {
    return _compareWithRegExp(
      // ignore: prefer_interpolation_to_compose_strings
      RegExp.escape(search.toString()) + r'$',
      base.toString(),
    );
  }

  static bool _compareWithRegExp(
    Pattern pattern,
    String value, {
    bool caseSensitive = false,
  }) {
    return RegExp(
      pattern,
      caseSensitive: caseSensitive,
    ).hasMatch(value);
  }
}

/// State for calling filter pop
class FilterPopupState {
  /// [BuildContext] for calling [showDialog]
  final BuildContext context;

  /// [PlutoConfiguration] to call [PlutoGridPopup]
  final PlutoConfiguration configuration;

  /// A callback function called when adding a new filter.
  final SetFilterPopupHandler handleAddNewFilter;

  /// A callback function called when filter information changes.
  final SetFilterPopupHandler handleApplyFilter;

  /// List of columns to be filtered.
  final List<PlutoColumn> columns;

  /// List with filtering condition information
  final List<PlutoRow> filterRows;

  /// The filter popup opens and focuses on the filter value in the first row.
  final bool focusFirstFilterValue;

  /// Width of filter popup
  final double width;

  /// Height of filter popup
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
        assert(configuration != null),
        assert(handleAddNewFilter != null),
        assert(handleApplyFilter != null),
        assert(columns != null && columns.isNotEmpty),
        assert(filterRows != null),
        assert(focusFirstFilterValue != null),
        _previousFilterRows = [...filterRows];

  PlutoStateManager _stateManager;
  List<PlutoRow> _previousFilterRows;

  void onLoaded(PlutoOnLoadedEvent e) {
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

  void onChanged(PlutoOnChangedEvent e) {
    applyFilter();
  }

  void onSelected(PlutoOnSelectedEvent e) {
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

  List<PlutoColumn> _makeFilterColumns({
    @required PlutoConfiguration configuration,
    @required List<PlutoColumn> columns,
  }) {
    Map<String, String> columnMap = _makeFilterColumnMap(
      configuration: configuration,
      columns: columns,
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
        type: PlutoColumnType.select(configuration.columnFilters),
        enableFilterMenuItem: false,
        applyFormatterInEditing: true,
        formatter: (dynamic value) {
          return value?.title ?? '';
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

  void handleAddButton() {
    handleAddNewFilter(stateManager);
  }

  void handleRemoveButton() {
    if (stateManager.currentSelectingRows.isEmpty) {
      stateManager.removeCurrentRow();
    } else {
      stateManager.removeRows(stateManager.currentSelectingRows);
    }
  }

  void handleClearButton() {
    if (stateManager.rows.isEmpty) {
      Navigator.of(stateManager.gridFocusNode.context).pop();
    } else {
      stateManager.removeRows(stateManager.rows);
    }
  }

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
            onPressed: handleAddButton,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            color: configuration.iconColor,
            iconSize: configuration.iconSize,
            onPressed: handleRemoveButton,
          ),
          IconButton(
            icon: const Icon(Icons.clear_sharp),
            color: Colors.red,
            iconSize: configuration.iconSize,
            onPressed: handleClearButton,
          ),
        ],
      ),
    );
  }
}

/// [base] is the cell values of the column on which the search is based.
/// [search] is the value entered by the user to search.
typedef PlutoCompareFunction = bool Function(dynamic base, dynamic search);

abstract class PlutoFilterType {
  String get title => throw UnimplementedError();

  PlutoCompareFunction get compare => throw UnimplementedError();
}

class PlutoFilterTypeContains implements PlutoFilterType {
  static String name = 'Contains';

  String get title => PlutoFilterTypeContains.name;

  PlutoCompareFunction get compare => FilterHelper.compareContains;
}

class PlutoFilterTypeEquals implements PlutoFilterType {
  static String name = 'Equals';

  String get title => PlutoFilterTypeEquals.name;

  PlutoCompareFunction get compare => FilterHelper.compareEquals;
}

class PlutoFilterTypeStartsWith implements PlutoFilterType {
  static String name = 'Starts with';

  String get title => PlutoFilterTypeStartsWith.name;

  PlutoCompareFunction get compare => FilterHelper.compareStartsWith;
}

class PlutoFilterTypeEndsWith implements PlutoFilterType {
  static String name = 'Ends with';

  String get title => PlutoFilterTypeEndsWith.name;

  PlutoCompareFunction get compare => FilterHelper.compareEndsWith;
}
