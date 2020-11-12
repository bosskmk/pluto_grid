part of '../../../pluto_grid.dart';

abstract class IKeyboardState {
  /// Currently pressed key
  PlutoKeyPressed get keyPressed;

  /// Set the current pressed key state.
  void setKeyPressed(PlutoKeyPressed keyPressed);

  void resetKeyPressed();

  /// The index position of the cell to move in that direction in the current cell.
  PlutoCellPosition cellPositionToMove(
    PlutoCellPosition cellPosition,
    MoveDirection direction,
  );

  /// Change the current cell to the cell in the [direction] and move the scroll
  /// [force] true : Allow left and right movement with tab key in editing state.
  void moveCurrentCell(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfColumns(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellToEdgeOfRows(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveCurrentCellByRowIdx(
    int rowIdx,
    MoveDirection direction, {
    bool notify = true,
  });

  void moveSelectingCell(MoveDirection direction);

  void moveSelectingCellToEdgeOfColumns(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellToEdgeOfRows(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  });

  void moveSelectingCellByRowIdx(
    int rowIdx,
    MoveDirection direction, {
    bool notify = true,
  });
}

mixin KeyboardState implements IPlutoState {
  PlutoKeyPressed get keyPressed => _keyPressed;

  PlutoKeyPressed _keyPressed = PlutoKeyPressed();

  void setKeyPressed(PlutoKeyPressed keyPressed) {
    _keyPressed = keyPressed;
  }

  void resetKeyPressed() {
    _keyPressed = PlutoKeyPressed();
  }

  PlutoCellPosition cellPositionToMove(
    PlutoCellPosition cellPosition,
    MoveDirection direction,
  ) {
    final columnIndexes = columnIndexesByShowFixed();

    switch (direction) {
      case MoveDirection.Left:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx - 1],
          rowIdx: cellPosition.rowIdx,
        );
      case MoveDirection.Right:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx + 1],
          rowIdx: cellPosition.rowIdx,
        );
      case MoveDirection.Up:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx],
          rowIdx: cellPosition.rowIdx - 1,
        );
      case MoveDirection.Down:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx],
          rowIdx: cellPosition.rowIdx + 1,
        );
    }
    throw Exception('MoveDirection case was not handled.');
  }

  void moveCurrentCell(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (currentCell == null) return;

    // @formatter:off
    if (!force && isEditing && direction.horizontal) {
      // Select type column can be moved left or right even in edit state
      if (currentColumn?.type?.isSelect == true) {
      }
      // Date type column can be moved left or right even in edit state
      else if (currentColumn?.type?.isDate == true) {
      }
      // Time type column can be moved left or right even in edit state
      else if (currentColumn?.type?.isTime == true) {
      }
      // Read only type column can be moved left or right even in edit state
      else if (currentColumn?.type?.readOnly == true) {
      }
      // Unable to move left and right in other modified states
      else {
        return;
      }
    }
    // @formatter:on

    final cellPosition = currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      eventManager.subject.add(
        PlutoCannotMoveCurrentCellEvent(
          cellPosition: cellPosition,
          direction: direction,
        ),
      );

      return;
    }

    final toMove = cellPositionToMove(
      cellPosition,
      direction,
    );

    setCurrentCell(_rows[toMove.rowIdx].cells[_columns[toMove.columnIdx].field],
        toMove.rowIdx,
        notify: notify);

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
    return;
  }

  void moveCurrentCellToEdgeOfColumns(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIndexes = columnIndexesByShowFixed();

    final int columnIdx =
        direction.isLeft ? columnIndexes.first : columnIndexes.last;

    final column = _columns[columnIdx];

    final cellToMove = currentRow.cells[column.field];

    setCurrentCell(cellToMove, currentRowIdx, notify: notify);

    if (!showFixedColumn || column.fixed.isFixed != true) {
      direction.isLeft
          ? scroll.horizontal.jumpTo(0)
          : scroll.horizontal.jumpTo(scroll.maxScrollHorizontal);
    }
  }

  void moveCurrentCellToEdgeOfRows(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    final field = currentColumnField ?? columns.first.field;

    final int rowIdx = direction.isUp ? 0 : _rows.length - 1;

    final cellToMove = _rows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    direction.isUp
        ? scroll.vertical.jumpTo(0)
        : scroll.vertical.jumpTo(scroll.maxScrollVertical);
  }

  void moveCurrentCellByRowIdx(
    int rowIdx,
    MoveDirection direction, {
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > _rows.length - 1) {
      rowIdx = _rows.length - 1;
    }

    final field = currentColumnField ?? _columns.first.field;

    final cellToMove = _rows[rowIdx].cells[field];

    setCurrentCell(cellToMove, rowIdx, notify: notify);

    moveScrollByRow(direction, rowIdx - direction.offset);
  }

  void moveSelectingCell(MoveDirection direction) {
    final PlutoCellPosition cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: PlutoCellPosition(
        columnIdx: cellPosition.columnIdx +
            (direction.horizontal ? direction.offset : 0),
        rowIdx:
            cellPosition.rowIdx + (direction.vertical ? direction.offset : 0),
      ),
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
  }

  void moveSelectingCellToEdgeOfColumns(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.horizontal) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final int columnIdx = direction.isLeft ? 0 : _columns.length - 1;

    final int rowIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition.rowIdx
        : currentCellPosition.rowIdx;

    setCurrentSelectingPosition(
      cellPosition: PlutoCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
      notify: notify,
    );

    direction.isLeft
        ? scroll.horizontal.jumpTo(0)
        : scroll.horizontal.jumpTo(scroll.maxScrollHorizontal);
  }

  void moveSelectingCellToEdgeOfRows(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (!direction.vertical) {
      return;
    }

    if (!force && isEditing == true) {
      return;
    }

    if (currentCell == null) {
      return;
    }

    final columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition.columnIdx
        : currentCellPosition.columnIdx;

    final int rowIdx = direction.isUp ? 0 : _rows.length - 1;

    setCurrentSelectingPosition(
      cellPosition: PlutoCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
      notify: notify,
    );

    direction.isUp
        ? scroll.vertical.jumpTo(0)
        : scroll.vertical.jumpTo(scroll.maxScrollVertical);
  }

  void moveSelectingCellByRowIdx(
    int rowIdx,
    MoveDirection direction, {
    bool notify = true,
  }) {
    if (rowIdx < 0) {
      rowIdx = 0;
    }

    if (rowIdx > _rows.length - 1) {
      rowIdx = _rows.length - 1;
    }

    if (currentCell == null) {
      return;
    }

    int columnIdx = hasCurrentSelectingPosition
        ? currentSelectingPosition.columnIdx
        : currentCellPosition.columnIdx;

    setCurrentSelectingPosition(
      cellPosition: PlutoCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );

    moveScrollByRow(direction, rowIdx - direction.offset);
  }
}
