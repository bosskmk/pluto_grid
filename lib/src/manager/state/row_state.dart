part of '../../../pluto_grid.dart';

abstract class IRowState {
  List<PlutoRow> get rows;

  List<PlutoRow> _rows;

  /// Row index of currently selected cell.
  int get currentRowIdx;

  int _currentRowIdx;

  /// Row of currently selected cell.
  PlutoRow get currentRow;

  List<PlutoRow> setSortIdxOfRows(
    List<PlutoRow> rows, {
    bool increase = true,
    int start = 0,
  });

  void prependRows(List<PlutoRow> rows);

  void appendRows(List<PlutoRow> rows);

  void removeCurrentRow();

  void removeRows(List<PlutoRow> rows);

  /// Update RowIdx to Current Cell.
  void updateCurrentRowIdx(Key cellKey);
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

  void prependRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(min) - 1 : 0;

    _rows.insertAll(
      0,
      setSortIdxOfRows(
        rows,
        increase: false,
        start: start,
      ),
    );

    /// Update currentRowIdx
    if (_currentRowIdx != null) {
      _currentRowIdx = rows.length + _currentRowIdx;

      double offsetToMove = rows.length * PlutoDefaultSettings.rowTotalHeight;

      scrollByDirection(MoveDirection.Up, offsetToMove);
    }

    /// Update currentSelectingPosition
    if (_currentSelectingPosition != null) {
      setCurrentSelectingPosition(
        columnIdx: _currentSelectingPosition.columnIdx,
        rowIdx: rows.length + _currentSelectingPosition.rowIdx,
        notify: false,
      );
    }

    notifyListeners();
  }

  void appendRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final start =
        _rows.length > 0 ? _rows.map((row) => row.sortIdx).reduce(max) + 1 : 0;

    _rows.addAll(
      setSortIdxOfRows(
        rows,
        start: start,
      ),
    );

    notifyListeners();
  }

  void removeCurrentRow() {
    if (_currentRowIdx == null) {
      return;
    }

    _rows.removeAt(_currentRowIdx);

    resetCurrentState(notify: false);

    notifyListeners(checkCellValue: false);
  }

  void removeRows(List<PlutoRow> rows) {
    if (rows == null || rows.length < 1) {
      return;
    }

    final List<Key> removeKeys = rows.map((e) => e.key).toList(growable: false);

    _rows.removeWhere((row) => removeKeys.contains(row.key));

    notifyListeners(checkCellValue: false);
  }

  void updateCurrentRowIdx(Key cellKey) {
    if (cellKey == null) {
      return;
    }

    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == cellKey) {
          _currentRowIdx = rowIdx;
        }
      }
    }
    return;
  }
}
