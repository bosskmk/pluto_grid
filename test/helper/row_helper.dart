import 'dart:math';

import 'package:pluto_grid/pluto_grid.dart';

class RowHelper {
  /// cell value format : '$columnFieldName value $rowIdx'
  static List<PlutoRow> count(
    int count,
    List<PlutoColumn> columns, {
    bool checked = false,
  }) {
    return Iterable.generate(count)
        .map((rowIdx) => PlutoRow(
              sortIdx: rowIdx,
              cells: Map.fromIterable(
                columns,
                key: (column) => column.field,
                value: (column) {
                  if ((column as PlutoColumn).type.isText) {
                    return cellOfTextColumn(column, rowIdx);
                  } else if ((column as PlutoColumn).type.isDate) {
                    return cellOfDateColumn(column, rowIdx);
                  }

                  throw Exception('Column is not implemented.');
                },
              ),
              checked: checked,
            ))
        .toList();
  }

  static PlutoCell cellOfTextColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(value: '${column.field} value $rowIdx');
  }

  static PlutoCell cellOfDateColumn(PlutoColumn column, int rowIdx) {
    return PlutoCell(
      value: DateTime.now()
          .add(Duration(
            days: Random().nextInt(365),
          ))
          .toString(),
    );
  }
}
