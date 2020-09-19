part of '../../../pluto_grid.dart';

abstract class IEditingState {
  /// Editing status of the current.
  bool get isEditing;

  bool _isEditing;

  /// pre-modification cell value
  dynamic get cellValueBeforeEditing;

  dynamic _cellValueBeforeEditing;

  /// Change the editing status of the current cell.
  void setEditing(
      bool flag, {
        bool notify = true,
      });

  /// Toggle the editing status of the current cell.
  void toggleEditing();

  /// Paste based on current cell
  void pasteCellValue(List<List<String>> textList);

  /// Cast the value according to the column type.
  dynamic castValueByColumnType(dynamic value, PlutoColumn column);

  /// Change cell value
  /// [callOnChangedEvent] triggers a [PlutoOnChangedEventCallback] callback.
  void changeCellValue(
      Key cellKey,
      dynamic value, {
        bool callOnChangedEvent = true,
        bool notify = true,
      });
}

mixin EditingState implements IPlutoState {
  bool get isEditing => _isEditing;

  bool _isEditing = false;

  dynamic get cellValueBeforeEditing => _cellValueBeforeEditing;

  dynamic _cellValueBeforeEditing;

  void setEditing(
      bool flag, {
        bool notify = true,
      }) {
    if (mode.isSelect) {
      return;
    }

    if (_currentCell == null || _isEditing == flag) {
      return;
    }

    if (flag == true) {
      _cellValueBeforeEditing = currentCell.value;
    }

    _isEditing = flag;

    _currentSelectingPosition = null;

    if (notify) {
      notifyListeners(checkCellValue: false);
    }
  }

  void toggleEditing() => setEditing(!(_isEditing == true));

  void pasteCellValue(List<List<String>> textList) {
    if (currentCellPosition == null) {
      return;
    }

    int columnStartIdx;

    int rowStartIdx;

    int columnEndIdx;

    int rowEndIdx;

    if (_currentSelectingPosition == null) {
      // No cell selection : Paste in order based on the current cell
      columnStartIdx = currentCellPosition.columnIdx;

      rowStartIdx = currentCellPosition.rowIdx;

      columnEndIdx = currentCellPosition.columnIdx + textList.first.length;

      rowEndIdx = currentCellPosition.rowIdx + textList.length;
    } else {
      // If there are selected cells : Paste in order from selected cell range
      columnStartIdx = min(
          currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx);

      rowStartIdx =
          min(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      columnEndIdx = max(currentCellPosition.columnIdx,
          _currentSelectingPosition.columnIdx) +
          1;

      rowEndIdx =
          max(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx) + 1;
    }

    final List<int> columnIndexes = columnIndexesByShowFixed();

    int textRowIdx = 0;

    for (var rowIdx = rowStartIdx; rowIdx < rowEndIdx; rowIdx += 1) {
      int textColumnIdx = 0;

      if (rowIdx >= _rows.length) {
        break;
      }

      if (textRowIdx > textList.length - 1) {
        textRowIdx = 0;
      }

      for (var columnIdx = columnStartIdx;
      columnIdx < columnEndIdx;
      columnIdx += 1) {
        if (columnIdx >= columnIndexes.length) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        final currentColumn = _columns[columnIndexes[columnIdx]];

        final currentRow = _rows[rowIdx].cells[currentColumn.field];

        dynamic newValue = textList[textRowIdx][textColumnIdx];

        final dynamic oldValue = currentRow.value;

        newValue = filteredCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        );

        if (canNotChangeCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        )) {
          ++textColumnIdx;
          continue;
        }

        currentRow.value =
            newValue = castValueByColumnType(newValue, currentColumn);

        _onChanged(PlutoOnChangedEvent(
          columnIdx: columnIndexes[columnIdx],
          column: currentColumn,
          rowIdx: rowIdx,
          row: _rows[rowIdx],
          value: newValue,
          oldValue: oldValue,
        ));

        ++textColumnIdx;
      }
      ++textRowIdx;
    }

    notifyListeners();
  }

  dynamic castValueByColumnType(dynamic value, PlutoColumn column) {
    if (column.type.isNumber && value.runtimeType != num) {
      return num.tryParse(value.toString()) ?? 0;
    }

    return value;
  }

  void changeCellValue(
      Key cellKey,
      dynamic value, {
        bool callOnChangedEvent = true,
        bool notify = true,
      }) {
    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
      columnIdx < columnIndexes.length;
      columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == cellKey) {
          final currentColumn = _columns[columnIndexes[columnIdx]];

          final dynamic oldValue = _rows[rowIdx].cells[field].value;

          value = filteredCellValue(
            column: currentColumn,
            newValue: value,
            oldValue: oldValue,
          );

          if (canNotChangeCellValue(
            column: currentColumn,
            newValue: value,
            oldValue: oldValue,
          )) {
            return;
          }

          _rows[rowIdx].cells[field].value =
              value = castValueByColumnType(value, currentColumn);

          if (callOnChangedEvent == true && _onChanged != null) {
            _onChanged(PlutoOnChangedEvent(
              columnIdx: columnIdx,
              column: currentColumn,
              rowIdx: rowIdx,
              row: _rows[rowIdx],
              value: value,
              oldValue: oldValue,
            ));
          }

          if (notify) {
            notifyListeners();
          }

          return;
        }
      }
    }
  }
}