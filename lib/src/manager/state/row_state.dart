part of '../../../pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  FilteredList<PlutoRow> _rows;

  List<PlutoRow> get checkedRows;

  List<PlutoRow> get unCheckedRows;

  bool get hasCheckedRow;

  bool get hasUnCheckedRow;

  /// Row index of currently selected cell.
  int get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow get currentRow;

  int getRowIdxByOffset(double offset);

  PlutoRow getRowByIdx(int rowIdx);

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

  void moveRows(
    List<PlutoRow> rows,
    double offset, {
    bool notify = true,
  });

  void toggleAllRowChecked(
    bool flag, {
    bool notify = true,
  });
}

mixin RowState implements IPlutoState {
  List<PlutoRow> get rows => [..._rows];

  FilteredList<PlutoRow> _rows;

  List<PlutoRow> get checkedRows => _rows.where((row) => row.checked).toList(
        growable: false,
      );

  List<PlutoRow> get unCheckedRows => _rows.where((row) => !row.checked).toList(
        growable: false,
      );

  bool get hasCheckedRow =>
      _rows.firstWhere(
        (element) => element.checked,
        orElse: () => null,
      ) !=
      null;

  bool get hasUnCheckedRow =>
      _rows.firstWhere(
        (element) => !element.checked,
        orElse: () => null,
      ) !=
      null;

  int get currentRowIdx => currentCellPosition?.rowIdx;

  PlutoRow get currentRow {
    if (currentRowIdx == null) {
      return null;
    }

    return _rows[currentRowIdx];
  }

  int getRowIdxByOffset(double offset) {
    offset -= bodyTopOffset - scroll.verticalOffset;

    double currentOffset = 0.0;

    int indexToMove;

    final int rowsLength = _rows.length;

    for (var i = 0; i < rowsLength; i += 1) {
      if (currentOffset <= offset && offset < currentOffset + rowTotalHeight) {
        indexToMove = i;
        break;
      }

      currentOffset += rowTotalHeight;
    }

    return indexToMove;
  }

  PlutoRow getRowByIdx(int rowIdx) {
    if (rowIdx == null || rowIdx < 0 || _rows.length - 1 < rowIdx) {
      return null;
    }

    return _rows[rowIdx];
  }

  PlutoRow getNewRow() {
    final cells = <String, PlutoCell>{};

    _columns.forEach((PlutoColumn column) {
      cells[column.field] = PlutoCell(
        value: column.type.defaultValue,
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
    PlutoRow row,
    bool flag, {
    bool notify = true,
  }) {
    final findRow = _rows.firstWhere(
      (element) => element.key == row.key,
      orElse: () => null,
    );

    if (findRow == null) {
      return;
    }

    findRow._setChecked(flag);

    if (notify) {
      notifyListeners();
    }
  }

  void insertRows(int rowIdx, List<PlutoRow> rows) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    if (rowIdx < 0 || _rows.length < rowIdx) {
      return;
    } else if (rowIdx == 0) {
      prependRows(rows);
      return;
    } else if (_rows.length == rowIdx) {
      appendRows(rows);
      return;
    }

    if (hasSortedColumn) {
      final int sortIdx = _rows[rowIdx].sortIdx;

      PlutoStateManager.initializeRows(
        _columns,
        rows,
        start: sortIdx,
      );

      for (var i = 0; i < _rows.length; i += 1) {
        if (sortIdx <= _rows[i].sortIdx) {
          _rows[i].sortIdx = _rows[i].sortIdx + rows.length;
        }
      }

      _insertRows(rowIdx, rows, state: PlutoRowState.added);
    } else {
      _insertRows(rowIdx, rows, state: PlutoRowState.added);

      PlutoStateManager.initializeRows(
        _columns,
        _rows,
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
        rowIdx <= currentSelectingPosition.rowIdx) {
      setCurrentSelectingPosition(
        cellPosition: PlutoCellPosition(
          columnIdx: currentSelectingPosition.columnIdx,
          rowIdx: rows.length + currentSelectingPosition.rowIdx,
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

  void prependRows(List<PlutoRow> rows) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    final start = (_rows.isNotEmpty
            ? _rows.map((row) => row.sortIdx ?? 0).reduce(min)
            : 0) -
        rows.length;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      start: start,
    );

    _insertRows(0, rows, state: PlutoRowState.added);

    /// Update currentRowIdx
    if (currentCell != null) {
      setCurrentCellPosition(
        PlutoCellPosition(
          columnIdx: currentCellPosition.columnIdx,
          rowIdx: rows.length + currentRowIdx,
        ),
        notify: false,
      );

      double offsetToMove = rows.length * rowTotalHeight;

      scrollByDirection(MoveDirection.up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        cellPosition: PlutoCellPosition(
          columnIdx: currentSelectingPosition.columnIdx,
          rowIdx: rows.length + currentSelectingPosition.rowIdx,
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

  void appendRows(List<PlutoRow> rows) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    final start = _rows.isNotEmpty
        ? _rows.map((row) => row.sortIdx ?? 0).reduce(max) + 1
        : 0;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      start: start,
    );

    _rows.addAll(rows);

    notifyListeners();
  }

  void removeCurrentRow() {
    if (currentRowIdx == null) {
      return;
    }

    _rows.removeAt(currentRowIdx);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  void removeRows(
    List<PlutoRow> rows, {
    bool notify = true,
  }) {
    if (rows == null || rows.isEmpty) {
      return;
    }

    final List<Key> removeKeys = rows.map((e) => e.key).toList(growable: false);

    if (currentRowIdx != null &&
        _rows.length > currentRowIdx &&
        removeKeys.contains(_rows[currentRowIdx].key)) {
      resetCurrentState(notify: false);
    }

    Key selectingCellKey;

    if (hasCurrentSelectingPosition) {
      selectingCellKey = _rows[currentSelectingPosition.rowIdx]
          .cells
          .entries
          .elementAt(currentSelectingPosition.columnIdx)
          .value
          .key;
    }

    _rows.removeWhere((row) => removeKeys.contains(row.key));

    updateCurrentCellPosition(notify: false);

    setCurrentSelectingPositionByCellKey(selectingCellKey, notify: false);

    currentSelectingRows?.removeWhere((row) => removeKeys.contains(row.key));

    if (notify) {
      notifyListeners();
    }
  }

  void moveRows(
    List<PlutoRow> rows,
    double offset, {
    bool notify = true,
  }) {
    int indexToMove = getRowIdxByOffset(offset);

    if (indexToMove == null) {
      return;
    } else if (indexToMove + rows.length > _rows.length) {
      indexToMove = _rows.length - rows.length;
    }

    rows.forEach((row) {
      _rows.remove(row);
    });

    _rows.insertAll(indexToMove, rows);

    int sortIdx = 0;

    _rows.forEach((element) {
      element.sortIdx = sortIdx++;
    });

    updateCurrentCellPosition(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void toggleAllRowChecked(
    bool flag, {
    bool notify = true,
  }) {
    _rows.forEach((e) {
      e._setChecked(flag == true);
    });

    if (notify) {
      notifyListeners();
    }
  }

  void _insertRows(
    int index,
    List<PlutoRow> rows, {
    PlutoRowState state,
  }) {
    if (state != null) {
      for (var row in rows) {
        row._setState(state);
      }
    }

    _rows.insertAll(index, rows);
  }
}
