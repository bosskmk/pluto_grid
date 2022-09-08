import 'package:collection/collection.dart' show IterableNumberExtension;
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoAggregateCondition = bool Function(PlutoRow);

class PlutoAggregateHelper {
  PlutoAggregateHelper({
    required this.rows,
  });

  final List<PlutoRow> rows;

  num sum({
    required PlutoColumn column,
    PlutoAggregateCondition? condition,
  }) {
    num sum = 0;

    if (!column.type.isNumber) {
      return sum;
    }

    final bool hasCondition = condition != null;

    final numberColumn = column.type.number!;

    sum = rows.fold(0, (p, e) {
      if (!hasCondition || condition(e)) {
        return p += e.cells[column.field]!.value!;
      }
      return p;
    });

    return numberColumn.toNumber(numberColumn.applyFormat(sum));
  }

  num average({
    required PlutoColumn column,
    PlutoAggregateCondition? condition,
  }) {
    num sum = 0;

    if (!column.type.isNumber) {
      return sum;
    }

    final bool hasCondition = condition != null;

    final numberColumn = column.type.number!;

    int itemCount = 0;

    sum = rows.fold(0, (p, e) {
      if (!hasCondition || condition(e)) {
        ++itemCount;
        return p += e.cells[column.field]!.value!;
      }
      return p;
    });

    return numberColumn.toNumber(numberColumn.applyFormat(sum / itemCount));
  }

  num? min({
    required PlutoColumn column,
    PlutoAggregateCondition? condition,
  }) {
    if (!column.type.isNumber) {
      return null;
    }

    final bool hasCondition = condition != null;

    final foundItems = hasCondition ? rows.where(condition) : rows;

    final Iterable<num> mapValues =
        foundItems.map((e) => e.cells[column.field]!.value);

    return mapValues.minOrNull;
  }

  num? max({
    required PlutoColumn column,
    PlutoAggregateCondition? condition,
  }) {
    if (!column.type.isNumber) {
      return null;
    }

    final bool hasCondition = condition != null;

    final foundItems = hasCondition ? rows.where(condition) : rows;

    final Iterable<num> mapValues =
        foundItems.map((e) => e.cells[column.field]!.value);

    return mapValues.maxOrNull;
  }

  int count({
    required PlutoColumn column,
    PlutoAggregateCondition? condition,
  }) {
    final bool hasCondition = condition != null;

    final foundItems = hasCondition ? rows.where(condition) : rows;

    return foundItems.length;
  }
}
