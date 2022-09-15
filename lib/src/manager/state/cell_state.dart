import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ICellState {
  /// currently selected cell.
  PlutoCell? get currentCell;

  /// The position index value of the currently selected cell.
  PlutoGridCellPosition? get currentCellPosition;

  PlutoCell? get firstCell;

  void setCurrentCellPosition(
    PlutoGridCellPosition cellPosition, {
    bool notify = true,
  });

  void updateCurrentCellPosition({bool notify = true});

  /// Index position of cell in a column
  PlutoGridCellPosition? cellPositionByCellKey(Key cellKey);

  int? columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx);

  /// set currentCell to null
  void clearCurrentCell({bool notify = true});

  /// Change the selected cell.
  void setCurrentCell(
    PlutoCell? cell,
    int? rowIdx, {
    bool notify = true,
  });

  /// Whether it is possible to move in the [direction] from [cellPosition].
  bool canMoveCell(
    PlutoGridCellPosition cellPosition,
    PlutoMoveDirection direction,
  );

  bool canNotMoveCell(
    PlutoGridCellPosition? cellPosition,
    PlutoMoveDirection direction,
  );

  /// Whether the cell is in a mutable state
  bool canChangeCellValue({
    required PlutoColumn column,
    required PlutoRow row,
    dynamic newValue,
    dynamic oldValue,
  });

  bool canNotChangeCellValue({
    required PlutoColumn column,
    required PlutoRow row,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Filter on cell value change
  dynamic filteredCellValue({
    required PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  });

  /// Whether the cell is the currently selected cell.
  bool isCurrentCell(PlutoCell cell);

  bool isInvalidCellPosition(PlutoGridCellPosition? cellPosition);
}

mixin CellState implements IPlutoGridState {
  @override
  PlutoCell? get currentCell => _currentCell;

  PlutoCell? _currentCell;

  @override
  PlutoGridCellPosition? get currentCellPosition => _currentCellPosition;

  PlutoGridCellPosition? _currentCellPosition;

  @override
  PlutoCell? get firstCell {
    if (refRows.isEmpty) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final columnField = refColumns[columnIndexes.first].field;

    return refRows.first.cells[columnField];
  }

  @override
  void setCurrentCellPosition(
    PlutoGridCellPosition? cellPosition, {
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

  @override
  void updateCurrentCellPosition({bool notify = true}) {
    if (_currentCell == null) {
      return;
    }

    setCurrentCellPosition(
      cellPositionByCellKey(_currentCell!.key),
      notify: false,
    );

    if (notify) {
      notifyListeners();
    }
  }

  @override
  PlutoGridCellPosition? cellPositionByCellKey(Key? cellKey) {
    if (cellKey == null) {
      return null;
    }

    final length = refRows.length;

    for (int rowIdx = 0; rowIdx < length; rowIdx += 1) {
      final columnIdx = columnIdxByCellKeyAndRowIdx(cellKey, rowIdx);

      if (columnIdx != null) {
        return PlutoGridCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
      }
    }

    return null;
  }

  @override
  int? columnIdxByCellKeyAndRowIdx(Key cellKey, int rowIdx) {
    if (rowIdx < 0 || rowIdx >= refRows.length) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFrozen;
    final length = columnIndexes.length;

    for (int columnIdx = 0; columnIdx < length; columnIdx += 1) {
      final field = refColumns[columnIndexes[columnIdx]].field;

      if (refRows[rowIdx].cells[field]!.key == cellKey) {
        return columnIdx;
      }
    }

    return null;
  }

  @override
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

  @override
  void setCurrentCell(
    PlutoCell? cell,
    int? rowIdx, {
    bool notify = true,
  }) {
    if (cell == null ||
        rowIdx == null ||
        refRows.isEmpty ||
        rowIdx < 0 ||
        rowIdx > refRows.length - 1) {
      return;
    }

    if (_currentCell != null && _currentCell!.key == cell.key) {
      return;
    }

    _currentCell = cell;

    _currentCellPosition = PlutoGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    );

    clearCurrentSelecting(notify: false);

    setEditing(autoEditing, notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  bool canMoveCell(
      PlutoGridCellPosition? cellPosition, PlutoMoveDirection direction) {
    switch (direction) {
      case PlutoMoveDirection.left:
        return cellPosition!.columnIdx! > 0;
      case PlutoMoveDirection.right:
        return cellPosition!.columnIdx! < refColumns.length - 1;
      case PlutoMoveDirection.up:
        return cellPosition!.rowIdx! > 0;
      case PlutoMoveDirection.down:
        return cellPosition!.rowIdx! < refRows.length - 1;
    }
  }

  @override
  bool canNotMoveCell(
      PlutoGridCellPosition? cellPosition, PlutoMoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  @override
  bool canChangeCellValue({
    required PlutoColumn column,
    required PlutoRow row,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.checkReadOnly(row, row.cells[column.field]!) ||
        column.enableEditingMode != true) {
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

  @override
  bool canNotChangeCellValue({
    required PlutoColumn column,
    required PlutoRow row,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      column: column,
      row: row,
      newValue: newValue,
      oldValue: oldValue,
    );
  }

  @override
  dynamic filteredCellValue({
    required PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.isSelect) {
      return column.type.select.items.contains(newValue) == true
          ? newValue
          : oldValue;
    }

    if (column.type.isDate) {
      try {
        final parseNewValue =
            column.type.date.dateFormat.parseStrict(newValue.toString());

        return PlutoDateTimeHelper.isValidRange(
          date: parseNewValue,
          start: column.type.date.startDate,
          end: column.type.date.endDate,
        )
            ? column.type.date.dateFormat.format(parseNewValue)
            : oldValue;
      } catch (e) {
        return oldValue;
      }
    }

    if (column.type.isTime) {
      final time = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d$');

      return time.hasMatch(newValue.toString()) ? newValue : oldValue;
    }

    return newValue;
  }

  @override
  bool isCurrentCell(PlutoCell? cell) {
    return _currentCell != null && _currentCell!.key == cell!.key;
  }

  @override
  bool isInvalidCellPosition(PlutoGridCellPosition? cellPosition) {
    return cellPosition == null ||
        cellPosition.columnIdx == null ||
        cellPosition.rowIdx == null ||
        cellPosition.columnIdx! < 0 ||
        cellPosition.rowIdx! < 0 ||
        cellPosition.columnIdx! > refColumns.length - 1 ||
        cellPosition.rowIdx! > refRows.length - 1;
  }
}
