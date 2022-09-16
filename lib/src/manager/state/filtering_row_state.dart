import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IFilteringRowState {
  List<PlutoRow> get filterRows;

  bool get hasFilter;

  void setFilter(FilteredListFilter<PlutoRow>? filter, {bool notify = true});

  void setFilterWithFilterRows(List<PlutoRow> rows, {bool notify = true});

  void setFilterRows(List<PlutoRow> rows);

  List<PlutoRow> filterRowsByField(String columnField);

  /// Check if the column is in a state with filtering applied.
  bool isFilteredColumn(PlutoColumn column);

  void removeColumnsInFilterRows(
    List<PlutoColumn> columns, {
    bool notify = true,
  });

  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
  });
}

mixin FilteringRowState implements IPlutoGridState {
  @override
  List<PlutoRow> get filterRows => _filterRows;

  List<PlutoRow> _filterRows = [];

  @override
  bool get hasFilter => refRows.hasFilter;

  @override
  void setFilter(FilteredListFilter<PlutoRow>? filter, {bool notify = true}) {
    for (final row in refRows.originalList) {
      row.setState(PlutoRowState.none);
    }

    var savedFilter = filter;

    if (filter == null) {
      setFilterRows([]);
    } else {
      savedFilter = (PlutoRow row) {
        return !row.state.isNone || filter(row);
      };
    }

    refRows.setFilter(savedFilter);

    resetCurrentState(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setFilterWithFilterRows(List<PlutoRow> rows, {bool notify = true}) {
    setFilterRows(rows);

    var enabledFilterColumnFields =
        refColumns.where((element) => element.enableFilterMenuItem).toList();

    setFilter(
      FilterHelper.convertRowsToFilter(_filterRows, enabledFilterColumnFields),
      notify: isPaginated ? false : notify,
    );

    if (isPaginated) {
      resetPage(notify: notify);
    }
  }

  @override
  void setFilterRows(List<PlutoRow> rows) {
    _filterRows = rows
        .where(
          (element) => element.cells[FilterHelper.filterFieldValue]!.value
              .toString()
              .isNotEmpty,
        )
        .toList();
  }

  @override
  List<PlutoRow> filterRowsByField(String columnField) {
    return _filterRows
        .where(
          (element) =>
              element.cells[FilterHelper.filterFieldColumn]!.value ==
              columnField,
        )
        .toList();
  }

  @override
  bool isFilteredColumn(PlutoColumn column) {
    return hasFilter && FilterHelper.isFilteredColumn(column, _filterRows);
  }

  @override
  void removeColumnsInFilterRows(
    List<PlutoColumn> columns, {
    bool notify = true,
  }) {
    if (filterRows.isEmpty) {
      return;
    }

    final Set<String> columnFields = Set.from(columns.map((e) => e.field));

    filterRows.removeWhere(
      (filterRow) {
        return columnFields.contains(
          filterRow.cells[FilterHelper.filterFieldColumn]!.value,
        );
      },
    );

    setFilterWithFilterRows(filterRows, notify: notify);
  }

  @override
  void showFilterPopup(
    BuildContext context, {
    PlutoColumn? calledColumn,
  }) {
    var shouldProvideDefaultFilterRow =
        _filterRows.isEmpty && calledColumn != null;

    var rows = shouldProvideDefaultFilterRow
        ? [
            FilterHelper.createFilterRow(
              columnField: calledColumn.enableFilterMenuItem
                  ? calledColumn.field
                  : FilterHelper.filterFieldAllColumns,
              filterType: calledColumn.defaultFilter,
            ),
          ]
        : _filterRows;

    FilterHelper.filterPopup(
      FilterPopupState(
        context: context,
        configuration: configuration.copyWith(
          style: configuration.style.copyWith(
            gridBorderRadius: configuration.style.gridPopupBorderRadius,
            enableRowColorAnimation: false,
            oddRowColor: PlutoOptional(null),
            evenRowColor: PlutoOptional(null),
          ),
        ),
        handleAddNewFilter: (filterState) {
          filterState!.appendRows([FilterHelper.createFilterRow()]);
        },
        handleApplyFilter: (filterState) {
          setFilterWithFilterRows(filterState!.rows);
        },
        columns: columns,
        filterRows: rows,
        focusFirstFilterValue: shouldProvideDefaultFilterRow,
      ),
    );
  }
}
