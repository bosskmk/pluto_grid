import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Event called when a row is dragged.
class PlutoGridDragRowsEvent extends PlutoGridEvent {
  final Offset? offset;
  final PlutoGridDragType? dragType;
  final List<PlutoRow?>? rows;

  PlutoGridDragRowsEvent({
    this.offset,
    this.dragType,
    this.rows,
  });

  void handler(PlutoGridStateManager? stateManager) {
    if (dragType == null ||
        (!dragType.isStart && offset == null) ||
        rows == null) {
      return;
    }

    if (dragType.isStart) {
      _startDrag(stateManager!);
    } else if (dragType.isUpdate) {
      _updateDrag(stateManager!);
    } else if (dragType.isEnd) {
      _endDrag(stateManager!);
    }
  }

  void _startDrag(PlutoGridStateManager stateManager) {
    stateManager.setIsDraggingRow(true, notify: false);
    stateManager.setDragRows(rows);
  }

  void _updateDrag(PlutoGridStateManager stateManager) {
    stateManager.setDragTargetRowIdx(
      stateManager.getRowIdxByOffset(offset!.dy),
    );
  }

  void _endDrag(PlutoGridStateManager stateManager) {
    stateManager.moveRowsByOffset(
      rows,
      offset!.dy,
      notify: false,
    );
    stateManager.setIsDraggingRow(false);
  }
}

enum PlutoGridDragType {
  start,
  update,
  end,
}

extension PlutoGridDragTypeExtension on PlutoGridDragType? {
  bool get isStart => this == PlutoGridDragType.start;

  bool get isUpdate => this == PlutoGridDragType.update;

  bool get isEnd => this == PlutoGridDragType.end;
}

enum PlutoGridDragItemType {
  rows,
}

extension PlutoGridDragItemExtension on PlutoGridDragItemType {
  bool get isRows => this == PlutoGridDragItemType.rows;
}
