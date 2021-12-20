import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseCell extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final double width;

  final double height;

  const PlutoBaseCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    this.width = PlutoGridSettings.columnWidth,
    this.height = PlutoGridSettings.rowHeight,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoBaseCellState createState() => _PlutoBaseCellState();
}

abstract class _PlutoBaseCellStateWithChangeKeepAlive
    extends PlutoStateWithChangeKeepAlive<PlutoBaseCell> {
  dynamic cellValue;

  bool? isCurrentCell;

  bool? isEditing;

  PlutoGridSelectingMode? selectingMode;

  bool? isSelectedCell;

  bool? hasFocus;

  @override
  void onChange() {
    resetState((update) {
      cellValue = update<dynamic>(cellValue, widget.cell.value);

      isCurrentCell = update<bool?>(
        isCurrentCell,
        widget.stateManager.isCurrentCell(widget.cell),
      );

      isEditing = update<bool?>(
        isEditing,
        widget.stateManager.isEditing,
        ignoreChange: isCurrentCell != true,
      );

      selectingMode = update<PlutoGridSelectingMode?>(
        selectingMode,
        widget.stateManager.selectingMode,
      );

      isSelectedCell = update<bool?>(
        isSelectedCell,
        widget.stateManager.isSelectedCell(
          widget.cell,
          widget.column,
          widget.rowIdx,
        ),
      );

      hasFocus = update<bool?>(
        hasFocus,
        isCurrentCell! && widget.stateManager.hasFocus,
      );

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(isCurrentCell!);
      }
    });
  }
}

class _PlutoBaseCellState extends _PlutoBaseCellStateWithChangeKeepAlive {
  void _addGestureEvent(PlutoGridGestureType gestureType, Offset offset) {
    widget.stateManager.eventManager!.addEvent(
      PlutoGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: widget.cell,
        column: widget.column,
        rowIdx: widget.rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    if (widget.stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressStart,
      details.globalPosition,
    );
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (widget.stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
        PlutoGridGestureType.onLongPressMoveUpdate, details.globalPosition);
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    if (widget.stateManager.selectingMode.isNone) {
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
    return widget.stateManager.onRowDoubleTap == null
        ? null
        : _handleOnDoubleTap;
  }

  void Function(TapDownDetails details)? _onSecondaryTapOrNull() {
    return widget.stateManager.onRowSecondaryTap == null
        ? null
        : _handleOnSecondaryTap;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
        readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
        width: widget.width,
        height: widget.height,
        hasFocus: widget.stateManager.hasFocus,
        isCurrentCell: isCurrentCell!,
        isEditing: isEditing!,
        selectingMode: selectingMode!,
        isSelectedCell: isSelectedCell!,
        configuration: widget.stateManager.configuration!,
        cellPadding: widget.column.cellPadding ??
            widget.stateManager.configuration!.defaultCellPadding,
        child: _BuildCell(
          stateManager: widget.stateManager,
          rowIdx: widget.rowIdx,
          column: widget.column,
          row: widget.row,
          cell: widget.cell,
          isCurrentCell: isCurrentCell!,
          isEditing: isEditing!,
        ),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final bool readOnly;
  final Widget child;
  final double width;
  final double height;
  final bool hasFocus;
  final bool isCurrentCell;
  final bool isEditing;
  final PlutoGridSelectingMode selectingMode;
  final bool isSelectedCell;
  final PlutoGridConfiguration configuration;
  final double cellPadding;

  const _CellContainer({
    required this.readOnly,
    required this.child,
    required this.width,
    required this.height,
    required this.hasFocus,
    required this.isCurrentCell,
    required this.isEditing,
    required this.selectingMode,
    required this.isSelectedCell,
    required this.configuration,
    required this.cellPadding,
  });

  Color? _currentCellColor() {
    if (!hasFocus) {
      return configuration.gridBackgroundColor;
    }

    if (!isEditing) {
      return selectingMode.isRow ? configuration.activatedColor : null;
    }

    return readOnly == true
        ? configuration.cellColorInReadOnlyState
        : configuration.cellColorInEditState;
  }

  BoxDecoration _boxDecoration() {
    if (isCurrentCell) {
      return BoxDecoration(
        color: _currentCellColor(),
        border: Border.all(
          color: hasFocus
              ? configuration.activatedBorderColor
              : configuration.inactivatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: configuration.activatedColor,
        border: Border.all(
          color: hasFocus
              ? configuration.activatedBorderColor
              : configuration.inactivatedBorderColor,
          width: 1,
        ),
      );
    } else {
      return configuration.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: configuration.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _boxDecoration(),
      child: Padding(
        // New - Customisable cellPadding
        padding: EdgeInsets.symmetric(
          horizontal: cellPadding,
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: height,
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(),
          child: child,
        ),
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
  final bool isCurrentCell;
  final bool isEditing;

  const _BuildCell({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
    required this.isCurrentCell,
    required this.isEditing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCurrentCell && isEditing && column.enableEditingMode == true) {
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
      stateManager: stateManager,
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
