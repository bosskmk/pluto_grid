part of '../../../pluto_grid.dart';

abstract class ISelectingState {
  /// Multi-selection state.
  bool get isSelecting;

  /// [selectingMode]
  PlutoSelectingMode get selectingMode;

  /// Current position of multi-select cell.
  /// Calculate the currently selected cell and its multi-selection range.
  PlutoCellPosition get currentSelectingPosition;

  /// Position list of currently selected.
  /// Only valid in [PlutoSelectingMode.square].
  ///
  /// ```dart
  /// stateManager.currentSelectingPositionList.forEach((element) {
  ///   final cellValue = stateManager.rows[element.rowIdx].cells[element.field].value;
  /// });
  /// ```
  List<PlutoSelectingCellPosition> get currentSelectingPositionList;

  bool get hasCurrentSelectingPosition;

  /// Rows of currently selected.
  /// Only valid in [PlutoSelectingMode.row].
  List<PlutoRow> get currentSelectingRows;

  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
  String get currentSelectingText;

  /// Change Multi-Select Status.
  void setSelecting(bool flag);

  void setSelectingMode(PlutoSelectingMode mode);

  void setAllCurrentSelecting();

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPosition({
    PlutoCellPosition cellPosition,
    bool notify = true,
  });

  void setCurrentSelectingPositionByCellKey(
    Key cellKey, {
    bool notify = true,
  });

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPositionWithOffset(Offset offset);

  /// Sets the currentSelectingRows by range.
  /// [from] rowIdx of rows.
  /// [to] rowIdx of rows.
  void setCurrentSelectingRowsByRange(int from, int to, {bool notify = true});

  void clearCurrentSelectingPosition({bool notify = true});

  void clearCurrentSelectingRows({bool notify = true});

  void toggleSelectingRow(int rowIdx, {notify = true});

  bool isSelectingInteraction();

  bool isSelectedRow(Key rowKey);

  /// Whether the cell is the currently multi selected cell.
  bool isSelectedCell(PlutoCell cell, PlutoColumn column, int rowIdx);

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(PlutoCell cell, dynamic value);
}

mixin SelectingState implements IPlutoState {
  bool get isSelecting => _isSelecting;

  bool _isSelecting = false;

  PlutoSelectingMode get selectingMode => _selectingMode;

  PlutoSelectingMode _selectingMode = PlutoSelectingMode.square;

  PlutoCellPosition get currentSelectingPosition => _currentSelectingPosition;

  PlutoCellPosition _currentSelectingPosition;

  List<PlutoSelectingCellPosition> get currentSelectingPositionList {
    if (!_selectingMode.isSquare ||
        currentCellPosition == null ||
        currentSelectingPosition == null) {
      return [];
    }

    final columnIndexes = columnIndexesByShowFrozen;

    int columnStartIdx =
        min(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int columnEndIdx =
        max(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowStartIdx =
        min(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    int rowEndIdx =
        max(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    List<PlutoSelectingCellPosition> positions = [];

    for (var i = rowStartIdx; i <= rowEndIdx; i += 1) {
      for (var j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = _columns[columnIndexes[j]].field;

        positions.add(PlutoSelectingCellPosition(
          rowIdx: i,
          field: field,
        ));
      }
    }

    return positions;
  }

  bool get hasCurrentSelectingPosition => _currentSelectingPosition != null;

  List<PlutoRow> get currentSelectingRows => _currentSelectingRows;

  List<PlutoRow> _currentSelectingRows = [];

  String get currentSelectingText {
    final bool fromSelectingRows =
        _selectingMode.isRow && _currentSelectingRows.isNotEmpty;

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

    notifyListeners();
  }

  void setSelectingMode(PlutoSelectingMode mode) {
    if (_selectingMode == mode) {
      return;
    }

    _currentSelectingRows = [];

    _currentSelectingPosition = null;

    _selectingMode = mode;

    notifyListeners();
  }

  void setAllCurrentSelecting() {
    if (_rows == null || _rows.isEmpty) {
      return;
    }

    switch (_selectingMode) {
      case PlutoSelectingMode.square:
      case PlutoSelectingMode._horizontal:
        setCurrentCell(firstCell, 0, notify: false);

        setCurrentSelectingPosition(
          cellPosition: PlutoCellPosition(
            columnIdx: _columns.length - 1,
            rowIdx: _rows.length - 1,
          ),
        );
        break;
      case PlutoSelectingMode.row:
        if (currentCell == null) {
          setCurrentCell(firstCell, 0, notify: false);
        }

        _currentSelectingPosition = PlutoCellPosition(
          columnIdx: _columns.length - 1,
          rowIdx: _rows.length - 1,
        );

        setCurrentSelectingRowsByRange(0, _rows.length - 1);
        break;
      case PlutoSelectingMode.none:
      default:
        break;
    }
  }

  void setCurrentSelectingPosition({
    PlutoCellPosition cellPosition,
    bool notify = true,
  }) {
    if (_selectingMode.isNone) {
      return;
    }

    if (_currentSelectingPosition == cellPosition) {
      return;
    }

    _currentSelectingPosition =
        isInvalidCellPosition(cellPosition) ? null : cellPosition;

    if (_currentSelectingPosition != null && _selectingMode.isRow) {
      setCurrentSelectingRowsByRange(
        currentRowIdx,
        _currentSelectingPosition.rowIdx,
        notify: false,
      );
    }

    if (notify) {
      notifyListeners();
    }
  }

  void setCurrentSelectingPositionByCellKey(
    Key cellKey, {
    bool notify = true,
  }) {
    if (cellKey == null) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: cellPositionByCellKey(cellKey),
      notify: notify,
    );
  }

  void setCurrentSelectingPositionWithOffset(Offset offset) {
    if (currentCell == null) {
      return;
    }

    final double gridBodyOffsetDy = gridGlobalOffset.dy +
        PlutoGridSettings.gridBorderWidth +
        headerHeight +
        columnHeight;

    double currentCellOffsetDy = (currentRowIdx * rowTotalHeight) +
        gridBodyOffsetDy -
        scroll.vertical.offset;

    if (gridBodyOffsetDy > offset.dy) {
      return;
    }

    int rowIdx = (((currentCellOffsetDy - offset.dy) / rowTotalHeight).ceil() -
            currentRowIdx)
        .abs();

    if (rowIdx == null) {
      return;
    }

    int columnIdx;

    double currentWidth = 0.0;
    currentWidth += gridGlobalOffset.dx;
    currentWidth += PlutoGridSettings.gridPadding;
    currentWidth += PlutoGridSettings.gridBorderWidth;

    final columnIndexes = columnIndexesByShowFrozen;

    final _rightBlankOffset = rightBlankOffset;
    final _horizontalScrollOffset = scroll.horizontal.offset;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      final column = _columns[columnIndexes[i]];

      currentWidth += column.width;

      final rightFrozenColumnOffset =
          column.frozen.isRight && showFrozenColumn ? _rightBlankOffset : 0;

      if (currentWidth + rightFrozenColumnOffset >
          offset.dx + _horizontalScrollOffset) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      return;
    }

    setCurrentSelectingPosition(
      cellPosition: PlutoCellPosition(
        columnIdx: columnIdx,
        rowIdx: rowIdx,
      ),
    );
  }

  void setCurrentSelectingRowsByRange(int from, int to, {bool notify = true}) {
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
      notifyListeners();
    }
  }

  void clearCurrentSelectingPosition({bool notify = true}) {
    if (_currentSelectingPosition == null) {
      return;
    }

    _currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

  void clearCurrentSelectingRows({bool notify = true}) {
    if (_currentSelectingRows == null || _currentSelectingRows.isEmpty) {
      return;
    }

    _currentSelectingRows = [];

    if (notify) {
      notifyListeners();
    }
  }

  void toggleSelectingRow(int rowIdx, {notify = true}) {
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
      notifyListeners();
    }
  }

  bool isSelectingInteraction() {
    return !_selectingMode.isNone &&
        (keyPressed.shift || keyPressed.ctrl) &&
        currentCell != null;
  }

  bool isSelectedRow(Key rowKey) {
    if (rowKey == null ||
        !_selectingMode.isRow ||
        _currentSelectingRows.isEmpty) {
      return false;
    }

    return _currentSelectingRows.firstWhere(
          (element) => element.key == rowKey,
          orElse: () => null,
        ) !=
        null;
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
      throw Exception('selectingMode is not handled');
    }
  }

  void handleAfterSelectingRow(PlutoCell cell, dynamic value) {
    changeCellValue(cell._key, value, notify: false);

    if (configuration.enableMoveDownAfterSelecting) {
      moveCurrentCell(MoveDirection.down, notify: false);

      setEditing(true, notify: false);
    }

    setKeepFocus(true, notify: false);

    notifyListeners();
  }

  String _selectingTextFromSelectingRows() {
    final columnIndexes = columnIndexesByShowFrozen;

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
    final columnIndexes = columnIndexesByShowFrozen;

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
