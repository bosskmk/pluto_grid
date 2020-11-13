part of '../../../pluto_grid.dart';

abstract class IDraggingRowState {
  bool get isDraggingRow;

  List<PlutoRow> get dragRows;

  int get dragTargetRowIdx;

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
}

mixin DraggingRowState implements IPlutoState {
  bool get isDraggingRow => _isDragging;

  bool _isDragging = false;

  List<PlutoRow> get dragRows => _dragRows;

  List<PlutoRow> _dragRows;

  int get dragTargetRowIdx => _dragTargetRowIdx;

  int _dragTargetRowIdx;

  void setIsDraggingRow(
    bool flag, {
    bool notify = true,
  }) {
    if (_isDragging == flag) {
      return;
    }

    _isDragging = flag;

    _clearDraggingState();

    if (notify) {
      notifyListeners();
    }
  }

  void setDragRows(
    List<PlutoRow> rows, {
    bool notify = true,
  }) {
    _dragRows = rows;

    if (notify) {
      notifyListeners();
    }
  }

  void setDragTargetRowIdx(
    int rowIdx, {
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

  bool isRowIdxDragTarget(int rowIdx) {
    return _dragTargetRowIdx != null &&
        _dragTargetRowIdx <= rowIdx &&
        rowIdx < _dragTargetRowIdx + _dragRows.length;
  }

  bool isRowIdxTopDragTarget(int rowIdx) {
    return _dragTargetRowIdx != null && _dragTargetRowIdx == rowIdx;
  }

  bool isRowIdxBottomDragTarget(int rowIdx) {
    return _dragTargetRowIdx != null &&
        rowIdx == _dragTargetRowIdx + _dragRows.length - 1;
  }

  void _clearDraggingState() {
    _dragRows = null;

    _dragTargetRowIdx = null;
  }
}
