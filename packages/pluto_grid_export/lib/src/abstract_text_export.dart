import 'package:pluto_grid_plus/pluto_grid.dart';

/// Abstract class for converting PlutoGrid's metadata.
abstract class AbstractTextExport<T> {
  const AbstractTextExport();

  T export(PlutoGridStateManager state);

  /// Returns the titles of the active column of PlutoGrid.
  List<String> getColumnTitles(PlutoGridStateManager state) =>
      visibleColumns(state).map((e) => e.title).toList();

  /// Converts a list of PlutoRows to a string to be printed.
  ///
  /// [state] PlutoGrid's PlutoGridStateManager.
  List<List<String?>> mapStateToListOfRows(PlutoGridStateManager state) {
    List<List<String?>> outputRows = [];

    List<PlutoRow> rowsToExport;

    // Use filteredList if available
    // https://github.com/bosskmk/pluto_grid/issues/318#issuecomment-987424407
    rowsToExport = state.refRows.filteredList.isNotEmpty
        ? state.refRows.filteredList
        : state.refRows.originalList;

    for (var plutoRow in rowsToExport) {
      outputRows.add(mapPlutoRowToList(state, plutoRow));
    }

    return outputRows;
  }

  /// [state] PlutoGrid's PlutoGridStateManager.
  List<String?> mapPlutoRowToList(
    PlutoGridStateManager state,
    PlutoRow plutoRow,
  ) {
    List<String?> serializedRow = [];

    // Order is important, so we iterate over columns
    for (PlutoColumn column in visibleColumns(state)) {
      dynamic value = plutoRow.cells[column.field]?.value;
      serializedRow
          .add(value != null ? column.formattedValueForDisplay(value) : null);
    }

    return serializedRow;
  }

  List<PlutoColumn> visibleColumns(PlutoGridStateManager state) =>
      state.columns.where((element) => !element.hide).toList();
}
