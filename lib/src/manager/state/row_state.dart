part of '../../../pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  List<PlutoRow> _rows;

  List<PlutoRow> get checkedRows;

  List<PlutoRow> get unCheckedRows;

  bool get hasCheckedRow;

  bool get hasUnCheckedRow;

  /// Row index of currently selected cell.
  int get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow get currentRow;

  PlutoRow getRowByIdx(int rowIdx);

  PlutoRow getNewRow();

  List<PlutoRow> getNewRows({
    int count = 1,
  });

  void setCurrentRowIdx(
    int rowIdx, {
    bool notify: true,
  });

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  });

  void setRowChecked(
    PlutoRow row,
    bool flag, {
    bool notify: true,
  });

  /// set currentRowIdx to null
  void clearCurrentRowIdx({
    bool notify: true,
  });

  /// Update RowIdx to Current Cell.
  void updateCurrentRowIdx({
    bool notify: true,
  });

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

  void moveRows(List<PlutoRow> rows, double offset);

  void toggleAllRowChecked(
    bool flag, {
    bool notify: true,
  });
}

mixin RowState implements IPlutoState {
  List<PlutoRow> get rows => [..._rows];

  List<PlutoRow> _rows;

  List<PlutoRow> get checkedRows => _rows.where((row) => row.checked);

  List<PlutoRow> get unCheckedRows => _rows.where((row) => !row.checked);

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

  int get currentRowIdx => _currentRowIdx;

  int _currentRowIdx;

  PlutoRow get currentRow {
    if (_currentRowIdx == null) {
      return null;
    }

    return _rows[_currentRowIdx];
  }

  PlutoRow getRowByIdx(int rowIdx) {
    if (rowIdx == null || rowIdx < 0 || _rows.length - 1 < rowIdx) {
      return null;
    }

    return _rows[rowIdx];
  }

  PlutoRow getNewRow() {
    final cells = Map<String, PlutoCell>();

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

    if (rows.length < 1) {
      return [];
    }

    return rows;
  }

  void setCurrentRowIdx(
    int rowIdx, {
    bool notify: true,
  }) {
    if (_currentRowIdx == rowIdx) {
      return;
    }

    _currentRowIdx = rowIdx;

    if (notify) {
      notifyListeners();
    }
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
    bool notify: true,
  }) {
    final findRow = _rows.firstWhere((element) => element.key == row.key);

    if (findRow == null) {
      return;
    }

    findRow._checked = flag;

    if (notify) {
      notifyListeners();
    }
  }

  void clearCurrentRowIdx({
    bool notify: true,
  }) {
    setCurrentRowIdx(null, notify: notify);
  }

  void updateCurrentRowIdx({
    bool notify: true,
  }) {
    if (currentCell == null) {
      _currentRowIdx = null;

      if (notify) {
        notifyListeners();
      }

      return;
    }

    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == currentCell.key) {
          _currentRowIdx = rowIdx;
        }
      }
    }

    if (notify) {
      notifyListeners();
    }
  }

  void prependNewRows({
    int count = 1,
  }) {
    prependRows(getNewRows(count: count));
  }

  void prependRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(min) - 1 : 0;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      increase: false,
      start: start,
    );

    _rows.insertAll(0, rows);

    /// Update currentRowIdx
    if (currentCell != null) {
      _currentRowIdx = rows.length + _currentRowIdx;

      setCurrentCellPosition(
        PlutoCellPosition(
          columnIdx: currentCellPosition.columnIdx,
          rowIdx: currentRowIdx,
        ),
        notify: false,
      );

      double offsetToMove = rows.length * PlutoDefaultSettings.rowTotalHeight;

      scrollByDirection(MoveDirection.Up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        columnIdx: currentSelectingPosition.columnIdx,
        rowIdx: rows.length + currentSelectingPosition.rowIdx,
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
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(max) + 1 : 0;

    PlutoStateManager.initializeRows(
      _columns,
      rows,
      start: start,
    );

    _rows.addAll(rows);

    notifyListeners();
  }

  void removeCurrentRow() {
    if (_currentRowIdx == null) {
      return;
    }

    _rows.removeAt(_currentRowIdx);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  void removeRows(
    List<PlutoRow> rows, {
    bool notify: true,
  }) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final List<Key> removeKeys = rows.map((e) => e.key).toList(growable: false);

    if (_currentRowIdx != null &&
        _rows.length > _currentRowIdx &&
        removeKeys.contains(_rows[_currentRowIdx].key)) {
      resetCurrentState(notify: false);
    }

    _rows.removeWhere((row) => removeKeys.contains(row.key));

    updateCurrentRowIdx(notify: false);

    updateCurrentCellPosition(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void moveRows(List<PlutoRow> rows, double offset) {
    offset -= bodyTopOffset - scroll.verticalOffset;

    double currentOffset = 0.0;

    int indexToMove;

    for (var i = 0; i < _rows.length; i += 1) {
      if (currentOffset < offset &&
          offset < currentOffset + PlutoDefaultSettings.rowTotalHeight) {
        indexToMove = i;
        break;
      }

      currentOffset += PlutoDefaultSettings.rowTotalHeight;
    }

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

    updateCurrentRowIdx(notify: false);

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  void toggleAllRowChecked(
    bool flag, {
    bool notify: true,
  }) {
    _rows.forEach((e) {
      e._checked = flag == true;
    });

    if (notify) {
      notifyListeners();
    }
  }
}
