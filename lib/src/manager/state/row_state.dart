part of '../../../pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  List<PlutoRow> _rows;

  /// Row index of currently selected cell.
  int get currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow get currentRow;

  /// set currentRowIdx to null
  void clearCurrentRowIdx({bool notify: true});

  void setCurrentRowIdx(int rowIdx, {bool notify: true});

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  });

  void prependNewRows({
    int count = 1,
  });

  void prependRows(List<PlutoRow> rows);

  void appendNewRows({
    int count = 1,
  });

  void appendRows(List<PlutoRow> rows);

  PlutoRow getNewRow();

  List<PlutoRow> getNewRows({
    int count = 1,
  });

  void removeCurrentRow();

  void removeRows(List<PlutoRow> rows);

  void moveRows(List<PlutoRow> rows, double offset);

  /// Update RowIdx to Current Cell.
  void updateCurrentRowIdx({bool notify: true});
}

mixin RowState implements IPlutoState {
  List<PlutoRow> get rows => [..._rows];

  List<PlutoRow> _rows;

  int get currentRowIdx => _currentRowIdx;

  int _currentRowIdx;

  PlutoRow get currentRow {
    if (_currentRowIdx == null) {
      return null;
    }

    return _rows[_currentRowIdx];
  }

  void clearCurrentRowIdx({bool notify: true}) {
    setCurrentRowIdx(null, notify: notify);
  }

  void setCurrentRowIdx(int rowIdx, {bool notify: true}) {
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
        removeKeys.contains(_rows[_currentRowIdx].key)) {
      resetCurrentState(notify: false);
    }

    _rows.removeWhere((row) => removeKeys.contains(row.key));

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

  void updateCurrentRowIdx({bool notify: true}) {
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
}
