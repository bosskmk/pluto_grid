part of '../../../pluto_grid.dart';

class PlutoCellGestureEvent extends PlutoEvent {
  final PlutoGestureType gestureType;
  final Offset offset;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;

  PlutoCellGestureEvent({
    this.gestureType,
    this.offset,
    this.cell,
    this.column,
    this.rowIdx,
  });

  @override
  void _handler(PlutoStateManager stateManager) {
    if (gestureType == null ||
        offset == null ||
        cell == null ||
        column == null ||
        rowIdx == null) {
      return;
    }

    if (gestureType.isOnTapUp) {
      _onTapUp(stateManager);
    } else if (gestureType.isOnLongPressStart) {
      _onLongPressStart(stateManager);
    } else if (gestureType.isOnLongPressMoveUpdate) {
      _onLongPressMoveUpdate(stateManager);
    } else if (gestureType.isOnLongPressEnd) {
      _onLongPressEnd(stateManager);
    }
  }

  void _onTapUp(PlutoStateManager stateManager) {
    if (_setKeepFocusAndCurrentCell(stateManager)) {
      return;
    } else if (stateManager.isSelectingInteraction()) {
      _selecting(stateManager);
      return;
    } else if (stateManager.mode.isSelect) {
      _selectMode(stateManager);
      return;
    }

    if (stateManager.isCurrentCell(cell) && stateManager.isEditing != true) {
      stateManager.setEditing(true);
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _onLongPressStart(PlutoStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);

    if (stateManager.selectingMode.isRow) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onLongPressMoveUpdate(PlutoStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager.addEvent(PlutoMoveUpdateEvent(
      offset: offset,
    ));
  }

  void _onLongPressEnd(PlutoStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);
  }

  bool _setKeepFocusAndCurrentCell(PlutoStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  void _selecting(PlutoStateManager stateManager) {
    if (stateManager.keyPressed.shift) {
      final int columnIdx = stateManager.columnIndex(column);

      stateManager.setCurrentSelectingPosition(
        cellPosition: PlutoCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        ),
      );
    } else if (stateManager.keyPressed.ctrl) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _selectMode(PlutoStateManager stateManager) {
    if (stateManager.isCurrentCell(cell)) {
      stateManager.handleOnSelected();
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _setCurrentCell(
    PlutoStateManager stateManager,
    PlutoCell cell,
    int rowIdx,
  ) {
    if (stateManager.isCurrentCell(cell) != true) {
      stateManager.setCurrentCell(cell, rowIdx, notify: false);
    }
  }
}

enum PlutoGestureType {
  onTapUp,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
}

extension PlutoGestureTypeExtension on PlutoGestureType {
  bool get isOnTapUp => this == PlutoGestureType.onTapUp;

  bool get isOnLongPressStart => this == PlutoGestureType.onLongPressStart;

  bool get isOnLongPressMoveUpdate =>
      this == PlutoGestureType.onLongPressMoveUpdate;

  bool get isOnLongPressEnd => this == PlutoGestureType.onLongPressEnd;
}
