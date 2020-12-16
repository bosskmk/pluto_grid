import 'package:pluto_grid/pluto_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class PlutoChangeColumnFilterEvent extends PlutoEvent {
  final String columnField;
  final PlutoFilterType filterType;
  final String filterValue;

  PlutoChangeColumnFilterEvent({
    this.columnField,
    this.filterType,
    this.filterValue,
  });

  void handler(PlutoStateManager stateManager) {
    List<PlutoRow> foundFilterRows =
        stateManager.filterRowsByField(columnField);

    if (foundFilterRows.isEmpty) {
      stateManager.setFilterWithFilterRows([
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: columnField,
          filterType: filterType,
          filterValue: filterValue,
        ),
      ]);
    } else {
      foundFilterRows.first.cells[FilterHelper.filterFieldValue].value =
          filterValue;

      stateManager.setFilterWithFilterRows(stateManager.filterRows);
    }
  }
}
