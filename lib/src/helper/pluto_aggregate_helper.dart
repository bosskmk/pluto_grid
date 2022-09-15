import 'package:collection/collection.dart'
    show IterableNumberExtension, IterableExtension;
import 'package:pluto_grid/pluto_grid.dart';

class PlutoAggregateHelper {
  static num sum({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    num sum = 0;

    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return sum;
    }

    final numberColumn = column.type as PlutoColumnTypeWithNumberFormat;

    sum = rows.fold(0, (p, e) {
      final cell = e.cells[column.field]!;

      if (filter == null || filter(cell)) {
        return p += cell.value!;
      }
      return p;
    });

    return numberColumn.toNumber(numberColumn.applyFormat(sum));
  }

  static num average({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    num sum = 0;

    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return sum;
    }

    int itemCount = 0;

    sum = rows.fold(0, (p, e) {
      final cell = e.cells[column.field]!;

      if (filter == null || filter(cell)) {
        ++itemCount;
        return p += cell.value!;
      }

      return p;
    });

    return sum / itemCount;
  }

  static num? min({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return null;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> mapValues =
        foundItems.map((e) => e.cells[column.field]!.value);

    return mapValues.minOrNull;
  }

  static num? max({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return null;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> mapValues =
        foundItems.map((e) => e.cells[column.field]!.value);

    return mapValues.maxOrNull;
  }

  static int count({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    if (!_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    return foundItems.length;
  }

  static bool _hasColumnField({
    required List<PlutoRow> rows,
    required PlutoColumn column,
  }) {
    return rows.firstOrNull?.cells.containsKey(column.field) == true;
  }
}
