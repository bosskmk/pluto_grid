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
      - Remove
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

  void toggleExpandedRowGroup({
    required PlutoRowGroup rowGroup,
    bool notify = true,
  });

  void sortRowGroup({
    required PlutoColumn column,
    required int Function(PlutoRow, PlutoRow) compare,
  });

  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter);
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

    rootGroup(e) => e.groupField == rootField;

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
  void toggleExpandedRowGroup({
    required PlutoRowGroup rowGroup,
    bool notify = true,
  }) {
    if (rowGroup.expanded) {
      final Set<Key> removeKeys = {};

      addChildrenKeys(PlutoRowGroup row) {
        for (final child in row.children) {
          removeKeys.add(child.key);
          if (child.type.isGroup) {
            addChildrenKeys(child as PlutoRowGroup);
          }
        }
      }

      addChildrenKeys(rowGroup);

      refRows.removeWhereFromOriginal((e) => removeKeys.contains(e.key));
    } else {
      final List<PlutoRow> addRows = [];

      addExpandedChildren(PlutoRowGroup row) {
        for (final child in row.children) {
          addRows.add(child);
          if (child.type.isGroup && child.expanded) {
            addExpandedChildren(child as PlutoRowGroup);
          }
        }
      }

      addExpandedChildren(rowGroup);

      final idx = refRows.indexOf(rowGroup);
      refRows.insertAll(idx + 1, addRows);
    }

    rowGroup.expanded = !rowGroup.expanded;

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
      if (refRows.first.groupField == column.field) {
        refRows.sort(compare);
      } else {
        sortChildren(PlutoRow row) {
          if (row.children.isEmpty) {
            return;
          }

          if (row.children.first.groupField == column.field ||
              row.children.first.groupField == '') {
            row.children.sort(compare);
            return;
          }

          for (final child in row.children) {
            sortChildren(child);
          }
        }

        for (final row in refRows) {
          sortChildren(row);
        }
      }
    });
  }

  @override
  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter) {
    _ensureRowGroups(() {
      if (filter == null) {
        void setFilter(FilteredList<PlutoRow> filteredList) {
          filteredList.setFilter(null);
          if (filteredList.isNotEmpty && filteredList.first.type.isGroup) {
            for (final c in filteredList) {
              setFilter(c.children as FilteredList<PlutoRow>);
            }
          }
        }

        setFilter(refRows);
      } else {
        void setFilter(FilteredList<PlutoRow> filteredList) {
          filteredList.setFilter((row) {
            if (row.type.isGroup) {
              setFilter(row.children as FilteredList<PlutoRow>);
              return row.children.isNotEmpty;
            }
            return filter(row);
          });
        }

        setFilter(refRows);
      }
    });
  }

  Iterable<PlutoRow> _iterateRow(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      if (row.type.isGroup) {
        for (final child in _iterateRow(row.children)) {
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
        for (final child in _iterateRowGroup(row.children)) {
          yield child;
        }
      }
    }
  }

  Iterable<PlutoRow> _iterateRowAndGroup(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      yield row;
      if (row.type.isGroup) {
        for (final child in _iterateRowAndGroup(row.children)) {
          yield child;
        }
      }
    }
  }

  void _ensureRowGroups(void Function() callback) {
    // collapse
    final mainGroup = _rowGroupColumns.first;
    refRows.removeWhereFromOriginal(
      (element) => mainGroup.field != element.groupField,
    );

    callback();

    // expand
    final List<PlutoRow> expandedRows =
        refRows.where((e) => e.expanded).toList();
    final length = expandedRows.length;

    for (int i = 0; i < length; i += 1) {
      final rowGroup = expandedRows[i] as PlutoRowGroup;

      final List<PlutoRow> addRows = [];

      addExpandedChildren(PlutoRowGroup row) {
        if (row.expanded) {
          for (final child in row.children) {
            addRows.add(child);
            if (child.type.isGroup && child.expanded) {
              addExpandedChildren(child as PlutoRowGroup);
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
  static Iterable<PlutoRowGroup> toGroupByColumns({
    required List<PlutoColumn> columns,
    required Iterable<PlutoRow> rows,
  }) {
    final maxDepth = columns.length;
    int sortIdx = 0;

    List<PlutoRowGroup> toGroup({
      required Iterable<PlutoRow> children,
      required int depth,
      String? previousKey,
    }) {
      final groupedColumn = columns[depth];

      return groupBy<PlutoRow, String>(children, (row) {
        return row.cells[columns[depth].field]!.value.toString();
      }).entries.map(
        (e) {
          final groupKey =
              previousKey == null ? e.key : '${previousKey}_${e.key}';

          final Key key = ValueKey(
            '${groupedColumn.field}_${groupKey}_rowGroup',
          );

          final nextDepth = depth + 1;

          return PlutoRowGroup.filledCells(
            key: key,
            sortIdx: sortIdx++,
            column: groupedColumn,
            children: FilteredList(
              initialList: nextDepth < maxDepth
                  ? toGroup(
                      children: e.value,
                      depth: nextDepth,
                      previousKey: groupKey,
                    ).toList()
                  : e.value.toList(),
            ),
          );
        },
      ).toList();
    }

    return toGroup(children: rows, depth: 0);
  }
}
