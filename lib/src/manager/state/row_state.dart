import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_filtered_list/pluto_filtered_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow?> get rows;

  FilteredList<PlutoRow?>? refRows;

  List<PlutoRow?> get checkedRows;

  List<PlutoRow?> get unCheckedRows;

  bool get hasCheckedRow;

  bool get hasUnCheckedRow;

  /// Row index of currently selected cell.
  int? get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow? get currentRow;

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
}

mixin RowState implements IPlutoGridState {
  List<PlutoRow?> get rows => [...refRows!];

  FilteredList<PlutoRow?>? get refRows => _refRows;

  set refRows(FilteredList<PlutoRow?>? setRows) {
    PlutoGridStateManager.initializeRows(refColumns!.originalList, setRows);
    _refRows = setRows;
  }

  FilteredList<PlutoRow?>? _refRows;

  List<PlutoRow?> get checkedRows =>
      refRows!.where((row) => row!.checked!).toList(
            growable: false,
          );

  List<PlutoRow?> get unCheckedRows =>
      refRows!.where((row) => !row!.checked!).toList(
            growable: false,
          );

  bool get hasCheckedRow =>
      refRows!.firstWhere(
        (element) => element!.checked!,
        orElse: () => null,
      ) !=
      null;

  bool get hasUnCheckedRow =>
      refRows!.firstWhere(
        (element) => !element!.checked!,
        orElse: () => null,
      ) !=
      null;

  int? get currentRowIdx => currentCellPosition?.rowIdx;

  PlutoRow? get currentRow {
    if (currentRowIdx == null) {
      return null;
    }

    return refRows![currentRowIdx!];
  }

  int? getRowIdxByOffset(double offset) {
    offset -= bodyTopOffset - scroll!.verticalOffset;

    double currentOffset = 0.0;

    int? indexToMove;

    final int rowsLength = refRows!.length;

    for (var i = 0; i < rowsLength; i += 1) {
      if (currentOffset <= offset && offset < currentOffset + rowTotalHeight) {
        indexToMove = i;
        break;
      }

      currentOffset += rowTotalHeight;
    }

    return indexToMove;
  }

  PlutoRow? getRowByIdx(int? rowIdx) {
    if (rowIdx == null || rowIdx < 0 || refRows!.length - 1 < rowIdx) {
      return null;
    }

    return refRows![rowIdx];
  }

  PlutoRow getNewRow() {
    final cells = <String, PlutoCell>{};

    refColumns!.forEach((PlutoColumn column) {
      cells[column.field] = PlutoCell(
        value: column.type!.defaultValue,
      );
    });

    return PlutoRow(cells: cells);
  }

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

  void setRowChecked(
    PlutoRow? row,
    bool? flag, {
    bool notify = true,
  }) {
    final findRow = refRows!.firstWhere(
      (element) => element!.key == row!.key,
      orElse: () => null,
    );

    if (findRow == null) {
      return;
    }

    findRow.setChecked(flag);

    if (notify) {
      notifyListeners();
    }
  }

  void insertRows(int rowIdx, List<PlutoRow?>? rows) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    if (rowIdx < 0 || refRows!.length < rowIdx) {
      return;
    } else if (rowIdx == 0) {
      prependRows(rows);
      return;
    } else if (refRows!.length == rowIdx) {
      appendRows(rows);
      return;
    }

    if (hasSortedColumn) {
      final int? sortIdx = refRows![rowIdx]!.sortIdx;

      PlutoGridStateManager.initializeRows(
        refColumns,
        rows,
        start: sortIdx,
      );

      for (var i = 0; i < refRows!.length; i += 1) {
        if (sortIdx! <= refRows![i]!.sortIdx!) {
          refRows![i]!.sortIdx = refRows![i]!.sortIdx! + rows.length;
        }
      }

      _insertRows(rowIdx, rows, state: PlutoRowState.added);
    } else {
      _insertRows(rowIdx, rows, state: PlutoRowState.added);

      PlutoGridStateManager.initializeRows(
        refColumns,
        refRows,
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

  void prependNewRows({
    int count = 1,
  }) {
    prependRows(getNewRows(count: count));
  }

  void prependRows(List<PlutoRow?> rows) {
    if (rows.isEmpty) {
      return;
    }

    final start = (refRows!.isNotEmpty
            ? refRows!.map((row) => row!.sortIdx ?? 0).reduce(min)
            : 0) -
        rows.length;

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

  void appendNewRows({
    int count = 1,
  }) {
    appendRows(getNewRows(count: count));
  }

  void appendRows(List<PlutoRow?> rows) {
    if (rows.isEmpty) {
      return;
    }

    final start = refRows!.isNotEmpty
        ? refRows!.map((row) => row!.sortIdx ?? 0).reduce(max) + 1
        : 0;

    PlutoGridStateManager.initializeRows(
      refColumns,
      rows,
      start: start,
    );

    refRows!.addAll(rows);

    notifyListeners();
  }

  void removeCurrentRow() {
    if (currentRowIdx == null) {
      return;
    }

    refRows!.removeAt(currentRowIdx!);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  void removeRows(
    List<PlutoRow?>? rows, {
    bool notify = true,
  }) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    final List<Key> removeKeys =
        rows.map((e) => e!.key).toList(growable: false);

    if (currentRowIdx != null &&
        refRows!.length > currentRowIdx! &&
        removeKeys.contains(refRows![currentRowIdx!]!.key)) {
      resetCurrentState(notify: false);
    }

    Key? selectingCellKey;

    if (hasCurrentSelectingPosition) {
      selectingCellKey = refRows![currentSelectingPosition!.rowIdx!]!
          .cells
          .entries
          .elementAt(currentSelectingPosition!.columnIdx!)
          .value
          .key;
    }

    refRows!.removeWhere((row) => removeKeys.contains(row!.key));

    updateCurrentCellPosition(notify: false);

    setCurrentSelectingPositionByCellKey(selectingCellKey, notify: false);

    currentSelectingRows.removeWhere((row) => removeKeys.contains(row!.key));

    if (notify) {
      notifyListeners();
    }
  }

  void moveRowsByOffset(
    List<PlutoRow?>? rows,
    double offset, {
    bool notify = true,
  }) {
    int? indexToMove = getRowIdxByOffset(offset);

    moveRowsByIndex(rows, indexToMove, notify: notify);
  }

  void moveRowsByIndex(
    List<PlutoRow?>? rows,
    int? indexToMove, {
    bool notify = true,
  }) {
    if (indexToMove == null) {
      return;
    } else if (indexToMove + rows!.length > refRows!.length) {
      indexToMove = refRows!.length - rows.length;
    }

    rows.forEach((row) {
      refRows!.remove(row);
    });

    refRows!.insertAll(indexToMove, rows.cast<PlutoRow>());

    int sortIdx = 0;

    refRows!.forEach((element) {
      element!.sortIdx = sortIdx++;
    });

    updateCurrentCellPosition(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void toggleAllRowChecked(
    bool? flag, {
    bool notify = true,
  }) {
    refRows!.forEach((e) {
      e!.setChecked(flag == true);
    });

    if (notify) {
      notifyListeners();
    }
  }

  void _insertRows(
    int index,
    List<PlutoRow?> rows, {
    PlutoRowState? state,
  }) {
    if (state != null) {
      for (var row in rows) {
        row!.setState(state);
      }
    }

    refRows!.insertAll(index, rows.cast<PlutoRow>());
  }
}
