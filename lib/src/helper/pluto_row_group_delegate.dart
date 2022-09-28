import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

enum PlutoRowGroupDelegateType {
  tree,
  byColumn;

  bool get isTree => this == PlutoRowGroupDelegateType.tree;

  bool get isByColumn => this == PlutoRowGroupDelegateType.byColumn;
}

abstract class PlutoRowGroupDelegate {
  PlutoRowGroupDelegateType get type;

  bool get enabled;

  bool isEditableCell(PlutoCell cell);

  bool isExpandableCell(PlutoCell cell);

  List<PlutoRow> toGroup({required Iterable<PlutoRow> rows});

  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  });

  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  });
}

class PlutoRowGroupTreeDelegate implements PlutoRowGroupDelegate {
  final bool Function(PlutoCell cell) showExpandableIcon;

  final bool Function(PlutoCell cell) showText;

  PlutoRowGroupTreeDelegate({
    required this.showExpandableIcon,
    required this.showText,
  });

  @override
  PlutoRowGroupDelegateType get type => PlutoRowGroupDelegateType.tree;

  @override
  bool get enabled => true;

  @override
  bool isEditableCell(PlutoCell cell) => showText(cell);

  @override
  bool isExpandableCell(PlutoCell cell) => showExpandableIcon(cell);

  void initializeChildren({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) {
    PlutoGridStateManager.initializeRows(columns, rows);

    for (final row in rows) {
      if (row.type.isGroup) {
        initializeChildren(
          columns: columns,
          rows: row.type.group.children.originalList,
        );
      }
    }
  }

  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    return rows.toList();
  }

  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) {
      return;
    }

    rows.sort(compare);

    sortChildren(PlutoRow row) {
      if (!row.type.isGroup) {
        return;
      }

      if (row.type.group.children.originalList.isEmpty) {
        return;
      }

      row.type.group.children.sort(compare);

      for (final child in row.type.group.children.originalList) {
        sortChildren(child);
      }
    }

    for (final row in rows.originalList) {
      sortChildren(row);
    }
  }

  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (filter == null) {
      void setFilter(FilteredList<PlutoRow> filteredList) {
        filteredList.setFilter(null);

        if (filteredList.originalList.isEmpty) {
          return;
        }

        for (final child in filteredList.originalList) {
          if (child.type.isGroup) {
            setFilter(child.type.group.children);
          }
        }
      }

      setFilter(rows);
    } else {
      void setFilter(FilteredList<PlutoRow> filteredList) {
        filteredList.setFilter((row) {
          if (!row.type.isGroup) {
            return filter(row);
          }

          setFilter(row.type.group.children);
          return filter(row) ||
              row.type.group.children.filterOrOriginalList.isNotEmpty;
        });
      }

      setFilter(rows);
    }
  }
}

class PlutoRowGroupByColumnDelegate implements PlutoRowGroupDelegate {
  final List<PlutoColumn> columns;

  PlutoRowGroupByColumnDelegate({
    required this.columns,
  });

  @override
  PlutoRowGroupDelegateType get type => PlutoRowGroupDelegateType.byColumn;

  @override
  bool get enabled => visibleColumns.isNotEmpty;

  List<PlutoColumn> get visibleColumns =>
      columns.where((e) => !e.hide).toList();

  @override
  bool isEditableCell(PlutoCell cell) =>
      cell.row.type.isNormal && !isRowGroupColumn(cell.column);

  @override
  bool isExpandableCell(PlutoCell cell) {
    if (cell.row.type.isNormal) {
      return false;
    }

    return _columnDepth(cell.column) == cell.row.depth;
  }

  bool isRowGroupColumn(PlutoColumn column) {
    return visibleColumns.firstWhereOrNull((e) => e.field == column.field) !=
        null;
  }

  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    assert(visibleColumns.isNotEmpty);

    final maxDepth = visibleColumns.length;
    int sortIdx = 0;

    List<PlutoRow> toGroup({
      required Iterable<PlutoRow> children,
      required int depth,
      String? previousKey,
    }) {
      final groupedColumn = visibleColumns[depth];

      return groupBy<PlutoRow, String>(children, (row) {
        return row.cells[visibleColumns[depth].field]!.value.toString();
      }).entries.map(
        (group) {
          final groupKey =
              previousKey == null ? group.key : '${previousKey}_${group.key}';

          final Key key = ValueKey(
            '${groupedColumn.field}_${groupKey}_rowGroup',
          );

          final nextDepth = depth + 1;

          final firstRow = group.value.first;

          final cells = <String, PlutoCell>{};

          final row = PlutoRow(
            cells: cells,
            key: ValueKey(key),
            sortIdx: sortIdx++,
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: nextDepth < maxDepth
                    ? toGroup(
                        children: group.value,
                        depth: nextDepth,
                        previousKey: groupKey,
                      ).toList()
                    : group.value.toList(),
              ),
            ),
          );

          for (var e in firstRow.cells.entries) {
            cells[e.key] = PlutoCell(
              value: visibleColumns.firstWhereOrNull((c) => c.field == e.key) !=
                      null
                  ? e.value.value
                  : null,
              key: ValueKey('${key}_${e.key}_cell'),
            )
              ..setColumn(e.value.column)
              ..setRow(row);
          }

          return row;
        },
      ).toList();
    }

    return toGroup(children: rows, depth: 0);
  }

  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) {
      return;
    }

    final depth = _columnDepth(column);

    if (depth == 0) {
      rows.sort(compare);
      return;
    }

    sortChildren(PlutoRow row) {
      assert(row.type.isGroup);

      if (row.type.group.children.originalList.isEmpty) {
        return;
      }

      if (_firstChildDepth(row) == depth) {
        row.type.group.children.sort(compare);
        return;
      }

      if (_isFirstChildGroup(row)) {
        for (final child in row.type.group.children.originalList) {
          sortChildren(child);
        }
      }
    }

    for (final row in rows.originalList) {
      sortChildren(row);
    }
  }

  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (filter == null) {
      void setFilter(FilteredList<PlutoRow> filteredList) {
        filteredList.setFilter(null);

        if (filteredList.originalList.isEmpty ||
            !filteredList.originalList.first.type.isGroup) {
          return;
        }

        for (final child in filteredList.originalList) {
          setFilter(child.type.group.children);
        }
      }

      setFilter(rows);
    } else {
      void setFilter(FilteredList<PlutoRow> filteredList) {
        filteredList.setFilter((row) {
          if (!row.type.isGroup) {
            return filter(row);
          }

          setFilter(row.type.group.children);
          return row.type.group.children.filterOrOriginalList.isNotEmpty;
        });
      }

      setFilter(rows);
    }
  }

  int _columnDepth(PlutoColumn column) => visibleColumns.indexOf(column);

  int _firstChildDepth(PlutoRow row) {
    if (!row.type.group.children.originalList.first.type.isGroup) {
      return -1;
    }

    return row.type.group.children.originalList.first.depth;
  }

  bool _isFirstChildGroup(PlutoRow row) {
    return row.type.group.children.originalList.first.type.isGroup;
  }
}
