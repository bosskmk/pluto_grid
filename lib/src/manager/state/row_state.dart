import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  FilteredList<PlutoRow> refRows = FilteredList();

  List<PlutoRow> get checkedRows;

  List<PlutoRow> get unCheckedRows;

  bool get hasCheckedRow;

  bool get hasUnCheckedRow;

  /// Property for [tristate] value in [Checkbox] widget.
  bool? get tristateCheckedRow;

  /// Row index of currently selected cell.
  int? get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow? get currentRow;

  PlutoRowColorCallback? get rowColorCallback;

  int? getRowIdxByOffset(double offset);

  PlutoRow? getRowByIdx(int rowIdx);

  PlutoRow getNewRow();

  List<PlutoRow> getNewRows({
    int count = 1,
  });

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  });

  void setRowChecked(
    PlutoRow row,
    bool flag, {
    bool notify = true,
  });

  void insertRows(int rowIdx, List<PlutoRow> rows);

  void prependNewRows({
    int count = 1,
  });

  void prependRows(List<PlutoRow> rows);

  void appendNewRows({
    int count = 1,
  });

  void appendRows(List<PlutoRow> rows);

  void removeCurrentRow();

  void removeRows(List<PlutoRow> rows);

  void moveRowsByOffset(
    List<PlutoRow> rows,
    double offset, {
    bool notify = true,
  });

  void moveRowsByIndex(
    List<PlutoRow> rows,
    int index, {
    bool notify = true,
  });

  void toggleAllRowChecked(
    bool flag, {
    bool notify = true,
  });

  /// Dynamically change the background color of row by implementing a callback function.
  void setRowColorCallback(PlutoRowColorCallback rowColorCallback);
}

mixin RowState implements IPlutoGridState {
  @override
  List<PlutoRow> get rows => [...refRows];

  @override
  FilteredList<PlutoRow> get refRows => _refRows;

  @override
  set refRows(FilteredList<PlutoRow> setRows) {
    PlutoGridStateManager.initializeRows(refColumns.originalList, setRows);
    _refRows = setRows;
  }

  FilteredList<PlutoRow> _refRows = FilteredList();

  @override
  List<PlutoRow> get checkedRows => refRows.where((row) => row.checked!).toList(
        growable: false,
      );

  @override
  List<PlutoRow> get unCheckedRows =>
      refRows.where((row) => !row.checked!).toList(
            growable: false,
          );

  @override
  bool get hasCheckedRow =>
      refRows.firstWhereOrNull((element) => element.checked!) != null;

  @override
  bool get hasUnCheckedRow =>
      refRows.firstWhereOrNull((element) => !element.checked!) != null;

  @override
  bool? get tristateCheckedRow {
    final length = refRows.length;

    final Set<bool> checkSet = {};

    for (var i = 0; i < length; i += 1) {
      checkSet.add(refRows[i].checked == true);
    }

    return checkSet.length == 2 ? null : checkSet.first;
  }

  @override
  int? get currentRowIdx => currentCellPosition?.rowIdx;

  @override
  PlutoRow? get currentRow {
    if (currentRowIdx == null) {
      return null;
    }

    return refRows[currentRowIdx!];
  }

  PlutoRowColorCallback? _rowColorCallback;

  @override
  PlutoRowColorCallback? get rowColorCallback {
    return _rowColorCallback;
  }

  @override
  int? getRowIdxByOffset(double offset) {
    offset -= bodyTopOffset - scroll!.verticalOffset;

    double currentOffset = 0.0;

    int? indexToMove;

    final int rowsLength = refRows.length;

    for (var i = 0; i < rowsLength; i += 1) {
      if (currentOffset <= offset && offset < currentOffset + rowTotalHeight) {
        indexToMove = i;
        break;
      }

      currentOffset += rowTotalHeight;
    }

    return indexToMove;
  }

  @override
  PlutoRow? getRowByIdx(int? rowIdx) {
    if (rowIdx == null || rowIdx < 0 || refRows.length - 1 < rowIdx) {
      return null;
    }

    return refRows[rowIdx];
  }

  @override
  PlutoRow getNewRow() {
    final cells = <String, PlutoCell>{};

    for (var column in refColumns) {
      cells[column.field] = PlutoCell(
        value: column.type.defaultValue,
      );
    }

    return PlutoRow(cells: cells);
  }

  @override
  List<PlutoRow> getNewRows({
    int count = 1,
  }) {
    List<PlutoRow> rows = [];

    for (var i = 0; i < count; i += 1) {
      rows.add(getNewRow());
    }

    if (rows.isEmpty) {
      return [];
    }

    return rows;
  }

  @override
  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  }) {
    int sortIdx = start;

    return rows.map((row) {
      row.sortIdx = sortIdx;

      sortIdx = increase ? ++sortIdx : --sortIdx;

      return row;
    }).toList(growable: false);
  }

  @override
  void setRowChecked(
    PlutoRow row,
    bool flag, {
    bool notify = true,
  }) {
    final findRow = refRows.firstWhereOrNull(
      (element) => element.key == row.key,
    );

    if (findRow == null) {
      return;
    }

    findRow.setChecked(flag);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void insertRows(int rowIdx, List<PlutoRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    if (rowIdx < 0 || refRows.length < rowIdx) {
      return;
    }

    if (hasSortedColumn) {
      final originalRowIdx = page > 1 ? rowIdx + (page - 1) * pageSize : rowIdx;

      final int? sortIdx = refRows.originalList[originalRowIdx].sortIdx;

      PlutoGridStateManager.initializeRows(
        refColumns,
        rows,
        start: sortIdx,
      );

      for (var i = 0; i < refRows.originalLength; i += 1) {
        if (sortIdx! <= refRows.originalList[i].sortIdx!) {
          refRows.originalList[i].sortIdx =
              refRows.originalList[i].sortIdx! + rows.length;
        }
      }

      _insertRows(rowIdx, rows, state: PlutoRowState.added);
    } else {
      _insertRows(rowIdx, rows, state: PlutoRowState.added);

      PlutoGridStateManager.initializeRows(
        refColumns,
        refRows.originalList,
        forceApplySortIdx: true,
      );
    }

    /// Update currentRowIdx
    if (currentCell != null) {
      updateCurrentCellPosition(notify: false);

      // todo : whether to apply scrolling.
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null &&
        rowIdx <= currentSelectingPosition!.rowIdx!) {
      setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: currentSelectingPosition!.columnIdx,
          rowIdx: rows.length + currentSelectingPosition!.rowIdx!,
        ),
        notify: false,
      );
    }

    notifyListeners();
  }

  @override
  void prependNewRows({
    int count = 1,
  }) {
    prependRows(getNewRows(count: count));
  }

  @override
  void prependRows(List<PlutoRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    final minSortIdx = (refRows.isNotEmpty
        ? refRows.first.sortIdx == null
            ? 0
            : refRows.first.sortIdx!
        : 0);

    final start = minSortIdx - rows.length;

    for (var element in refRows.originalList) {
      if (element.sortIdx != null && element.sortIdx! < minSortIdx) {
        element.sortIdx = element.sortIdx! - rows.length;
      }
    }

    PlutoGridStateManager.initializeRows(
      refColumns,
      rows,
      start: start,
    );

    _insertRows(0, rows, state: PlutoRowState.added);

    /// Update currentRowIdx
    if (currentCell != null) {
      setCurrentCellPosition(
        PlutoGridCellPosition(
          columnIdx: currentCellPosition!.columnIdx,
          rowIdx: rows.length + currentRowIdx!,
        ),
        notify: false,
      );

      double offsetToMove = rows.length * rowTotalHeight;

      scrollByDirection(PlutoMoveDirection.up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: currentSelectingPosition!.columnIdx,
          rowIdx: rows.length + currentSelectingPosition!.rowIdx!,
        ),
        notify: false,
      );
    }

    notifyListeners();
  }

  @override
  void appendNewRows({
    int count = 1,
  }) {
    appendRows(getNewRows(count: count));
  }

  @override
  void appendRows(List<PlutoRow> rows) {
    if (rows.isEmpty) {
      return;
    }

    final start = refRows.isNotEmpty
        ? refRows.last.sortIdx == null
            ? 1
            : refRows.last.sortIdx! + 1
        : 0;

    for (var element in refRows.originalList) {
      if (element.sortIdx != null && element.sortIdx! > start - 1) {
        element.sortIdx = element.sortIdx! + rows.length;
      }
    }

    PlutoGridStateManager.initializeRows(
      refColumns,
      rows,
      start: start,
    );

    _insertRows(refRows.length, rows, state: PlutoRowState.added);

    notifyListeners();
  }

  @override
  void removeCurrentRow() {
    if (currentRowIdx == null) {
      return;
    }

    refRows.removeAt(currentRowIdx!);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  @override
  void removeRows(
    List<PlutoRow> rows, {
    bool notify = true,
  }) {
    if (rows.isEmpty) {
      return;
    }

    final Set<Key> removeKeys = Set.from(rows.map((e) => e.key));

    if (currentRowIdx != null &&
        refRows.length > currentRowIdx! &&
        removeKeys.contains(refRows[currentRowIdx!].key)) {
      resetCurrentState(notify: false);
    }

    Key? selectingCellKey;

    if (hasCurrentSelectingPosition) {
      selectingCellKey = refRows
          .originalList[currentSelectingPosition!.rowIdx!].cells.entries
          .elementAt(currentSelectingPosition!.columnIdx!)
          .value
          .key;
    }

    refRows.removeWhereFromOriginal((row) => removeKeys.contains(row.key));

    updateCurrentCellPosition(notify: false);

    setCurrentSelectingPositionByCellKey(selectingCellKey, notify: false);

    currentSelectingRows.removeWhere((row) => removeKeys.contains(row.key));

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void moveRowsByOffset(
    List<PlutoRow> rows,
    double offset, {
    bool notify = true,
  }) {
    int? indexToMove = getRowIdxByOffset(offset);

    moveRowsByIndex(rows, indexToMove, notify: notify);
  }

  @override
  void moveRowsByIndex(
    List<PlutoRow> rows,
    int? indexToMove, {
    bool notify = true,
  }) {
    if (indexToMove == null) {
      return;
    }

    if (indexToMove + rows.length > refRows.length) {
      indexToMove = refRows.length - rows.length;
    }

    for (var row in rows) {
      refRows.removeFromOriginal(row);
    }

    final originalRowIdx =
        page > 1 ? indexToMove + (page - 1) * pageSize : indexToMove;

    if (originalRowIdx >= refRows.originalLength) {
      refRows.addAll(rows.cast<PlutoRow>());
    } else {
      refRows.insertAll(indexToMove, rows.cast<PlutoRow>());
    }

    int sortIdx = 0;

    for (var element in refRows.originalList) {
      element.sortIdx = sortIdx++;
    }

    updateCurrentCellPosition(notify: false);

    if (onRowsMoved != null) {
      onRowsMoved!(PlutoGridOnRowsMovedEvent(
        idx: indexToMove,
        rows: rows,
      ));
    }

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void toggleAllRowChecked(
    bool? flag, {
    bool notify = true,
  }) {
    for (var e in refRows) {
      e.setChecked(flag == true);
    }

    if (notify) {
      notifyListeners();
    }
  }

  void _insertRows(
    int index,
    List<PlutoRow> rows, {
    PlutoRowState? state,
  }) {
    if (rows.isEmpty) {
      return;
    }

    if (state != null) {
      for (var row in rows) {
        row.setState(state);
      }
    }

    final originalRowIdx = page > 1 ? index + (page - 1) * pageSize : index;

    if (originalRowIdx >= refRows.originalLength) {
      refRows.addAll(rows.cast<PlutoRow>());
    } else {
      refRows.insertAll(index, rows.cast<PlutoRow>());
    }

    if (isPaginated) {
      setPage(page, notify: false);
    }
  }

  @override
  void setRowColorCallback(PlutoRowColorCallback? rowColorCallback) {
    _rowColorCallback = rowColorCallback;
  }
}
