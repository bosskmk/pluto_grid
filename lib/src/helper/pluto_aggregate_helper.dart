import 'package:collection/collection.dart'
    show IterableNumberExtension, IterableExtension;
import 'package:pluto_grid/pluto_grid.dart';

class PlutoAggregateHelper {
  static num sum({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final numberColumn = column.type as PlutoColumnTypeWithNumberFormat;

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> numbers = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

    return numberColumn.toNumber(numberColumn.applyFormat(numbers.sum));
  }

  static num average({
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) {
    if (column.type is! PlutoColumnTypeWithNumberFormat ||
        !_hasColumnField(rows: rows, column: column)) {
      return 0;
    }

    final numberColumn = column.type as PlutoColumnTypeWithNumberFormat;

    final foundItems = filter != null
        ? rows.where((row) => filter(row.cells[column.field]!))
        : rows;

    final Iterable<num> numbers = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

    return numberColumn.toNumber(numberColumn.applyFormat(numbers.average));
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

    final Iterable<num> mapValues = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

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

    final Iterable<num> mapValues = foundItems.map(
      (e) => e.cells[column.field]!.value,
    );

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
