import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IEditingState {
  /// Editing status of the current.
  bool get isEditing;

  /// Automatically set to editing state when cell is selected.
  bool get autoEditing;

  TextEditingController? textEditingController;

  /// Change the editing status of the current cell.
  void setEditing(
    bool flag, {
    bool notify = true,
  });

  void setAutoEditing(
    bool flag, {
    bool notify = true,
  });

  /// Toggle the editing status of the current cell.
  void toggleEditing({bool notify = true});

  /// Paste based on current cell
  void pasteCellValue(List<List<String>> textList);

  /// Cast the value according to the column type.
  dynamic castValueByColumnType(dynamic value, PlutoColumn column);

  /// Change cell value
  /// [callOnChangedEvent] triggers a [PlutoOnChangedEventCallback] callback.
  void changeCellValue(
    PlutoCell cell,
    dynamic value, {
    bool callOnChangedEvent = true,
    bool force = false,
    bool notify = true,
  });
}

mixin EditingState implements IPlutoGridState {
  @override
  bool get isEditing => _isEditing;

  bool _isEditing = false;

  @override
  bool get autoEditing =>
      _autoEditing || currentColumn?.enableAutoEditing == true;

  bool _autoEditing = false;

  @override
  TextEditingController? textEditingController;

  @override
  void setEditing(
    bool flag, {
    bool notify = true,
  }) {
    if (mode.isSelect) {
      return;
    }

    if (currentColumn?.enableEditingMode != true) {
      flag = false;
    }

    if (currentCell == null || _isEditing == flag) {
      return;
    }

    _isEditing = flag;

    clearCurrentSelecting(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setAutoEditing(
    bool flag, {
    bool notify = true,
  }) {
    if (_autoEditing == flag) {
      return;
    }

    _autoEditing = flag;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void toggleEditing({bool notify = true}) => setEditing(
        !(_isEditing == true),
        notify: notify,
      );

  @override
  void pasteCellValue(List<List<String>> textList) {
    if (currentCellPosition == null) {
      return;
    }

    if (selectingMode.isRow && currentSelectingRows.isNotEmpty) {
      _pasteCellValueIntoSelectingRows(textList: textList);
    } else {
      int? columnStartIdx;

      int columnEndIdx;

      int? rowStartIdx;

      int rowEndIdx;

      if (currentSelectingPosition == null) {
        // No cell selection : Paste in order based on the current cell
        columnStartIdx = currentCellPosition!.columnIdx;

        columnEndIdx =
            currentCellPosition!.columnIdx! + textList.first.length - 1;

        rowStartIdx = currentCellPosition!.rowIdx;

        rowEndIdx = currentCellPosition!.rowIdx! + textList.length - 1;
      } else {
        // If there are selected cells : Paste in order from selected cell range
        columnStartIdx = min(currentCellPosition!.columnIdx!,
            currentSelectingPosition!.columnIdx!);

        columnEndIdx = max(currentCellPosition!.columnIdx!,
            currentSelectingPosition!.columnIdx!);

        rowStartIdx = min(
            currentCellPosition!.rowIdx!, currentSelectingPosition!.rowIdx!);

        rowEndIdx = max(
            currentCellPosition!.rowIdx!, currentSelectingPosition!.rowIdx!);
      }

      _pasteCellValueInOrder(
        textList: textList,
        rowIdxList: [for (var i = rowStartIdx!; i <= rowEndIdx; i += 1) i],
        columnStartIdx: columnStartIdx,
        columnEndIdx: columnEndIdx,
      );
    }

    notifyListeners();
  }

  @override
  dynamic castValueByColumnType(dynamic value, PlutoColumn column) {
    if (column.type is PlutoColumnTypeWithNumberFormat) {
      return (column.type as PlutoColumnTypeWithNumberFormat)
          .toNumber(column.type.applyFormat(value));
    }

    return value;
  }

  @override
  void changeCellValue(
    PlutoCell cell,
    dynamic value, {
    bool callOnChangedEvent = true,
    bool force = false,
    bool notify = true,
  }) {
    final currentColumn = cell.column;

    final currentRow = cell.row;

    final dynamic oldValue = cell.value;

    value = filteredCellValue(
      column: currentColumn,
      newValue: value,
      oldValue: oldValue,
    );

    value = castValueByColumnType(value, currentColumn);

    if (force == false &&
        canNotChangeCellValue(
          column: currentColumn,
          row: currentRow,
          newValue: value,
          oldValue: oldValue,
        )) {
      return;
    }

    currentRow.setState(PlutoRowState.updated);

    cell.value = value;

    if (callOnChangedEvent == true && onChanged != null) {
      onChanged!(PlutoGridOnChangedEvent(
        columnIdx: columnIndex(currentColumn),
        column: currentColumn,
        rowIdx: refRows.indexOf(currentRow),
        row: currentRow,
        value: value,
        oldValue: oldValue,
      ));
    }

    if (notify) {
      notifyListeners();
    }
  }

  void _pasteCellValueIntoSelectingRows({List<List<String>>? textList}) {
    int columnStartIdx = 0;

    int columnEndIdx = refColumns.length - 1;

    final Set<Key> selectingRowKeys =
        Set.from(currentSelectingRows.map((e) => e.key));

    List<int> rowIdxList = [];

    for (int i = 0; i < refRows.length; i += 1) {
      final currentRowKey = refRows[i].key;

      if (selectingRowKeys.contains(currentRowKey)) {
        selectingRowKeys.remove(currentRowKey);
        rowIdxList.add(i);
      }

      if (selectingRowKeys.isEmpty) {
        break;
      }
    }

    _pasteCellValueInOrder(
      textList: textList,
      rowIdxList: rowIdxList,
      columnStartIdx: columnStartIdx,
      columnEndIdx: columnEndIdx,
    );
  }

  void _pasteCellValueInOrder({
    List<List<String>>? textList,
    required List<int> rowIdxList,
    int? columnStartIdx,
    int? columnEndIdx,
  }) {
    final List<int> columnIndexes = columnIndexesByShowFrozen;

    int textRowIdx = 0;

    for (int i = 0; i < rowIdxList.length; i += 1) {
      final rowIdx = rowIdxList[i];

      int textColumnIdx = 0;

      if (rowIdx > refRows.length - 1) {
        break;
      }

      if (textRowIdx > textList!.length - 1) {
        textRowIdx = 0;
      }

      for (int columnIdx = columnStartIdx!;
          columnIdx <= columnEndIdx!;
          columnIdx += 1) {
        if (columnIdx > columnIndexes.length - 1) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        final currentColumn = refColumns[columnIndexes[columnIdx]];

        final currentCell = refRows[rowIdx].cells[currentColumn.field]!;

        dynamic newValue = textList[textRowIdx][textColumnIdx];

        final dynamic oldValue = currentCell.value;

        newValue = filteredCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        );

        newValue = castValueByColumnType(newValue, currentColumn);

        if (canNotChangeCellValue(
          column: currentColumn,
          row: refRows[rowIdx],
          newValue: newValue,
          oldValue: oldValue,
        )) {
          ++textColumnIdx;
          continue;
        }

        refRows[rowIdx].setState(PlutoRowState.updated);

        currentCell.value = newValue;

        if (onChanged != null) {
          onChanged!(PlutoGridOnChangedEvent(
            columnIdx: columnIndexes[columnIdx],
            column: currentColumn,
            rowIdx: rowIdx,
            row: refRows[rowIdx],
            value: newValue,
            oldValue: oldValue,
          ));
        }

        ++textColumnIdx;
      }
      ++textRowIdx;
    }
  }
}
