import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// [PlutoGrid.onLoaded] Argument received by registering callback.
class PlutoGridOnLoadedEvent {
  final PlutoGridStateManager stateManager;

  const PlutoGridOnLoadedEvent({
    required this.stateManager,
  });
}

/// Event called when the value of [PlutoCell] is changed.
///
/// Notice.
/// [columnIdx], [rowIdx] are the values in the current screen state.
/// Values in their current state, not actual data values
/// with filtering, sorting, or pagination applied.
/// This value is from
/// [PlutoGridStateManager.columns] and [PlutoGridStateManager.rows].
///
/// All data is in
/// [PlutoGridStateManager.refColumns.originalList]
/// [PlutoGridStateManager.refRows.originalList]
class PlutoGridOnChangedEvent {
  final int columnIdx;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;
  final dynamic value;
  final dynamic oldValue;

  const PlutoGridOnChangedEvent({
    required this.columnIdx,
    required this.column,
    required this.rowIdx,
    required this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

/// This is the argument value of the [PlutoGrid.onSelected] callback
/// that is called when the [PlutoGrid.mode] value is in select mode.
///
/// If [row], [rowIdx], [cell] is [PlutoGridMode.select] or [PlutoGridMode.selectWithOneTap],
/// Information of the row selected with the tab or enter key.
/// If the Escape key is pressed, these values are null.
///
/// [selectedRows] is valid only in case of [PlutoGridMode.multiSelect].
/// If rows are selected by tab or keyboard, the selected rows are included.
/// If the Escape key is pressed, this value is null.
class PlutoGridOnSelectedEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell? cell;
  final List<PlutoRow>? selectedRows;

  const PlutoGridOnSelectedEvent({
    this.row,
    this.rowIdx,
    this.cell,
    this.selectedRows,
  });

  @override
  String toString() {
    return '[PlutoGridOnSelectedEvent] rowIdx: $rowIdx, selectedRows: ${selectedRows?.length}';
  }
}

/// Argument of [PlutoGrid.onSorted] callback for receiving column sort change event.
class PlutoGridOnSortedEvent {
  final PlutoColumn column;

  final PlutoColumnSort oldSort;

  const PlutoGridOnSortedEvent({
    required this.column,
    required this.oldSort,
  });

  @override
  String toString() {
    return '[PlutoGridOnSortedEvent] ${column.title} (changed: ${column.sort}, old: $oldSort)';
  }
}

/// Argument of [PlutoGrid.onRowChecked] callback to receive row checkbox event.
///
/// [runtimeType] is [PlutoGridOnRowCheckedAllEvent] if [isAll] is true.
/// When [isAll] is true, it means the entire check button event of the column.
///
/// [runtimeType] is [PlutoGridOnRowCheckedOneEvent] if [isRow] is true.
/// If [isRow] is true, it means the check button event of a specific row.
abstract class PlutoGridOnRowCheckedEvent {
  bool get isAll => runtimeType == PlutoGridOnRowCheckedAllEvent;

  bool get isRow => runtimeType == PlutoGridOnRowCheckedOneEvent;

  final PlutoRow? row;
  final int? rowIdx;
  final bool? isChecked;

  const PlutoGridOnRowCheckedEvent({
    this.row,
    this.rowIdx,
    this.isChecked,
  });

  @override
  String toString() {
    String checkMessage = isAll ? 'All rows ' : 'RowIdx $rowIdx ';
    checkMessage += isChecked == true ? 'checked' : 'unchecked';
    return '[PlutoGridOnRowCheckedEvent] $checkMessage';
  }
}

/// Argument of [PlutoGrid.onRowChecked] callback when the checkbox of the row is tapped.
class PlutoGridOnRowCheckedOneEvent extends PlutoGridOnRowCheckedEvent {
  const PlutoGridOnRowCheckedOneEvent({
    required PlutoRow super.row,
    required int super.rowIdx,
    required super.isChecked,
  });
}

/// Argument of [PlutoGrid.onRowChecked] callback when all checkboxes of the column are tapped.
class PlutoGridOnRowCheckedAllEvent extends PlutoGridOnRowCheckedEvent {
  const PlutoGridOnRowCheckedAllEvent({
    super.isChecked,
  }) : super(row: null, rowIdx: null);
}

/// The argument of the [PlutoGrid.onRowDoubleTap] callback
/// to receive the event of double-tapping the row.
class PlutoGridOnRowDoubleTapEvent {
  final PlutoRow row;
  final int rowIdx;
  final PlutoCell cell;

  const PlutoGridOnRowDoubleTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
  });
}

/// Argument of the [PlutoGrid.onRowSecondaryTap] callback
/// to receive the event of tapping the row with the right mouse button.
class PlutoGridOnRowSecondaryTapEvent {
  final PlutoRow row;
  final int rowIdx;
  final PlutoCell cell;
  final Offset offset;

  const PlutoGridOnRowSecondaryTapEvent({
    required this.row,
    required this.rowIdx,
    required this.cell,
    required this.offset,
  });
}

/// Argument of [PlutoGrid.onRowEnter] callback
/// to receive the event of entering the row with the mouse.
class PlutoGridOnRowEnterEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell cell;

  const PlutoGridOnRowEnterEvent({
    this.row,
    this.rowIdx,
    required this.cell,
  });
}

/// Argument of [PlutoGrid.onRowExit] callback
/// to receive the event of exiting the row with the mouse.
class PlutoGridOnRowExitEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell cell;

  const PlutoGridOnRowExitEvent({
    this.row,
    this.rowIdx,
    required this.cell,
  });
}

/// Argument of [PlutoGrid.onRowsMoved] callback
/// to receive the event of moving the row by dragging it.
class PlutoGridOnRowsMovedEvent {
  final int idx;
  final List<PlutoRow> rows;

  const PlutoGridOnRowsMovedEvent({
    required this.idx,
    required this.rows,
  });
}

/// Argument of [PlutoGrid.onColumnsMoved] callback
/// to move columns by dragging or receive left or right fixed events.
///
/// [idx] means the actual index of
/// [PlutoGridStateManager.columns] or [PlutoGridStateManager.refColumns].
///
/// [visualIdx] means the order displayed on the screen, not the actual index.
/// For example, if there are 5 columns of [0, 1, 2, 3, 4]
/// If 1 column is frozen to the right, [visualIndex] becomes 4.
/// But the actual index is preserved.
class PlutoGridOnColumnsMovedEvent {
  final int idx;
  final int visualIdx;
  final List<PlutoColumn> columns;

  const PlutoGridOnColumnsMovedEvent({
    required this.idx,
    required this.visualIdx,
    required this.columns,
  });

  @override
  String toString() {
    String text =
        '[PlutoGridOnColumnsMovedEvent] idx: $idx, visualIdx: $visualIdx\n';

    text += columns.map((e) => e.title).join(',');

    return text;
  }
}
