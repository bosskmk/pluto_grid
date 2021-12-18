import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IDraggingRowState {
  bool get isDraggingRow;

  List<PlutoRow?>? get dragRows;

  int? get dragTargetRowIdx;

  bool get canRowDrag;

  void setIsDraggingRow(
    bool flag, {
    bool notify = true,
  });

  void setDragRows(
    List<PlutoRow> rows, {
    bool notify = true,
  });

  void setDragTargetRowIdx(
    int rowIdx, {
    bool notify = true,
  });

  bool isRowIdxDragTarget(int rowIdx);

  bool isRowIdxTopDragTarget(int rowIdx);

  bool isRowIdxBottomDragTarget(int rowIdx);

  bool isRowBeingDragged(Key rowKey);
}

mixin DraggingRowState implements IPlutoGridState {
  @override
  bool get isDraggingRow => _isDraggingRow;

  bool _isDraggingRow = false;

  @override
  List<PlutoRow?>? get dragRows => _dragRows;

  List<PlutoRow?>? _dragRows;

  @override
  int? get dragTargetRowIdx => _dragTargetRowIdx;

  int? _dragTargetRowIdx;

  @override
  bool get canRowDrag => !hasSortedColumn && !hasFilter;

  @override
  void setIsDraggingRow(
    bool flag, {
    bool notify = true,
  }) {
    if (_isDraggingRow == flag) {
      return;
    }

    _isDraggingRow = flag;

    _clearDraggingState();

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setDragRows(
    List<PlutoRow?>? rows, {
    bool notify = true,
  }) {
    _dragRows = rows;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setDragTargetRowIdx(
    int? rowIdx, {
    bool notify = true,
  }) {
    if (_dragTargetRowIdx == rowIdx) {
      return;
    }

    _dragTargetRowIdx = rowIdx;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  bool isRowIdxDragTarget(int? rowIdx) {
    return rowIdx != null &&
        _dragTargetRowIdx != null &&
        _dragTargetRowIdx! <= rowIdx &&
        rowIdx < _dragTargetRowIdx! + _dragRows!.length;
  }

  @override
  bool isRowIdxTopDragTarget(int? rowIdx) {
    return rowIdx != null &&
        _dragTargetRowIdx != null &&
        _dragTargetRowIdx == rowIdx &&
        rowIdx + _dragRows!.length <= refRows!.length;
  }

  @override
  bool isRowIdxBottomDragTarget(int? rowIdx) {
    return rowIdx != null &&
        _dragTargetRowIdx != null &&
        rowIdx == _dragTargetRowIdx! + _dragRows!.length - 1;
  }

  @override
  bool isRowBeingDragged(Key? rowKey) {
    return rowKey != null &&
        _isDraggingRow == true &&
        dragRows != null &&
        dragRows!.firstWhere((element) => element!.key == rowKey,
                orElse: () => null) !=
            null;
  }

  void _clearDraggingState() {
    _dragRows = null;

    _dragTargetRowIdx = null;
  }
}
