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

  bool get hasCurrentSelectingPosition;

  /// Rows of currently selected.
  /// Only valid in [PlutoSelectingMode.Row].
  List<PlutoRow> get currentSelectingRows;

  List<PlutoRow> _currentSelectingRows;

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

  /// Sets the currentSelectingRows by range.
  /// [from] rowIdx of [rows].
  /// [to] rowIdx of [rows].
  void setCurrentSelectingRowsByRange(int from, int to);

  void toggleSelectingRow(int rowIdx);

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(PlutoCell cell, dynamic value);

  bool isSelectingInteraction();

  bool isSelectedRow(Key rowKey);

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

  bool get hasCurrentSelectingPosition => _currentSelectingPosition != null;

  List<PlutoRow> get currentSelectingRows => _currentSelectingRows;

  List<PlutoRow> _currentSelectingRows = [];

  String get currentSelectingText {
    final bool fromSelectingRows =
        _selectingMode.isRow && _currentSelectingRows.length > 0;

    final bool fromSelectingPosition =
        currentCellPosition != null && currentSelectingPosition != null;

    final bool fromCurrentCell = currentCellPosition != null;

    if (fromSelectingRows) {
      return _selectingTextFromSelectingRows();
    } else if (fromSelectingPosition) {
      return _selectingTextFromSelectingPosition();
    } else if (fromCurrentCell) {
      return _selectingTextFromCurrentCell();
    }

    return '';
  }

  void setSelecting(bool flag) {
    if (_selectingMode.isNone) {
      return;
    }

    if (currentCell == null || _isSelecting == flag) {
      return;
    }

    _isSelecting = flag;

    if (isEditing == true) {
      setEditing(false, notify: false);
    }

    notifyListeners(checkCellValue: false);
  }

  void setSelectingMode(PlutoSelectingMode mode) {
    if (_selectingMode == mode) {
      return;
    }

    _currentSelectingRows = [];

    _currentSelectingPosition = null;

    _selectingMode = mode;

    notifyListeners(checkCellValue: false);
  }

  void setAllCurrentSelecting() {
    if (_rows == null || _rows.length < 1) {
      return;
    }

    switch (_selectingMode) {
      case PlutoSelectingMode.Square:
      case PlutoSelectingMode._Horizontal:
        setCurrentCell(firstCell, 0, notify: false);

        setCurrentSelectingPosition(
          columnIdx: _columns.length - 1,
          rowIdx: _rows.length - 1,
        );
        break;
      case PlutoSelectingMode.Row:
        if (currentCell == null) {
          setCurrentCell(firstCell, 0, notify: false);
        }

        _currentSelectingPosition = PlutoCellPosition(
          columnIdx: _columns.length - 1,
          rowIdx: _rows.length - 1,
        );

        setCurrentSelectingRowsByRange(0, _rows.length - 1);
        break;
      case PlutoSelectingMode.None:
      default:
        break;
    }
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

    if (_selectingMode.isRow) {
      setCurrentSelectingRowsByRange(_currentRowIdx, rowIdx, notify: false);
    }

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  void setCurrentSelectingPositionWithOffset(Offset offset) {
    if (currentCell == null) {
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

    if (rowIdx == null) {
      return;
    }

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

  void setCurrentSelectingRowsByRange(int from, int to, {notify: true}) {
    if (!_selectingMode.isRow) {
      return;
    }

    final _from = min(from, to);

    final _to = max(from, to) + 1;

    if (_from < 0 || _to > _rows.length) {
      return;
    }

    _currentSelectingRows = _rows.getRange(_from, _to).toList();

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  void toggleSelectingRow(int rowIdx, {notify: true}) {
    if (!_selectingMode.isRow) {
      return;
    }

    if (rowIdx == null || rowIdx < 0 || rowIdx > _rows.length - 1) {
      return;
    }

    final PlutoRow row = _rows[rowIdx];

    final keys =
        _currentSelectingRows.map((e) => e.key).toList(growable: false);

    if (keys.contains(row.key)) {
      _currentSelectingRows.removeWhere((element) => element.key == row.key);
    } else {
      _currentSelectingRows.add(row);
    }

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  void handleAfterSelectingRow(PlutoCell cell, dynamic value) {
    moveCurrentCell(MoveDirection.Down, notify: false);

    changeCellValue(cell._key, value, notify: false);

    setEditing(true, notify: false);

    notifyListeners();
  }

  bool isSelectingInteraction() {
    return !_selectingMode.isNone &&
        (_keyPressed.shift || _keyPressed.ctrl) &&
        currentCell != null;
  }

  bool isSelectedRow(Key rowKey) {
    if (!_selectingMode.isRow || _currentSelectingRows.length < 1) {
      return false;
    }

    final List<Key> selectedRowKeys =
        _currentSelectingRows.map((e) => e.key).toList(growable: false);

    return selectedRowKeys.contains(rowKey);
  }

  // todo : code cleanup
  bool isSelectedCell(PlutoCell cell, PlutoColumn column, int rowIdx) {
    if (_selectingMode.isNone) {
      return false;
    }

    if (currentCellPosition == null) {
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
    } else if (_selectingMode._isHorizontal) {
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
    } else if (_selectingMode.isRow) {
      return false;
    } else {
      throw ('selectingMode is not handled');
    }
  }

  String _selectingTextFromSelectingRows() {
    final columnIndexes = columnIndexesByShowFixed();

    List<String> rowText = [];

    _currentSelectingRows.forEach((row) {
      List<String> columnText = [];

      for (var i = 0; i < columnIndexes.length; i += 1) {
        final String field = _columns[columnIndexes[i]].field;

        columnText.add(row.cells[field].value.toString());
      }

      rowText.add(columnText.join('\t'));
    });

    return rowText.join('\n');
  }

  String _selectingTextFromSelectingPosition() {
    final columnIndexes = columnIndexesByShowFixed();

    List<String> rowText = [];

    int columnStartIdx =
        min(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int columnEndIdx =
        max(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowStartIdx =
        min(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    int rowEndIdx =
        max(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    for (var i = rowStartIdx; i <= rowEndIdx; i += 1) {
      List<String> columnText = [];

      for (var j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = _columns[columnIndexes[j]].field;

        columnText.add(_rows[i].cells[field].value.toString());
      }

      rowText.add(columnText.join('\t'));
    }

    return rowText.join('\n');
  }

  String _selectingTextFromCurrentCell() {
    return currentCell.value.toString();
  }
}
