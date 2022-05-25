import 'package:pluto_grid/pluto_grid.dart';

abstract class AbstractTextExport<T> {

  const AbstractTextExport();

  T export(PlutoGridStateManager state);

  List<String> getColumnTitles(PlutoGridStateManager state) =>
      visibleColumns(state).map((e) => e.title).toList();

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
