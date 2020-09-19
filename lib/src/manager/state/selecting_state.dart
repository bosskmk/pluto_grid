part of '../../../pluto_grid.dart';

abstract class ISelectingState {
  /// Multi-selection state.
  bool get isSelecting;

  bool _isSelecting;

  /// [selectingMode]
  PlutoSelectingMode get selectingMode;

  PlutoSelectingMode _selectingMode;

  /// Current position of multi-select cell.
  /// Calculate the currently selected cell and its multi-selection range.
  PlutoCellPosition get currentSelectingPosition;

  PlutoCellPosition _currentSelectingPosition;

  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
  String get currentSelectingText;

  /// Change Multi-Select Status.
  void setSelecting(bool flag);

  void setSelectingMode(PlutoSelectingMode mode);

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPosition({
    int columnIdx,
    int rowIdx,
    bool notify = true,
  });

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPositionWithOffset(Offset offset);

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(PlutoCell cell, dynamic value);

  /// Whether the cell is the currently multi selected cell.
  bool isSelectedCell(PlutoCell cell, PlutoColumn column, int rowIdx);
}

mixin SelectingState implements IPlutoState {
  bool get isSelecting => _isSelecting;

  bool _isSelecting = false;

  PlutoSelectingMode get selectingMode => _selectingMode;

  PlutoSelectingMode _selectingMode = PlutoSelectingMode.Square;

  PlutoCellPosition get currentSelectingPosition => _currentSelectingPosition;

  PlutoCellPosition _currentSelectingPosition;

  String get currentSelectingText {
    List<String> textList = [];

    int columnStartIdx =
    min(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowStartIdx =
    min(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    int columnEndIdx =
    max(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowEndIdx =
    max(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    final columnIndexes = columnIndexesByShowFixed();

    for (var i = rowStartIdx; i <= rowEndIdx; i += 1) {
      List<String> columnText = [];

      for (var j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = _columns[columnIndexes[j]].field;

        columnText.add(_rows[i].cells[field].value.toString());
      }

      textList.add(columnText.join('\t'));
    }

    return textList.join('\n');
  }

  void setSelecting(bool flag) {
    if (_selectingMode.isNone) {
      return;
    }

    if (_currentCell == null || _isSelecting == flag) {
      return;
    }

    _isSelecting = flag;

    if (_isEditing == true) {
      setEditing(false, notify: false);
    }

    notifyListeners(checkCellValue: false);
  }

  void setSelectingMode(PlutoSelectingMode mode) {
    if (_selectingMode == mode) {
      return;
    }

    _selectingMode = mode;

    notifyListeners(checkCellValue: false);
  }

  void setCurrentSelectingPosition({
    int columnIdx,
    int rowIdx,
    bool notify = true,
  }) {
    if (_selectingMode.isNone) {
      return;
    }

    _currentSelectingPosition =
        PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  void setCurrentSelectingPositionWithOffset(Offset offset) {
    if (_currentCell == null) {
      return;
    }

    final double gridBodyOffsetDy = gridGlobalOffset.dy +
        PlutoDefaultSettings.gridBorderWidth +
        layout.headerHeight +
        PlutoDefaultSettings.rowTotalHeight;

    double currentCellOffsetDy =
        (currentRowIdx * PlutoDefaultSettings.rowTotalHeight) +
            gridBodyOffsetDy -
            _scroll.vertical.offset;

    if (gridBodyOffsetDy > offset.dy) {
      return;
    }

    int rowIdx = (((currentCellOffsetDy - offset.dy) /
        PlutoDefaultSettings.rowTotalHeight)
        .ceil() -
        currentRowIdx)
        .abs();

    int columnIdx;

    double currentWidth = 0.0;
    currentWidth += gridGlobalOffset.dx;
    currentWidth += PlutoDefaultSettings.gridPadding;
    currentWidth += PlutoDefaultSettings.gridBorderWidth;

    final columnIndexes = columnIndexesByShowFixed();

    for (var i = 0; i < columnIndexes.length; i += 1) {
      currentWidth += _columns[columnIndexes[i]].width;

      if (currentWidth > offset.dx + _scroll.horizontal.offset) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      return;
    }

    setCurrentSelectingPosition(columnIdx: columnIdx, rowIdx: rowIdx);
  }

  void handleAfterSelectingRow(PlutoCell cell, dynamic value) {
    moveCurrentCell(MoveDirection.Down, notify: false);

    changeCellValue(cell._key, value, notify: false);

    setEditing(true, notify: false);

    notifyListeners();
  }

  // todo : code cleanup
  bool isSelectedCell(PlutoCell cell, PlutoColumn column, int rowIdx) {
    if (_selectingMode.isNone) {
      return false;
    }

    if (isCurrentCell(cell) == true) {
      return false;
    }

    if (_currentSelectingPosition == null) {
      return false;
    }

    if (_selectingMode.isSquare) {
      final bool inRangeOfRows = min(currentCellPosition.rowIdx,
          _currentSelectingPosition.rowIdx) <=
          rowIdx &&
          rowIdx <=
              max(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      if (inRangeOfRows == false) {
        return false;
      }

      final int columnIdx = columnIndex(column);

      if (columnIdx == null) {
        return false;
      }

      final bool inRangeOfColumns = min(currentCellPosition.columnIdx,
          currentSelectingPosition.columnIdx) <=
          columnIdx &&
          columnIdx <=
              max(currentCellPosition.columnIdx,
                  currentSelectingPosition.columnIdx);

      if (inRangeOfColumns == false) {
        return false;
      }

      return true;
    } else if (_selectingMode.isHorizontal) {
      int startRowIdx =
      min(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      int endRowIdx =
      max(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      final int columnIdx = columnIndex(column);

      if (columnIdx == null) {
        return false;
      }

      int startColumnIdx;

      int endColumnIdx;

      if (currentCellPosition.rowIdx < _currentSelectingPosition.rowIdx) {
        startColumnIdx = currentCellPosition.columnIdx;
        endColumnIdx = _currentSelectingPosition.columnIdx;
      } else if (currentCellPosition.rowIdx >
          _currentSelectingPosition.rowIdx) {
        startColumnIdx = _currentSelectingPosition.columnIdx;
        endColumnIdx = currentCellPosition.columnIdx;
      } else {
        startColumnIdx = min(
            currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx);
        endColumnIdx = max(
            currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx);
      }

      if (rowIdx == startRowIdx && startRowIdx == endRowIdx) {
        return !(columnIdx < startColumnIdx || columnIdx > endColumnIdx);
      } else if (rowIdx == startRowIdx && columnIdx >= startColumnIdx) {
        return true;
      } else if (rowIdx == endRowIdx && columnIdx <= endColumnIdx) {
        return true;
      } else if (rowIdx > startRowIdx && rowIdx < endRowIdx) {
        return true;
      }

      return false;
    } else {
      throw ('selectingMode is not handled');
    }
  }
}