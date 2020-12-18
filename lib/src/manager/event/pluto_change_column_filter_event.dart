import 'package:pluto_grid/pluto_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class PlutoChangeColumnFilterEvent extends PlutoEvent {
  final PlutoColumn column;
  final PlutoFilterType filterType;
  final String filterValue;

  PlutoChangeColumnFilterEvent({
    this.column,
    this.filterType,
    this.filterValue,
  });

  void handler(PlutoStateManager stateManager) {
    List<PlutoRow> foundFilterRows =
        stateManager.filterRowsByField(column.field);

    if (foundFilterRows.isEmpty) {
      stateManager.setFilterWithFilterRows([
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: column.field,
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
