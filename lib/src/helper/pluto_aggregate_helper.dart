import 'package:collection/collection.dart'
    show IterableExtension, IterableNullableExtension, IterableNumberExtension;
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class PlutoAggregateHelper {
  static num sum({
    required Iterable<PlutoRow> rows,
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

    final Iterable<num> numbers = foundItems
        .map(
          (e) => e.cells[column.field]?.value as num?,
        )
        .whereNotNull();

    return numberColumn.toNumber(numberColumn.applyFormat(numbers.sum));
  }

  static num average({
    required Iterable<PlutoRow> rows,
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

    final Iterable<num> numbers = foundItems
        .map(
          (e) => e.cells[column.field]?.value as num?,
        )
        .whereNotNull();

    return numberColumn.toNumber(numberColumn.applyFormat(numbers.average));
  }

  static num? min({
    required Iterable<PlutoRow> rows,
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
    required Iterable<PlutoRow> rows,
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
    required Iterable<PlutoRow> rows,
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
    required Iterable<PlutoRow> rows,
    required PlutoColumn column,
  }) {
    return rows.firstOrNull?.cells.containsKey(column.field) == true;
  }
}
