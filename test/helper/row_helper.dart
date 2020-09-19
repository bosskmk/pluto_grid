import 'package:pluto_grid/pluto_grid.dart';

class RowHelper {
  /// cell value format : '$columnFieldName value $rowIdx'
  static List<PlutoRow> count(int count, List<PlutoColumn> columns) {
    return Iterable.generate(count)
        .map((rowIdx) => PlutoRow(
              sortIdx: rowIdx,
              cells: Map.fromIterable(
                columns,
                key: (column) => column.field,
                value: (column) =>
                    PlutoCell(value: '${column.field} value $rowIdx'),
              ),
            ))
        .toList();
  }
}
