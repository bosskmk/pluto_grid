part of '../../../pluto_grid.dart';

abstract class IKeyboardState {
  /// Currently pressed key
  PlutoKeyPressed get keyPressed;

  PlutoKeyPressed _keyPressed;

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

  void moveSelectingCell(MoveDirection direction);
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
    if (!force && _isEditing && direction.horizontal) {
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
      _eventManager.subject.add(
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

  void moveSelectingCell(MoveDirection direction) {
    final PlutoCellPosition cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      return;
    }

    setCurrentSelectingPosition(
      columnIdx: cellPosition.columnIdx +
          (direction.horizontal ? direction.offset : 0),
      rowIdx: cellPosition.rowIdx + (direction.vertical ? direction.offset : 0),
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
  }
}
