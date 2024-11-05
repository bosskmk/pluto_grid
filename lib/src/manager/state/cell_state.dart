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
    required PlutoCell cell,
    dynamic newValue,
    dynamic oldValue,
  });

  bool canNotChangeCellValue({
    required PlutoCell cell,
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

  void dragCellWithPosition({
    required PlutoCell cell,
    required int columnIdx,
    required int rowIdx,
    bool initialCell = false,
  });

  void finishCellDrag();

  bool isDraggedCell({
    required PlutoCell cell,
    bool isInitialCell = false,
  });
}

class _State {
  PlutoCell? _currentCell;

  PlutoGridCellPosition? _currentCellPosition;
}

mixin CellState implements IPlutoGridState {
  final _State _state = _State();

  final _CellDragState _cellDragState = _CellDragState();

  @override
  PlutoCell? get currentCell => _state._currentCell;

  @override
  PlutoGridCellPosition? get currentCellPosition => _state._currentCellPosition;

  @override
  PlutoCell? get firstCell {
    if (refRows.isEmpty || refColumns.isEmpty) {
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
    if (currentCellPosition == cellPosition) {
      return;
    }

    if (cellPosition == null) {
      clearCurrentCell(notify: false);
    } else if (isInvalidCellPosition(cellPosition)) {
      return;
    }

    _state._currentCellPosition = cellPosition;

    notifyListeners(notify, setCurrentCellPosition.hashCode);
  }

  @override
  void updateCurrentCellPosition({bool notify = true}) {
    if (currentCell == null) {
      return;
    }

    setCurrentCellPosition(
      cellPositionByCellKey(currentCell!.key),
      notify: false,
    );

    notifyListeners(notify, updateCurrentCellPosition.hashCode);
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
    if (currentCell == null) {
      return;
    }

    _state._currentCell = null;

    _state._currentCellPosition = null;

    notifyListeners(notify, clearCurrentCell.hashCode);
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

    if (currentCell != null && currentCell!.key == cell.key) {
      return;
    }

    _state._currentCell = cell;

    _state._currentCellPosition = PlutoGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    );

    clearCurrentSelecting(notify: false);

    setEditing(autoEditing, notify: false);

    notifyListeners(notify, setCurrentCell.hashCode);
  }

  @override
  bool canMoveCell(
    PlutoGridCellPosition? cellPosition,
    PlutoMoveDirection direction,
  ) {
    if (cellPosition == null || !cellPosition.hasPosition) return false;

    switch (direction) {
      case PlutoMoveDirection.left:
        return cellPosition.columnIdx! > 0;
      case PlutoMoveDirection.right:
        return cellPosition.columnIdx! < refColumns.length - 1;
      case PlutoMoveDirection.up:
        return cellPosition.rowIdx! > 0;
      case PlutoMoveDirection.down:
        return cellPosition.rowIdx! < refRows.length - 1;
    }
  }

  @override
  bool canNotMoveCell(
    PlutoGridCellPosition? cellPosition,
    PlutoMoveDirection direction,
  ) {
    return !canMoveCell(cellPosition, direction);
  }

  @override
  bool canChangeCellValue({
    required PlutoCell cell,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (!mode.isEditableMode) {
      return false;
    }

    if (cell.column.checkReadOnly(
      cell.row,
      cell.row.cells[cell.column.field]!,
    )) {
      return false;
    }

    if (!isEditableCell(cell)) {
      return false;
    }

    if (newValue.toString() == oldValue.toString()) {
      return false;
    }

    return true;
  }

  @override
  bool canNotChangeCellValue({
    required PlutoCell cell,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      cell: cell,
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
    return currentCell != null && currentCell!.key == cell!.key;
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

  @override
  void finishCellDrag() {
    _cellDragState.finishCellDrag();

    notifyListeners();
  }

  @override
  bool isDraggedCell({
    required PlutoCell cell,
    bool isInitialCell = false,
  }) =>
      _cellDragState.isDraggedCell(
        cell: cell,
        isInitialCell: isInitialCell,
      );

  @override
  void dragCellWithPosition({
    required PlutoCell cell,
    required int columnIdx,
    required int rowIdx,
    bool initialCell = false,
  }) {
    _cellDragState.dragCellWithPosition(
      cell: cell,
      columnIdx: columnIdx,
      rowIdx: rowIdx,
      initialCell: initialCell,
    );

    notifyListeners();
  }
}

enum _CellDragStateDirection {
  up,
  down,
  left,
  right,
  none,
}

class _CellDragState {
  final _draggedCellsWithPosition = <_CellWithPositionState>[];

  var _direction = _CellDragStateDirection.none;

  void finishCellDrag() {
    // No cells to drag.
    if (_draggedCellsWithPosition.isEmpty) {
      return;
    }

    // Get first cell that started the drag.
    final startingCellWithPosition = _draggedCellsWithPosition.first;

    // Apply starting cell value to all other cells.
    for (var i = 1; i < _draggedCellsWithPosition.length; i++) {
      final draggedCellWithPosition = _draggedCellsWithPosition[i];
      // Apply value.
      draggedCellWithPosition.cell.value = startingCellWithPosition.cell.value;
    }

    // Reset.
    _resetCellDrag();
  }

  void dragCellWithPosition({
    required PlutoCell cell,
    required int columnIdx,
    required int rowIdx,
    bool initialCell = false,
  }) {
    // Cannot drag cell, so exit.
    if (!_canCellWithPositionBeDragged(
      cell: cell,
      columnIdx: columnIdx,
      rowIdx: rowIdx,
      initialCell: initialCell,
    )) {
      return;
    }

    // Create new cell with postion.
    final newCellWithPosition = _CellWithPositionState(
      cell: cell,
      position: PlutoGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );

    // Get latest cell.
    final latestCellWithPosition = _draggedCellsWithPosition.isNotEmpty
        ? _draggedCellsWithPosition.last
        : null;

    // No cell yet, so just add it and return.
    if (latestCellWithPosition == null) {
      _draggedCellsWithPosition.add(newCellWithPosition);
      return;
    }

    // Get potential direction from dragging new cell.
    final newDirection = _directionFromDraggingCell(
      latestCellWithPosition: latestCellWithPosition,
      columnIdx: columnIdx,
      rowIdx: rowIdx,
    )!;

    // Dragged opposite, which means we need to pop latest cell and return.
    // Can only drag in opposite direction with one row/column at a time.
    if (_areDirectionsOpposite(_direction, newDirection)) {
      _draggedCellsWithPosition.removeLast();

      // Reset direction if less than 2 items.
      if (_draggedCellsWithPosition.length < 2) {
        _direction = _CellDragStateDirection.none;
      }

      return;
    }

    // Add cell to dragged cells.
    _draggedCellsWithPosition.add(_CellWithPositionState(
      cell: cell,
      position: PlutoGridCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    ));

    // Set direction if it is none and now we have two cells.
    if (_direction == _CellDragStateDirection.none &&
        _draggedCellsWithPosition.length == 2) {
      _direction = _directionFromDraggingCell(
        // Use first to get new direction.
        latestCellWithPosition: _draggedCellsWithPosition.first,
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      )!;
    }
  }

  bool isDraggedCell({
    required PlutoCell cell,
    bool isInitialCell = false,
  }) {
    if (_draggedCellsWithPosition.isEmpty) {
      return false;
    }

    if (isInitialCell) {
      return _draggedCellsWithPosition.first.cell.key == cell.key;
    }

    for (final cellWithPosition in _draggedCellsWithPosition) {
      if (cellWithPosition.cell.key == cell.key) {
        return true;
      }
    }

    return false;
  }

  bool _canCellWithPositionBeDragged({
    required PlutoCell cell,
    required int columnIdx,
    required int rowIdx,
    bool initialCell = false,
  }) {
    // No cells yet, so if it's initial cell then we can drag.
    if (_draggedCellsWithPosition.isEmpty) {
      return initialCell;
    }

    // Get latest cell.
    final latestCellWithPosition = _draggedCellsWithPosition.last;

    // Same as latest cell, so cannot drag.
    if (latestCellWithPosition.cell.key == cell.key) {
      return false;
    }

    // Type mismatch, so we cannot drag.
    if (cell.value.runtimeType !=
        latestCellWithPosition.cell.value.runtimeType) {
      return false;
    }

    // Determine new direction if this cell was dragged.
    final direction = _directionFromDraggingCell(
      latestCellWithPosition: latestCellWithPosition,
      rowIdx: rowIdx,
      columnIdx: columnIdx,
    );

    // Not a valid direction, so we cannot drag.
    if (direction == null) {
      return false;
    }

    // No existing direction, so we can drag.
    if (_direction == _CellDragStateDirection.none) {
      return true;
    }

    // Existing direction, so directions must match or must be opposites.
    return _direction == direction ||
        _areDirectionsOpposite(_direction, direction);
  }

  void _resetCellDrag() {
    _direction = _CellDragStateDirection.none;
    _draggedCellsWithPosition.clear();
  }

  _CellDragStateDirection? _directionFromDraggingCell({
    required _CellWithPositionState latestCellWithPosition,
    required int columnIdx,
    required int rowIdx,
  }) {
    // Determine new direction based on current.
    // Null direction means it's not a valid drag.
    switch (_direction) {
      case _CellDragStateDirection.none:
        final areRowsSame = latestCellWithPosition.position.rowIdx == rowIdx;
        final areColumnsSame =
            latestCellWithPosition.position.columnIdx == columnIdx;
        final areRowsDiffByOneInEitherDirection =
            latestCellWithPosition.position.rowIdx == rowIdx + 1 ||
                latestCellWithPosition.position.rowIdx == rowIdx - 1;
        final areColumnsDiffByOneInEitherDirection =
            latestCellWithPosition.position.columnIdx == columnIdx + 1 ||
                latestCellWithPosition.position.columnIdx == columnIdx - 1;

        // Not valid up, down, left, or right drag.
        if (!(areRowsSame && areColumnsDiffByOneInEitherDirection) &&
            !(areColumnsSame && areRowsDiffByOneInEitherDirection)) {
          return null;
        }

        // Moving left or right.
        if (areRowsSame) {
          // Moving right.
          if (latestCellWithPosition.position.columnIdx == columnIdx - 1) {
            return _CellDragStateDirection.right;
          }

          return _CellDragStateDirection.left;
        }

        // Must be moving either up or down.
        // Moving down.
        if (latestCellWithPosition.position.rowIdx == rowIdx - 1) {
          return _CellDragStateDirection.down;
        }

        return _CellDragStateDirection.up;
      case _CellDragStateDirection.up:
      case _CellDragStateDirection.down:
        // Column not the same, so we cannot drag.
        if (columnIdx != latestCellWithPosition.position.columnIdx) {
          return null;
        }

        final draggedOneRowUp =
            rowIdx + 1 == latestCellWithPosition.position.rowIdx;
        final draggedOneRowDown =
            rowIdx - 1 == latestCellWithPosition.position.rowIdx;

        // Row not exactly +-1, so we cannot drag.
        if (!draggedOneRowUp && !draggedOneRowDown) {
          return null;
        }

        if (draggedOneRowUp) {
          return _CellDragStateDirection.up;
        }

        return _CellDragStateDirection.down;
      case _CellDragStateDirection.left:
      case _CellDragStateDirection.right:
        // Row not the same, so we cannot drag.
        if (rowIdx != latestCellWithPosition.position.rowIdx) {
          return null;
        }

        final draggedOneColumnRight =
            columnIdx - 1 == latestCellWithPosition.position.columnIdx;
        final draggedOneColumnLeft =
            columnIdx + 1 == latestCellWithPosition.position.columnIdx;

        // Column not exactly +-1, so we cannot drag.
        if (!draggedOneColumnLeft && !draggedOneColumnRight) {
          return null;
        }

        if (draggedOneColumnLeft) {
          return _CellDragStateDirection.left;
        }

        return _CellDragStateDirection.right;
    }
  }

  bool _areDirectionsOpposite(
    _CellDragStateDirection a,
    _CellDragStateDirection b,
  ) {
    switch (a) {
      case _CellDragStateDirection.up:
        return b == _CellDragStateDirection.down;
      case _CellDragStateDirection.down:
        return b == _CellDragStateDirection.up;
      case _CellDragStateDirection.left:
        return b == _CellDragStateDirection.right;
      case _CellDragStateDirection.right:
        return b == _CellDragStateDirection.left;
      case _CellDragStateDirection.none:
        return false;
    }
  }
}

class _CellWithPositionState {
  const _CellWithPositionState({
    required this.cell,
    required this.position,
  });

  final PlutoCell cell;

  final PlutoGridCellPosition position;
}
