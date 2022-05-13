import 'package:csv/csv.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridExport {
  static String exportCSV(
    PlutoGridStateManager state, {
    String? fieldDelimiter,
    String? textDelimiter,
    String? textEndDelimiter,
    String? eol,
  }) {
    String toCsv = const ListToCsvConverter().convert(
      _mapStateToRows(state),
      fieldDelimiter: fieldDelimiter,
      textDelimiter: textDelimiter,
      textEndDelimiter: textEndDelimiter,
      delimitAllFields: true,
      eol: eol,
    );

    return toCsv;
  }

  static List<List<String?>> _mapStateToRows(PlutoGridStateManager state) {
    List<List<String?>> outputRows = [];
    outputRows.add(state.columns
        // Append all VISIBLE columns
        .where((element) => !element.hide)
        .map((e) => e.title)
        .toList());

    List<PlutoRow> rowsToExport;

    // Use filteredList if available
    // https://github.com/bosskmk/pluto_grid/issues/318#issuecomment-987424407
    if (state.refRows.filteredList.isNotEmpty) {
      rowsToExport = state.refRows.filteredList;
    } else {
      rowsToExport = state.refRows.originalList;
    }

    for (var plutoRow in rowsToExport) {
      outputRows.add(_mapRow(state.columns, plutoRow));
    }

    return outputRows;
  }

  static List<String?> _mapRow(
    List<PlutoColumn> plutoColumns,
    PlutoRow plutoRow,
  ) {
    List<String?> serializedRow = [];

    // Order is important, so we iterate over columns
    for (PlutoColumn column in plutoColumns) {
      // Only VISIBLE columns
      if (!column.hide) {
        dynamic value = plutoRow.cells[column.field]?.value;
        serializedRow
            .add(value != null ? column.formattedValueForDisplay(value) : null);
      }
    }

    return serializedRow;
  }
}
