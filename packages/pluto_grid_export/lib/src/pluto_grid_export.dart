import 'package:pluto_grid/pluto_grid.dart';

import './csv/pluto_grid_csv_export.dart';

class PlutoGridExport {
  static String exportCSV(
    PlutoGridStateManager state, {
    String? fieldDelimiter,
    String? textDelimiter,
    String? textEndDelimiter,
    String? eol,
  }) {
    var plutoGridCsvExport = PlutoGridDefaultCsvExport(
      fieldDelimiter: fieldDelimiter,
      textDelimiter: textDelimiter,
      textEndDelimiter: textEndDelimiter,
      eol: eol,
    );

    return plutoGridCsvExport.export(state);
  }
}
