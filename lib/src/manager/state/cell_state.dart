import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ICellState {
  /// currently selected cell.
  PlutoCell get currentCell;

  /// The position index value of the currently selected cell.
  PlutoCellPosition get currentCellPosition;

  PlutoCell get firstCell;

  void setCurrentCellPosition(
    PlutoCellPosition cellPosition, {
    bool notify = true,
  });

  void updateCurrentCellPosition({bool notify = true});

  /// Index position of cell in a column
  PlutoCellPosition cellPositionByCellKey(Key cellKey);

  int columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx);

  /// set currentCell to null
  void clearCurrentCell({bool notify = true});

  /// Change the selected cell.
  void setCurrentCell(
    PlutoCell cell,
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

  bool isInvalidCellPosition(PlutoCellPosition cellPosition);
}

mixin CellState implements IPlutoState {
  PlutoCell get currentCell => _currentCell;

  PlutoCell _currentCell;

  PlutoCellPosition get currentCellPosition => _currentCellPosition;

  PlutoCellPosition _currentCellPosition;

  PlutoCell get firstCell {
    if (refRows == null || refRows.isEmpty) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final columnField = refColumns[columnIndexes.first].field;

    return refRows.first.cells[columnField];
  }

  void setCurrentCellPosition(
    PlutoCellPosition cellPosition, {
    bool notify = true,
  }) {
    if (_currentCellPosition == cellPosition) {
      return;
    }

    if (cellPosition == null) {
      clearCurrentCell(notify: false);
    } else if (isInvalidCellPosition(cellPosition)) {
      return;
    }

    _currentCellPosition = cellPosition;

    if (notify) {
      notifyListeners();
    }
  }

  void updateCurrentCellPosition({bool notify = true}) {
    if (_currentCell == null) {
      return;
    }

    resetShowFrozenColumn(notify: false);

    setCurrentCellPosition(
      cellPositionByCellKey(_currentCell.key),
      notify: false,
    );

    if (notify) {
      notifyListeners();
    }
  }

  PlutoCellPosition cellPositionByCellKey(Key cellKey) {
    assert(cellKey != null);

    for (var rowIdx = 0; rowIdx < refRows.length; rowIdx += 1) {
      final columnIdx = columnIdxByCellKeyAndRowIdx(cellKey, rowIdx);

      if (columnIdx != null) {
        return PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
      }
    }

    return null;
  }

  int columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx) {
    if (cellKey == null ||
        rowIdx < 0 ||
        refRows == null ||
        rowIdx >= refRows.length) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    for (var columnIdx = 0; columnIdx < columnIndexes.length; columnIdx += 1) {
      final field = refColumns[columnIndexes[columnIdx]].field;

      if (refRows[rowIdx].cells[field].key == cellKey) {
        return columnIdx;
      }
    }

    return null;
  }

  void clearCurrentCell({bool notify = true}) {
    if (_currentCell == null) {
      return;
    }

    _currentCell = null;

    _currentCellPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

  void setCurrentCell(
    PlutoCell cell,
    int rowIdx, {
    bool notify = true,
  }) {
    if (cell == null ||
        rowIdx == null ||
        refRows == null ||
        refRows.isEmpty ||
        rowIdx < 0 ||
        rowIdx > refRows.length - 1) {
      return;
    }

    if (_currentCell != null && _currentCell.key == cell.key) {
      return;
    }

    _currentCell = cell;

    _currentCellPosition = PlutoCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    );

    clearCurrentSelectingPosition(notify: false);

    clearCurrentSelectingRows(notify: false);

    setEditing(false, notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.left:
        return cellPosition.columnIdx > 0;
      case MoveDirection.right:
        return cellPosition.columnIdx <
            refRows[cellPosition.rowIdx].cells.length - 1;
      case MoveDirection.up:
        return cellPosition.rowIdx > 0;
      case MoveDirection.down:
        return cellPosition.rowIdx < refRows.length - 1;
    }

    throw Exception('Not handled MoveDirection');
  }

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.readOnly || column.enableEditingMode != true) {
      return false;
    }

    if (mode.isSelect) {
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
      try {
        final parseNewValue =
            intl.DateFormat(column.type.date.format).parseStrict(newValue);

        newValue =
            intl.DateFormat(column.type.date.format).format(parseNewValue);
      } catch (e) {
        newValue = oldValue;
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
    return _currentCell != null && _currentCell.key == cell.key;
  }

  bool isInvalidCellPosition(PlutoCellPosition cellPosition) {
    return cellPosition == null ||
        cellPosition.columnIdx == null ||
        cellPosition.rowIdx == null ||
        cellPosition.columnIdx < 0 ||
        cellPosition.rowIdx < 0 ||
        cellPosition.columnIdx > refColumns.length - 1 ||
        cellPosition.rowIdx > refRows.length - 1;
  }
}
