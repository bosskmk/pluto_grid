import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

/*
  todo
    Column
      - Add
      - Remove
      - Hide
      - UnHide
    Row
      - Add
      - Move
      - Check
 */

abstract class IRowGroupState {
  bool get hasRowGroups;

  Iterable<PlutoRow> get iterateRootRowGroup;

  Iterable<PlutoRow> get iterateRowGroup;

  Iterable<PlutoRow> get iterateRowAndGroup;

  Iterable<PlutoRow> get iterateRow;

  bool isGroupedRowColumn(PlutoColumn column);

  void setRowGroupByColumns(
    List<PlutoColumn> columns, {
    bool notify = true,
  });

  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter);

  void toggleExpandedRowGroup({
    required PlutoRow rowGroup,
    bool notify = true,
  });

  void sortRowGroup({
    required PlutoColumn column,
    required int Function(PlutoRow, PlutoRow) compare,
  });

  void removeRowAndGroupByKey(Iterable<Key> keys);
}

mixin RowGroupState implements IPlutoGridState {
  @override
  bool get hasRowGroups => _rowGroupColumns.isNotEmpty;

  List<PlutoColumn> _rowGroupColumns = [];

  @override
  Iterable<PlutoRow> get iterateRootRowGroup sync* {
    if (!hasRowGroups) {
      return;
    }

    final rootField = _rowGroupColumns.first.field;

    rootGroup(PlutoRow e) =>
        e.type.isGroup && e.type.group.groupField == rootField;

    for (final row in refRows.originalList.where(rootGroup)) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRowGroup sync* {
    if (!hasRowGroups) {
      return;
    }

    for (final row in _iterateRowGroup(iterateRootRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRowAndGroup sync* {
    for (final row in hasRowGroups
        ? _iterateRowAndGroup(iterateRootRowGroup)
        : refRows.originalList) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRow sync* {
    for (final row in hasRowGroups
        ? _iterateRow(iterateRootRowGroup)
        : refRows.originalList) {
      yield row;
    }
  }

  @override
  bool isGroupedRowColumn(PlutoColumn column) {
    return _rowGroupColumns.firstWhereOrNull((c) => c.field == column.field) !=
        null;
  }

  @override
  void setRowGroupByColumns(
    List<PlutoColumn> columns, {
    bool notify = true,
  }) {
    final groupedRows = PlutoRowGroupHelper.toGroupByColumns(
      columns: columns,
      rows: iterateRow,
    );

    refRows.clearFromOriginal();

    refRows.addAll(groupedRows);

    _rowGroupColumns = columns;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter) {
    _ensureRowGroups(() {
      if (filter == null) {
        void setFilter(FilteredList<PlutoRow> filteredList) {
          filteredList.setFilter(null);

          if (filteredList.isEmpty || !filteredList.first.type.isGroup) {
            return;
          }

          for (final c in filteredList) {
            setFilter(c.type.group.children);
          }
        }

        setFilter(refRows);
      } else {
        void setFilter(FilteredList<PlutoRow> filteredList) {
          filteredList.setFilter((row) {
            if (!row.type.isGroup) {
              return filter(row);
            }

            setFilter(row.type.group.children);
            return row.type.group.children.isNotEmpty;
          });
        }

        setFilter(refRows);
      }
    });
  }

  @override
  void toggleExpandedRowGroup({
    required PlutoRow rowGroup,
    bool notify = true,
  }) {
    if (!rowGroup.type.isGroup) {
      return;
    }

    if (rowGroup.type.group.expanded) {
      final Set<Key> removeKeys = {};

      addChildToCollapse(PlutoRow row) {
        for (final child in row.type.group.children) {
          removeKeys.add(child.key);
          if (child.type.isGroup) {
            addChildToCollapse(child);
          }
        }
      }

      addChildToCollapse(rowGroup);

      refRows.removeWhereFromOriginal((e) => removeKeys.contains(e.key));
    } else {
      final List<PlutoRow> addRows = [];

      addChildToExpand(PlutoRow row) {
        for (final child in row.type.group.children) {
          addRows.add(child);
          if (child.type.isGroup && child.type.group.expanded) {
            addChildToExpand(child);
          }
        }
      }

      addChildToExpand(rowGroup);

      final idx = refRows.indexOf(rowGroup);

      refRows.insertAll(idx + 1, addRows);
    }

    rowGroup.type.group.setExpanded(!rowGroup.type.group.expanded);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void sortRowGroup({
    required PlutoColumn column,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (!hasRowGroups) {
      return;
    }

    _ensureRowGroups(() {
      if (refRows.isEmpty) {
        return;
      }

      if (refRows.first.type.group.groupField == column.field) {
        refRows.sort(compare);

        return;
      }

      sortChildren(PlutoRow row) {
        assert(row.type.isGroup);

        if (row.type.group.childrenGroupField == column.field ||
            !row.type.group.children.first.type.isGroup) {
          row.type.group.children.sort(compare);

          return;
        }

        if (row.type.group.children.first.type.isGroup) {
          for (final child in row.type.group.children) {
            sortChildren(child);
          }
        }
      }

      for (final row in refRows) {
        sortChildren(row);
      }
    });
  }

  @override
  void removeRowAndGroupByKey(Iterable<Key> keys) {
    _ensureRowGroups(() {
      bool removeAll(PlutoRow row) {
        if (row.type.isGroup) {
          row.type.group.children.removeWhere(removeAll);
          if (row.type.group.children.isEmpty) {
            return true;
          }
        }
        return keys.contains(row.key);
      }

      refRows.removeWhere(removeAll);
    });
  }

  Iterable<PlutoRow> _iterateRow(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      if (row.type.isGroup) {
        for (final child in _iterateRow(row.type.group.children)) {
          yield child;
        }
      } else {
        yield row;
      }
    }
  }

  Iterable<PlutoRow> _iterateRowGroup(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      if (row.type.isGroup) {
        yield row;
        for (final child in _iterateRowGroup(row.type.group.children)) {
          yield child;
        }
      }
    }
  }

  Iterable<PlutoRow> _iterateRowAndGroup(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      yield row;
      if (row.type.isGroup) {
        for (final child in _iterateRowAndGroup(row.type.group.children)) {
          yield child;
        }
      }
    }
  }

  void _ensureRowGroups(void Function() callback) {
    assert(hasRowGroups);

    _collapseAllRowGroup();

    callback();

    _restoreExpandedRowGroup();
  }

  void _collapseAllRowGroup() {
    final mainGroup = _rowGroupColumns.first;

    isNotMainGroup(PlutoRow e) {
      return !e.type.isGroup || e.type.group.groupField != mainGroup.field;
    }

    refRows.removeWhereFromOriginal(isNotMainGroup);
  }

  void _restoreExpandedRowGroup() {
    expandedGroup(PlutoRow e) => e.type.isGroup && e.type.group.expanded;

    final Iterable<PlutoRow> expandedRows =
        refRows.where(expandedGroup).toList(growable: false);

    for (final rowGroup in expandedRows) {
      final List<PlutoRow> addRows = [];

      addExpandedChildren(PlutoRow row) {
        if (row.type.group.expanded) {
          for (final child in row.type.group.children) {
            addRows.add(child);
            if (child.type.isGroup && child.type.group.expanded) {
              addExpandedChildren(child);
            }
          }
        }
      }

      addExpandedChildren(rowGroup);

      final idx = refRows.indexOf(rowGroup);

      refRows.insertAll(idx + 1, addRows);
    }
  }
}

class PlutoRowGroupHelper {
  static Iterable<PlutoRow> toGroupByColumns({
    required List<PlutoColumn> columns,
    required Iterable<PlutoRow> rows,
  }) {
    final maxDepth = columns.length;
    int sortIdx = 0;

    List<PlutoRow> toGroup({
      required Iterable<PlutoRow> children,
      required int depth,
      String? previousKey,
    }) {
      final groupedColumn = columns[depth];

      return groupBy<PlutoRow, String>(children, (row) {
        return row.cells[columns[depth].field]!.value.toString();
      }).entries.map(
        (group) {
          final groupKey =
              previousKey == null ? group.key : '${previousKey}_${group.key}';

          final Key key = ValueKey(
            '${groupedColumn.field}_${groupKey}_rowGroup',
          );

          final nextDepth = depth + 1;

          final firstRow = children.first;

          final cells = <String, PlutoCell>{};

          final row = PlutoRow(
            cells: cells,
            key: ValueKey(key),
            sortIdx: sortIdx++,
            type: PlutoRowType.group(
              groupField: groupedColumn.field,
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
              value: e.key == groupedColumn.field ? group.key : null,
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
}
