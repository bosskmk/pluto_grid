part of '../../../pluto_grid.dart';

abstract class IFilteringRowState {
  List<PlutoRow> get filterRows;

  bool get hasFilter;

  void setFilter(FilteredListFilter filter);

  void setFilterWithFilterRows(List<PlutoRow> rows);

  void setFilterRows(List<PlutoRow> rows);

  bool isFilteredColumn(PlutoColumn column);

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn calledColumn,
  });
}

mixin FilteringRowState implements IPlutoState {
  List<PlutoRow> get filterRows => _filterRows;

  List<PlutoRow> _filterRows = [];

  bool get hasFilter => _rows.hasFilter;

  void setFilter(FilteredListFilter<PlutoRow> filter) {
    for (var row in _rows.originalList) {
      row._setState(PlutoRowState.none);
    }

    var _filter = filter;

    if (filter == null) {
      setFilterRows([]);
    } else {
      _filter = (PlutoRow row) {
        return !row._state.isNone || filter(row);
      };
    }

    _rows.setFilter(_filter);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  void setFilterWithFilterRows(List<PlutoRow> rows) {
    setFilterRows(rows);

    var enabledFilterColumnFields = _columns
        .where((element) => element.enableFilterMenuItem)
        .map((e) => e.field)
        .toList();

    setFilter(FilterHelper.rowsToFilter(rows, enabledFilterColumnFields));
  }

  void setFilterRows(List<PlutoRow> rows) {
    _filterRows = rows;
  }

  bool isFilteredColumn(PlutoColumn column) {
    return hasFilter &&
        _filterRows.isNotEmpty &&
        FilterHelper.isFilteredColumn(column, _filterRows);
  }

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn calledColumn,
  }) {
    var shouldProvideDefaultFilterRow =
        _filterRows.isEmpty && calledColumn != null;

    var rows = shouldProvideDefaultFilterRow
        ? [FilterHelper.getFilter(columnField: calledColumn.field)]
        : _filterRows;

    FilterHelper.filterPopup(
      FilterPopupState(
        context: context,
        configuration: configuration,
        handleAddNewFilter: (filterState) {
          filterState.appendRows([FilterHelper.getFilter()]);
        },
        handleApplyFilter: (filterState) {
          setFilterWithFilterRows(filterState.rows);
        },
        columns: columns,
        filterRows: rows,
        focusFirstFilterValue: shouldProvideDefaultFilterRow,
      ),
    );
  }
}
