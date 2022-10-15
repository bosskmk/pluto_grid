import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

enum PlutoRowGroupDelegateType {
  tree,
  byColumn;

  bool get isTree => this == PlutoRowGroupDelegateType.tree;

  bool get isByColumn => this == PlutoRowGroupDelegateType.byColumn;
}

abstract class PlutoRowGroupDelegate {
  final countFormat = NumberFormat.compact();

  PlutoRowGroupDelegateType get type;

  bool get enabled;

  bool get showCount;

  bool get enableCompactCount;

  bool get showFirstExpandableIcon;

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

  String compactNumber(num count) {
    return countFormat.format(count);
  }
}

class PlutoRowGroupTreeDelegate extends PlutoRowGroupDelegate {
  final int? Function(PlutoColumn column) resolveColumnDepth;

  final bool Function(PlutoCell cell) showText;

  @override
  final bool showFirstExpandableIcon;

  @override
  final bool showCount;

  @override
  final bool enableCompactCount;

  PlutoRowGroupTreeDelegate({
    required this.resolveColumnDepth,
    required this.showText,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
  });

  @override
  PlutoRowGroupDelegateType get type => PlutoRowGroupDelegateType.tree;

  @override
  bool get enabled => true;

  @override
  bool isEditableCell(PlutoCell cell) => showText(cell);

  @override
  bool isExpandableCell(PlutoCell cell) {
    if (!cell.row.type.isGroup) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return cell.row.type.isGroup &&
        resolveColumnDepth(cell.column) == checkDepth;
  }

  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    if (rows.isEmpty) return rows.toList();

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows,
      (r) => r.type.isGroup,
    );

    for (final child in children) {
      setParent(PlutoRow r) => r.setParent(child);
      child.type.group.children.originalList.forEach(setParent);
    }

    return rows.toList();
  }

  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    rows.sort(compare);

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows.originalList,
      (r) => r.type.isGroup,
    );

    for (final child in children) {
      child.type.group.children.sort(compare);
    }
  }

  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);
  }
}

class PlutoRowGroupByColumnDelegate extends PlutoRowGroupDelegate {
  final List<PlutoColumn> columns;

  @override
  final bool showFirstExpandableIcon;

  @override
  final bool showCount;

  @override
  final bool enableCompactCount;

  PlutoRowGroupByColumnDelegate({
    required this.columns,
    this.showFirstExpandableIcon = false,
    this.showCount = true,
    this.enableCompactCount = true,
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
    if (cell.row.type.isNormal) return false;
    final int checkDepth = showFirstExpandableIcon ? 0 : cell.row.depth;
    return _columnDepth(cell.column) == checkDepth;
  }

  bool isRowGroupColumn(PlutoColumn column) {
    return visibleColumns.firstWhereOrNull((e) => e.field == column.field) !=
        null;
  }

  @override
  List<PlutoRow> toGroup({
    required Iterable<PlutoRow> rows,
  }) {
    if (rows.isEmpty) return rows.toList();
    assert(visibleColumns.isNotEmpty);

    final List<PlutoRow> groups = [];
    final List<List<PlutoRow>> groupStack = [];
    final List<PlutoRow> parentStack = [];
    final List<String> groupFields =
        visibleColumns.map((e) => e.field).toList();
    final List<String> groupKeyStack = [];
    final maxDepth = groupFields.length;

    List<PlutoRow>? currentGroups = groups;
    PlutoRow? currentParent;
    int depth = 0;
    int sortIdx = 0;
    List<Iterator<MapEntry<String, List<PlutoRow>>>> stack = [];
    Iterator<MapEntry<String, List<PlutoRow>>>? currentIter;
    currentIter = groupBy<PlutoRow, String>(
      rows,
      (r) => r.cells[groupFields[depth]]!.value.toString(),
    ).entries.iterator;

    while (currentIter != null || stack.isNotEmpty) {
      if (currentIter != null && depth < maxDepth && currentIter.moveNext()) {
        groupKeyStack.add(currentIter.current.key);
        final groupKeys = [
          visibleColumns[depth].field,
          groupKeyStack.join('_'),
          'rowGroup',
        ];

        final row = _createRowGroup(
          groupKeys: groupKeys,
          sortIdx: ++sortIdx,
          sampleRow: currentIter.current.value.first,
        );

        currentParent = parentStack.lastOrNull;
        if (currentParent != null) row.setParent(currentParent);

        parentStack.add(row);
        currentGroups!.add(row);
        stack.add(currentIter);
        groupStack.add(currentGroups);
        currentGroups = row.type.group.children;

        if (depth + 1 < maxDepth) {
          currentIter = groupBy<PlutoRow, String>(
            currentIter.current.value,
            (r) => r.cells[groupFields[depth + 1]]!.value.toString(),
          ).entries.iterator;
        }

        ++depth;
      } else {
        --depth;
        if (depth < 0) break;

        groupKeyStack.removeLast();
        currentParent = parentStack.lastOrNull;
        if (currentParent != null) parentStack.removeLast();
        currentIter = stack.lastOrNull;
        if (currentIter != null) stack.removeLast();

        if (depth + 1 == maxDepth) {
          int sortIdx = 0;
          for (final child in currentIter!.current.value) {
            currentGroups!.add(child);
            child.setParent(currentParent);
            child.sortIdx = ++sortIdx;
          }
        }

        currentGroups = groupStack.lastOrNull;
        if (currentGroups != null) groupStack.removeLast();
      }

      if (depth == 0) groupKeyStack.clear();
    }

    return groups;
  }

  @override
  void sort({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required int Function(PlutoRow, PlutoRow) compare,
  }) {
    if (rows.originalList.isEmpty) return;

    final depth = _columnDepth(column);

    if (depth == 0) {
      rows.sort(compare);
      return;
    }

    final children = PlutoRowGroupHelper.iterateWithFilter(
      rows.originalList,
      (r) => r.type.isGroup,
      (r) => _isFirstChildGroup(r)
          ? r.type.group.children.originalList.iterator
          : null,
    );

    for (final child in children) {
      if (_firstChildDepth(child) == depth) {
        child.type.group.children.sort(compare);
      }
    }
  }

  @override
  void filter({
    required FilteredList<PlutoRow> rows,
    required FilteredListFilter<PlutoRow>? filter,
  }) {
    if (rows.originalList.isEmpty) return;

    PlutoRowGroupHelper.applyFilter(rows: rows, filter: filter);
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

  PlutoRow _createRowGroup({
    required List<String> groupKeys,
    required int sortIdx,
    required PlutoRow sampleRow,
  }) {
    final cells = <String, PlutoCell>{};

    final groupKey = groupKeys.join('_');

    final row = PlutoRow(
      key: ValueKey(groupKey),
      cells: cells,
      sortIdx: sortIdx,
      type: PlutoRowType.group(
        children: FilteredList(initialList: []),
      ),
    );

    for (var e in sampleRow.cells.entries) {
      cells[e.key] = PlutoCell(
        value: visibleColumns.firstWhereOrNull((c) => c.field == e.key) != null
            ? e.value.value
            : null,
        key: ValueKey('${groupKey}_${e.key}_cell'),
      )
        ..setColumn(e.value.column)
        ..setRow(row);
    }

    return row;
  }
}
