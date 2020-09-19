part of '../../../pluto_grid.dart';

abstract class ICellState {
  /// True, check the change of value when moving cells.
  bool get checkCellValue;

  /// currently selected cell.
  PlutoCell get currentCell;

  PlutoCell _currentCell;

  /// The position index value of the currently selected cell.
  PlutoCellPosition get currentCellPosition;

  /// Execute the function without checking if the value has changed.
  /// Improves cell rendering performance.
  void withoutCheckCellValue(Function() callback);

  /// Index position of cell in a column
  PlutoCellPosition cellPositionByCellKey(Key cellKey,
      List<int> columnIndexes);

  /// Change the selected cell.
  void setCurrentCell(PlutoCell cell,
      int rowIdx, {
        bool notify = true,
      });

  /// Whether it is possible to move in the [direction] from [cellPosition].
  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction);

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction);

  /// Whether the cell is in a mutable state
  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  bool canNotChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Filter on cell value change
  dynamic filteredCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Whether the cell is the currently selected cell.
  bool isCurrentCell(PlutoCell cell);
}

mixin CellState implements IPlutoState {
  bool get checkCellValue => _checkCellValue;

  bool _checkCellValue = true;

  PlutoCell get currentCell => _currentCell;

  PlutoCell _currentCell;

  PlutoCellPosition get currentCellPosition {
    if (_currentCell == null) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFixed();

    return cellPositionByCellKey(_currentCell._key, columnIndexes);
  }

  void withoutCheckCellValue(Function() callback) {
    _checkCellValue = false;

    callback();

    _checkCellValue = true;
  }

  PlutoCellPosition cellPositionByCellKey(Key cellKey,
      List<int> columnIndexes) {
    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
      columnIdx < columnIndexes.length;
      columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;
        if (_rows[rowIdx].cells[field]._key == cellKey) {
          return PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
        }
      }
    }
    throw Exception('CellKey was not found in the list.');
  }

  void setCurrentCell(PlutoCell cell,
      int rowIdx, {
        bool notify = true,
      }) {
    if (cell == null) {
      return;
    }

    if (_currentCell != null && _currentCell._key == cell._key) {
      return;
    }

    _currentCell = cell;

    _currentSelectingPosition = null;

    setEditing(false, notify: false);

    if (rowIdx != null) _currentRowIdx = rowIdx;

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    bool _canMoveCell;

    switch (direction) {
      case MoveDirection.Left:
        _canMoveCell = cellPosition.columnIdx > 0;
        break;
      case MoveDirection.Right:
        _canMoveCell = cellPosition.columnIdx <
            _rows[cellPosition.rowIdx].cells.length - 1;
        break;
      case MoveDirection.Up:
        _canMoveCell = cellPosition.rowIdx > 0;
        break;
      case MoveDirection.Down:
        _canMoveCell = cellPosition.rowIdx < _rows.length - 1;
        break;
    }

    assert(_canMoveCell != null);

    return _canMoveCell;
  }

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.readOnly) {
      return false;
    }

    if (newValue.toString() == oldValue.toString()) {
      return false;
    }

    return true;
  }

  bool canNotChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      column: column,
      newValue: newValue,
      oldValue: oldValue,
    );
  }

  dynamic filteredCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.isSelect &&
        column.type.select.items.contains(newValue) != true) {
      newValue = oldValue;
    } else if (column.type.isDate) {
      final parseNewValue = DateTime.tryParse(newValue);

      if (parseNewValue == null) {
        newValue = oldValue;
      } else {
        newValue =
            intl.DateFormat(column.type.date.format).format(parseNewValue);
      }
    } else if (column.type.isTime) {
      final time = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

      if (!time.hasMatch(newValue)) {
        newValue = oldValue;
      }
    }

    return newValue;
  }

  bool isCurrentCell(PlutoCell cell) {
    return _currentCell != null && _currentCell._key == cell._key;
  }
}