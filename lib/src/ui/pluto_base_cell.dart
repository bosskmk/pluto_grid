import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class PlutoBaseCell extends StatelessWidget
    implements PlutoVisibilityLayoutChild {
  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoGridStateManager stateManager;

  const PlutoBaseCell({
    Key? key,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.stateManager,
  }) : super(key: key);

  @override
  bool visible() {
    return stateManager.visibilityBuildController.visibleColumn(column);
  }

  void _addGestureEvent(PlutoGridGestureType gestureType, Offset offset) {
    stateManager.eventManager!.addEvent(
      PlutoGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: cell,
        column: column,
        rowIdx: rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressStart,
      details.globalPosition,
    );
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
        PlutoGridGestureType.onLongPressMoveUpdate, details.globalPosition);
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
        PlutoGridGestureType.onLongPressEnd, details.globalPosition);
  }

  void _handleOnDoubleTap() {
    _addGestureEvent(PlutoGridGestureType.onDoubleTap, Offset.zero);
  }

  void _handleOnSecondaryTap(TapDownDetails details) {
    _addGestureEvent(
        PlutoGridGestureType.onSecondaryTap, details.globalPosition);
  }

  void Function()? _onDoubleTapOrNull() {
    return stateManager.onRowDoubleTap == null ? null : _handleOnDoubleTap;
  }

  void Function(TapDownDetails details)? _onSecondaryTapOrNull() {
    return stateManager.onRowSecondaryTap == null
        ? null
        : _handleOnSecondaryTap;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Essential gestures.
      onTapUp: _handleOnTapUp,
      onLongPressStart: _handleOnLongPressStart,
      onLongPressMoveUpdate: _handleOnLongPressMoveUpdate,
      onLongPressEnd: _handleOnLongPressEnd,
      // Optional gestures.
      onDoubleTap: _onDoubleTapOrNull(),
      onSecondaryTapDown: _onSecondaryTapOrNull(),
      child: _CellContainer(
        cell: cell,
        rowIdx: rowIdx,
        row: row,
        column: column,
        cellPadding: column.cellPadding ??
            stateManager.configuration!.defaultCellPadding,
        child: _BuildCell(
          stateManager: stateManager,
          rowIdx: rowIdx,
          column: column,
          row: row,
          cell: cell,
        ),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final PlutoCell cell;
  final PlutoRow row;
  final int rowIdx;
  final PlutoColumn column;
  final EdgeInsets cellPadding;
  final Widget child;

  const _CellContainer({
    required this.cell,
    required this.row,
    required this.rowIdx,
    required this.column,
    required this.cellPadding,
    required this.child,
  });

  Color? _currentCellColor({
    required bool readOnly,
    required bool hasFocus,
    required bool isEditing,
    required Color activatedColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required PlutoGridSelectingMode selectingMode,
  }) {
    if (!hasFocus) {
      return gridBackgroundColor;
    }

    if (!isEditing) {
      return selectingMode.isRow ? activatedColor : null;
    }

    return readOnly == true ? cellColorInReadOnlyState : cellColorInEditState;
  }

  BoxDecoration _boxDecoration({
    required bool hasFocus,
    required bool readOnly,
    required bool isEditing,
    required bool isCurrentCell,
    required bool isSelectedCell,
    required bool enableColumnBorder,
    required Color borderColor,
    required Color activatedBorderColor,
    required Color activatedColor,
    required Color inactivatedBorderColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required PlutoGridSelectingMode selectingMode,
  }) {
    if (isCurrentCell) {
      return BoxDecoration(
        color: _currentCellColor(
          hasFocus: hasFocus,
          isEditing: isEditing,
          readOnly: readOnly,
          gridBackgroundColor: gridBackgroundColor,
          activatedColor: activatedColor,
          cellColorInReadOnlyState: cellColorInReadOnlyState,
          cellColorInEditState: cellColorInEditState,
          selectingMode: selectingMode,
        ),
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: activatedColor,
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else {
      return enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: borderColor,
                  width: 1.0,
                ),
              ),
            )
          : const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<PlutoGridStateManager, BoxDecoration>(
      update: (_, stateManager, __) {
        final configuration = stateManager.configuration!;

        final isCurrentCell = stateManager.isCurrentCell(cell);

        return _boxDecoration(
          hasFocus: stateManager.hasFocus,
          readOnly: column.checkReadOnly(row, cell),
          isEditing: stateManager.isEditing,
          isCurrentCell: isCurrentCell,
          isSelectedCell: stateManager.isSelectedCell(
            cell,
            column,
            rowIdx,
          ),
          enableColumnBorder: configuration.enableColumnBorder,
          borderColor: configuration.borderColor,
          activatedBorderColor: configuration.activatedBorderColor,
          activatedColor: configuration.activatedColor,
          inactivatedBorderColor: configuration.inactivatedBorderColor,
          gridBackgroundColor: configuration.gridBackgroundColor,
          cellColorInEditState: configuration.cellColorInEditState,
          cellColorInReadOnlyState: configuration.cellColorInReadOnlyState,
          selectingMode: stateManager.selectingMode,
        );
      },
      child: Consumer<BoxDecoration>(
        builder: (_, decoration, child) {
          return Container(
            decoration: decoration,
            padding: cellPadding,
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

class _BuildCell extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final PlutoColumn column;
  final PlutoCell cell;

  const _BuildCell({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool showTypedCell = context.select<PlutoGridStateManager, bool>(
      (value) => value.isEditing && value.isCurrentCell(cell),
    );

    if (showTypedCell && column.enableEditingMode == true) {
      if (column.type.isSelect) {
        return PlutoSelectCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
          row: row,
        );
      } else if (column.type.isNumber) {
        return PlutoNumberCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
          row: row,
        );
      } else if (column.type.isDate) {
        return PlutoDateCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
          row: row,
        );
      } else if (column.type.isTime) {
        return PlutoTimeCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
          row: row,
        );
      } else if (column.type.isText) {
        return PlutoTextCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
          row: row,
        );
      }
    }

    return PlutoDefaultCell(
      cell: cell,
      column: column,
      rowIdx: rowIdx,
      row: row,
    );
  }
}

enum CellEditingStatus {
  init,
  changed,
  updated,
}

extension CellEditingStatusExtension on CellEditingStatus? {
  bool get isNotChanged {
    return CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return CellEditingStatus.updated == this;
  }
}
