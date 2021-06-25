import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridCellGestureEvent extends PlutoGridEvent {
  final PlutoGridGestureType? gestureType;
  final Offset? offset;
  final PlutoCell? cell;
  final PlutoColumn? column;
  final int? rowIdx;

  PlutoGridCellGestureEvent({
    this.gestureType,
    this.offset,
    this.cell,
    this.column,
    this.rowIdx,
  });

  @override
  void handler(PlutoGridStateManager? stateManager) {
    if (gestureType == null ||
        offset == null ||
        cell == null ||
        column == null ||
        rowIdx == null) {
      return;
    }

    switch (gestureType) {
      case PlutoGridGestureType.onTapUp:
        _onTapUp(stateManager!);
        break;
      case PlutoGridGestureType.onLongPressStart:
        _onLongPressStart(stateManager!);
        break;
      case PlutoGridGestureType.onLongPressMoveUpdate:
        _onLongPressMoveUpdate(stateManager!);
        break;
      case PlutoGridGestureType.onLongPressEnd:
        _onLongPressEnd(stateManager!);
        break;
      case PlutoGridGestureType.onDoubleTap:
        _onDoubleTap(stateManager!);
        break;
      default:
    }
  }

  void _onTapUp(PlutoGridStateManager stateManager) {
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

  void _onLongPressStart(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(true);

    if (stateManager.selectingMode.isRow) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _onLongPressMoveUpdate(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setCurrentSelectingPositionWithOffset(offset);

    stateManager.eventManager!.addEvent(PlutoGridMoveUpdateEvent(
      offset: offset,
    ));
  }

  void _onLongPressEnd(PlutoGridStateManager stateManager) {
    _setCurrentCell(stateManager, cell, rowIdx);

    stateManager.setSelecting(false);
  }

  void _onDoubleTap(PlutoGridStateManager stateManager) {
    stateManager.onRowDoubleTap!(PlutoGridOnRowDoubleTapEvent(
        row: stateManager.getRowByIdx(rowIdx), cell: cell));
  }

  bool _setKeepFocusAndCurrentCell(PlutoGridStateManager stateManager) {
    if (stateManager.hasFocus) {
      return false;
    }

    stateManager.setKeepFocus(true);

    return stateManager.isCurrentCell(cell);
  }

  void _selecting(PlutoGridStateManager stateManager) {
    if (stateManager.keyPressed.shift) {
      final int? columnIdx = stateManager.columnIndex(column);

      stateManager.setCurrentSelectingPosition(
        cellPosition: PlutoGridCellPosition(
          columnIdx: columnIdx,
          rowIdx: rowIdx,
        ),
      );
    } else if (stateManager.keyPressed.ctrl) {
      stateManager.toggleSelectingRow(rowIdx);
    }
  }

  void _selectMode(PlutoGridStateManager stateManager) {
    if (stateManager.isCurrentCell(cell)) {
      stateManager.handleOnSelected();
    } else {
      stateManager.setCurrentCell(cell, rowIdx);
    }
  }

  void _setCurrentCell(
    PlutoGridStateManager stateManager,
    PlutoCell? cell,
    int? rowIdx,
  ) {
    if (stateManager.isCurrentCell(cell) != true) {
      stateManager.setCurrentCell(cell, rowIdx, notify: false);
    }
  }
}

enum PlutoGridGestureType {
  onTapUp,
  onLongPressStart,
  onLongPressMoveUpdate,
  onLongPressEnd,
  onDoubleTap,
}
