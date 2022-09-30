import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

/*
  todo
    ColumnGroup
      - Apply changed depth when removing column
    Row
      - Move
      - Check
      - Improve initializeRows when adding rows
    Test
      - add, insert, prepend, append rows with pagination, sort, filter
 */

abstract class IRowGroupState {
  bool get hasRowGroups;

  bool get enabledRowGroups;

  PlutoRowGroupDelegate? get rowGroupDelegate;

  Iterable<PlutoRow> get iterateMainRowGroup;

  Iterable<PlutoRow> get iterateRowGroup;

  Iterable<PlutoRow> get iterateRowAndGroup;

  Iterable<PlutoRow> get iterateRow;

  bool isMainRow(PlutoRow row);

  bool isNotMainGroupedRow(PlutoRow row);

  bool isExpandedGroupedRow(PlutoRow row);

  void setRowGroup(
    PlutoRowGroupDelegate? delegate, {
    bool notify = true,
  });

  void toggleExpandedRowGroup({
    required PlutoRow rowGroup,
    bool notify = true,
  });

  @protected
  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter);

  @protected
  void sortRowGroup({
    required PlutoColumn column,
    required int Function(PlutoRow, PlutoRow) compare,
  });

  @protected
  void insertRowGroup(int index, List<PlutoRow> rows);

  @protected
  void removeRowAndGroupByKey(Iterable<Key> keys);

  @protected
  void removeColumnsInRowGroupByColumn(
    List<PlutoColumn> columns, {
    bool notify = true,
  });

  @protected
  void updateRowGroupByHideColumn(List<PlutoColumn> columns);
}

mixin RowGroupState implements IPlutoGridState {
  @override
  bool get hasRowGroups => _rowGroupDelegate != null;

  @override
  bool get enabledRowGroups => _rowGroupDelegate?.enabled == true;

  bool _previousEnabledRowGroups = false;

  PlutoRowGroupDelegate? _rowGroupDelegate;

  @override
  PlutoRowGroupDelegate? get rowGroupDelegate => _rowGroupDelegate;

  @override
  Iterable<PlutoRow> get iterateMainRowGroup sync* {
    for (final row in refRows.originalList.where(isMainRow)) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRowGroup sync* {
    for (final row in _iterateRowGroup(iterateMainRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRowAndGroup sync* {
    for (final row in _iterateRowAndGroup(iterateMainRowGroup)) {
      yield row;
    }
  }

  @override
  Iterable<PlutoRow> get iterateRow sync* {
    for (final row in _iterateRow(iterateMainRowGroup)) {
      yield row;
    }
  }

  @override
  bool isMainRow(PlutoRow row) => row.isMain;

  @override
  bool isNotMainGroupedRow(PlutoRow row) => !isMainRow(row);

  @override
  bool isExpandedGroupedRow(PlutoRow row) {
    return row.type.isGroup && row.type.group.expanded;
  }

  @override
  void setRowGroup(
    PlutoRowGroupDelegate? delegate, {
    bool notify = true,
  }) {
    _rowGroupDelegate = delegate;

    _updateRowGroup();

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void toggleExpandedRowGroup({
    required PlutoRow rowGroup,
    bool notify = true,
  }) {
    assert(enabledRowGroups);

    if (!rowGroup.type.isGroup || rowGroup.type.group.children.isEmpty) {
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

    if (isPaginated) {
      resetPage(resetCurrentState: false, notify: false);
    }

    updateCurrentCellPosition(notify: false);

    clearCurrentSelecting(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  @protected
  void setRowGroupFilter(FilteredListFilter<PlutoRow>? filter) {
    assert(enabledRowGroups);

    _ensureRowGroups(() {
      _rowGroupDelegate!.filter(rows: refRows, filter: filter);
    });
  }

  @override
  @protected
  void sortRowGroup({
    required PlutoColumn column,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    assert(enabledRowGroups);

    _ensureRowGroups(() {
      _rowGroupDelegate!.sort(column: column, rows: refRows, compare: compare);
    });
  }

  @override
  @protected
  void insertRowGroup(int index, List<PlutoRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    assert(enabledRowGroups);

    if (!rows.first.initialized) {
      PlutoGridStateManager.initializeRows(
        refColumns.originalList,
        rows,
        forceApplySortIdx: false,
      );
    }

    final bool append = index >= refRows.length;
    final targetIdx = append ? refRows.length - 1 : index;
    final target = refRows.isEmpty ? null : refRows[targetIdx];

    if (_rowGroupDelegate is PlutoRowGroupByColumnDelegate && !append) {
      _updateCellsByTargetForGroupByColumn(rows: rows, target: target);
    }

    final grouped = _rowGroupDelegate!.toGroup(rows: rows);

    bool findByTargetKey(PlutoRow e) => e.key == target?.key;

    bool hasChildrenGroup(PlutoRow found) {
      return found.type.isGroup &&
          found.type.group.children.originalList.isNotEmpty &&
          found.type.group.children.originalList.first.type.isGroup;
    }

    void updateSortIdx({
      required List<PlutoRow> rows,
      required int start,
      required int compare,
      required int increase,
    }) {
      if (hasSortedColumn) {
        for (final row in rows) {
          if (compare >= row.sortIdx) {
            row.sortIdx += increase;
          }
        }
      } else {
        final length = rows.length;
        for (int i = start; i < length; i += 1) {
          rows[i].sortIdx += increase;
        }
      }
    }

    void insertOrAdd({
      required FilteredList<PlutoRow> ref,
      required PlutoRow row,
    }) {
      final insertIdx = ref.indexWhere(findByTargetKey);
      if (insertIdx > -1 && !append) {
        row.sortIdx = ref[insertIdx].sortIdx;
        updateSortIdx(
          rows: ref,
          start: insertIdx,
          compare: row.sortIdx,
          increase: 1,
        );
        ref.insert(insertIdx, row);
      } else {
        ref.add(row);
      }
    }

    void insertOrAddToChildren({
      required PlutoRow found,
      required PlutoRow row,
    }) {
      final insertIdx = found.type.group.children.indexWhere(findByTargetKey);
      if (insertIdx > -1 && !append) {
        final length = row.type.group.children.length;
        for (int i = 0; i < length; i += 1) {
          row.type.group.children[i].sortIdx =
              found.type.group.children[insertIdx].sortIdx + i;
        }
        updateSortIdx(
          rows: found.type.group.children,
          start: insertIdx,
          compare: found.type.group.children[insertIdx].sortIdx,
          increase: row.type.group.children.length,
        );
        found.type.group.children.insertAll(
          insertIdx,
          row.type.group.children,
        );
      } else {
        found.type.group.children.addAll(row.type.group.children);
      }
    }

    void addAllGroupByColumn(
      Iterable<PlutoRow> groupedRows,
      FilteredList<PlutoRow> ref,
    ) {
      for (final row in groupedRows) {
        findByRowKey(PlutoRow e) => e.key == row.key;
        final found = ref.originalList.firstWhereOrNull(findByRowKey);

        if (found == null) {
          insertOrAdd(ref: ref, row: row);
        } else {
          if (hasChildrenGroup(found)) {
            addAllGroupByColumn(
              row.type.group.children,
              found.type.group.children,
            );
          } else {
            insertOrAddToChildren(found: found, row: row);
          }
        }

        if (row.type.isGroup) {
          setParent(e) => e.setParent(found ?? row);
          row.type.group.children.originalList.forEach(setParent);
        }
      }
    }

    void addAllGroupTree() {
      final targetParent = target?.parent?.type.group.children ?? refRows;

      if (append) {
        targetParent.addAll(grouped);
        return;
      }

      final targetParentList = targetParent.filterOrOriginalList;
      final insertIdx = targetParentList.indexWhere(findByTargetKey);
      assert(insertIdx != -1);

      final length = grouped.length;
      for (int i = 0; i < length; i += 1) {
        grouped[i].sortIdx = (target?.sortIdx ?? 0) + i;
      }

      updateSortIdx(
        rows: targetParent.originalList,
        start: target == null ? 0 : targetParent.originalList.indexOf(target),
        compare: target?.sortIdx ?? 0,
        increase: grouped.length,
      );

      targetParent.insertAll(insertIdx, grouped);
      setParent(PlutoRow e) => e.setParent(target?.parent);
      grouped.forEach(setParent);
    }

    _ensureRowGroups(() {
      switch (_rowGroupDelegate!.type) {
        case PlutoRowGroupDelegateType.tree:
          addAllGroupTree();
          break;
        case PlutoRowGroupDelegateType.byColumn:
          addAllGroupByColumn(grouped, refRows);
          break;
      }
    });
  }

  @override
  @protected
  void removeRowAndGroupByKey(Iterable<Key> keys) {
    if (keys.isEmpty) {
      return;
    }

    assert(enabledRowGroups);

    _ensureRowGroups(() {
      bool removeAll(PlutoRow row) {
        if (row.type.isGroup) {
          row.type.group.children.removeWhereFromOriginal(removeAll);
          if (row.type.group.children.originalList.isEmpty) {
            return true;
          }
        }
        return keys.contains(row.key);
      }

      refRows.removeWhereFromOriginal(removeAll);
    });
  }

  @override
  @protected
  void removeColumnsInRowGroupByColumn(
    List<PlutoColumn> columns, {
    bool notify = true,
  }) {
    if (columns.isEmpty || _rowGroupDelegate?.type.isByColumn != true) {
      return;
    }

    final delegate = _rowGroupDelegate as PlutoRowGroupByColumnDelegate;

    final Set<Key> removeKeys = Set.from(columns.map((e) => e.key));

    isNotRemoved(e) => !removeKeys.contains(e.key);

    final remaining =
        delegate.columns.where(isNotRemoved).toList(growable: false);

    if (remaining.length == delegate.columns.length) {
      return;
    }

    delegate.columns.clear();

    delegate.columns.addAll(remaining);

    _updateRowGroup();
  }

  @override
  @protected
  void updateRowGroupByHideColumn(List<PlutoColumn> columns) {
    if (rowGroupDelegate?.type.isByColumn != true) {
      return;
    }

    final delegate = rowGroupDelegate as PlutoRowGroupByColumnDelegate;

    final Set<Key> updateKeys = Set.from(columns.map((e) => e.key));

    isUpdated(e) => updateKeys.contains(e.key);

    final updated = delegate.columns.firstWhereOrNull(isUpdated) != null;

    if (updated) {
      _updateRowGroup();
    }
  }

  Iterable<PlutoRow> _iterateRow(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      if (row.type.isGroup) {
        for (final child in _iterateRow(row.type.group.children.originalList)) {
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
        for (final child
            in _iterateRowGroup(row.type.group.children.originalList)) {
          yield child;
        }
      }
    }
  }

  Iterable<PlutoRow> _iterateRowAndGroup(Iterable<PlutoRow> rows) sync* {
    for (final row in rows) {
      yield row;
      if (row.type.isGroup) {
        for (final child
            in _iterateRowAndGroup(row.type.group.children.originalList)) {
          yield child;
        }
      }
    }
  }

  void _ensureRowGroups(void Function() callback) {
    assert(enabledRowGroups);

    _collapseAllRowGroup();

    callback();

    _restoreExpandedRowGroup();
  }

  void _collapseAllRowGroup() {
    refRows.removeWhereFromOriginal(isNotMainGroupedRow);
  }

  void _restoreExpandedRowGroup() {
    final Iterable<PlutoRow> expandedRows = refRows.filterOrOriginalList
        .where(isExpandedGroupedRow)
        .toList(growable: false);

    bool toResetPage = false;

    if (isPaginated) {
      refRows.setFilterRange(null);
      toResetPage = true;
    }

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

      final idx = refRows.filterOrOriginalList.indexOf(rowGroup);

      refRows.insertAll(idx + 1, addRows);
    }

    if (toResetPage) {
      resetPage(resetCurrentState: false, notify: false);
    }
  }

  void _updateCellsByTargetForGroupByColumn({
    required List<PlutoRow> rows,
    required PlutoRow? target,
  }) {
    if (target == null) {
      return;
    }

    assert(_rowGroupDelegate is PlutoRowGroupByColumnDelegate);

    final delegate = _rowGroupDelegate as PlutoRowGroupByColumnDelegate;

    final depth = target.depth;

    final groupedColumn = delegate.columns.getRange(0, depth);

    for (final row in rows) {
      for (final column in groupedColumn) {
        row.cells[column.field]!.value = target.cells[column.field]!.value;
      }
    }
  }

  void _updateRowGroup() {
    assert(hasRowGroups);

    List<PlutoRow> rows;

    final previousRows = _previousEnabledRowGroups
        ? _iterateRow(iterateMainRowGroup)
        : refRows.originalList;

    if (enabledRowGroups == true) {
      rows = _rowGroupDelegate!.toGroup(rows: previousRows);
    } else {
      rows = previousRows.toList();
    }

    _previousEnabledRowGroups = enabledRowGroups;

    refRows.clearFromOriginal();

    refRows.addAll(rows);

    if (isPaginated) {
      resetPage(resetCurrentState: true, notify: false);
    }
  }
}
