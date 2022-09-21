import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRowGroup extends PlutoRow {
  PlutoRowGroup({
    required super.cells,
    super.sortIdx,
    super.checked,
    super.key,
  });

  factory PlutoRowGroup.filledCells({
    required Key key,
    required int sortIdx,
    required PlutoColumn column,
    required List<PlutoRow> children,
  }) {
    final cells = <String, PlutoCell>{};

    final firstRow = children.first;

    final row = PlutoRowGroup(
      cells: cells,
      key: ValueKey(key),
      sortIdx: sortIdx,
    );

    for (var e in firstRow.cells.entries) {
      cells[e.key] = PlutoCell(
        value: e.value.value,
        key: ValueKey('${key}_${e.key}_cell'),
      )
        ..setColumn(e.value.column)
        ..setRow(row);
    }

    row.cells = cells;

    row.children = children;

    row.groupField = column.field;

    return row;
  }

  @override
  PlutoRowType get type => PlutoRowType.group;

  @override
  bool expanded = false;

  @override
  String groupField = '';

  @override
  List<PlutoRow> children = [];

  @override
  void setExpanded(bool flag) {
    expanded = flag;
  }
}
