import 'package:pluto_grid/pluto_grid.dart';

/// Event called when the value of the TextField
/// that handles the filter under the column changes.
class PlutoGridChangeColumnFilterEvent extends PlutoGridEvent {
  final PlutoColumn? column;
  final PlutoFilterType? filterType;
  final String? filterValue;
  final int? debounceMilliseconds;

  PlutoGridChangeColumnFilterEvent({
    this.column,
    this.filterType,
    this.filterValue,
    this.debounceMilliseconds,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: Duration(
            milliseconds: debounceMilliseconds == null
                ? PlutoGridSettings.debounceMillisecondsForColumnFilter
                : debounceMilliseconds < 0
                    ? 0
                    : debounceMilliseconds,
          ),
        );

  void handler(PlutoGridStateManager? stateManager) {
    List<PlutoRow?> foundFilterRows =
        stateManager!.filterRowsByField(column!.field);

    if (foundFilterRows.isEmpty) {
      stateManager.setFilterWithFilterRows([
        ...stateManager.filterRows,
        FilterHelper.createFilterRow(
          columnField: column!.field,
          filterType: filterType,
          filterValue: filterValue,
        ),
      ]);
    } else {
      foundFilterRows.first!.cells[FilterHelper.filterFieldValue]!.value =
          filterValue;

      stateManager.setFilterWithFilterRows(stateManager.filterRows);
    }
  }
}
