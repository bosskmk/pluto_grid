import 'package:pluto_grid/pluto_grid.dart';

import './csv/pluto_grid_csv_export.dart';

class PlutoGridExport {
  /// Export to CSV from PlutoGrid
  ///
  /// [state] The stateManager received from the [onLoaded] callback of [PlutoGrid].
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
