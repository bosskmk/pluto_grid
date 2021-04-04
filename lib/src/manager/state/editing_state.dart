import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IEditingState {
  /// Editing status of the current.
  bool get isEditing;

  /// pre-modification cell value
  dynamic get cellValueBeforeEditing;

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
    bool force = false,
    bool notify = true,
  });
}

mixin EditingState implements IPlutoGridState {
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

    if (currentColumn?.enableEditingMode != true) {
      flag = false;
    }

    if (currentCell == null || _isEditing == flag) {
      return;
    }

    if (flag == true) {
      _cellValueBeforeEditing = currentCell!.value;
    }

    _isEditing = flag;

    clearCurrentSelectingPosition(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void toggleEditing() => setEditing(!(_isEditing == true));

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
        columnStartIdx = min(
            currentCellPosition!.columnIdx!, currentSelectingPosition!.columnIdx!);

        columnEndIdx = max(
            currentCellPosition!.columnIdx!, currentSelectingPosition!.columnIdx!);

        rowStartIdx =
            min(currentCellPosition!.rowIdx!, currentSelectingPosition!.rowIdx!);

        rowEndIdx =
            max(currentCellPosition!.rowIdx!, currentSelectingPosition!.rowIdx!);
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
    bool force = false,
    bool notify = true,
  }) {
    for (var rowIdx = 0; rowIdx < refRows!.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = refColumns![columnIndexes[columnIdx]].field;

        if (refRows![rowIdx]!.cells[field]!.key == cellKey) {
          final currentColumn = refColumns![columnIndexes[columnIdx]];

          final dynamic oldValue = refRows![rowIdx]!.cells[field]!.value;

          value = filteredCellValue(
            column: currentColumn,
            newValue: value,
            oldValue: oldValue,
          );

          if (force == false &&
              canNotChangeCellValue(
                column: currentColumn,
                newValue: value,
                oldValue: oldValue,
              )) {
            return;
          }

          refRows![rowIdx]!.setState(PlutoRowState.updated);

          refRows![rowIdx]!.cells[field]!.value =
              value = castValueByColumnType(value, currentColumn);

          if (callOnChangedEvent == true && onChanged != null) {
            onChanged!(PlutoGridOnChangedEvent(
              columnIdx: columnIdx,
              column: currentColumn,
              rowIdx: rowIdx,
              row: refRows![rowIdx],
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

  void _pasteCellValueIntoSelectingRows({List<List<String>>? textList}) {
    int columnStartIdx = 0;

    int columnEndIdx = refColumns!.length - 1;

    final List<Key> selectingRowKeys =
        currentSelectingRows.map((e) => e!.key).toList();

    List<int> rowIdxList = [];

    for (var i = 0; i < refRows!.length; i += 1) {
      final currentRowKey = refRows![i]!.key;

      if (selectingRowKeys.contains(currentRowKey)) {
        selectingRowKeys.removeWhere((key) => key == currentRowKey);
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

    for (var i = 0; i < rowIdxList.length; i += 1) {
      final rowIdx = rowIdxList[i];

      int textColumnIdx = 0;

      if (rowIdx > refRows!.length - 1) {
        break;
      }

      if (textRowIdx > textList!.length - 1) {
        textRowIdx = 0;
      }

      for (var columnIdx = columnStartIdx!;
          columnIdx <= columnEndIdx!;
          columnIdx += 1) {
        if (columnIdx > columnIndexes.length - 1) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        final currentColumn = refColumns![columnIndexes[columnIdx]];

        final currentRow = refRows![rowIdx]!.cells[currentColumn.field]!;

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

        refRows![rowIdx]!.setState(PlutoRowState.updated);

        currentRow.value =
            newValue = castValueByColumnType(newValue, currentColumn);

        if (onChanged != null) {
          onChanged!(PlutoGridOnChangedEvent(
            columnIdx: columnIndexes[columnIdx],
            column: currentColumn,
            rowIdx: rowIdx,
            row: refRows![rowIdx],
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
