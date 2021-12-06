import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseCell extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoCell? cell;
  final double? width;
  final double? height;
  final PlutoColumn? column;
  final int? rowIdx;

  PlutoBaseCell({
    Key? key,
    required this.stateManager,
    this.cell,
    this.width,
    this.height,
    this.column,
    this.rowIdx,
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
      cellValue = update<dynamic>(cellValue, widget.cell!.value);

      isCurrentCell = update<bool?>(
        isCurrentCell,
        widget.stateManager.isCurrentCell(widget.cell),
      );

      isEditing = update<bool?>(isEditing, widget.stateManager.isEditing);

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
    _addGestureEvent(
        PlutoGridGestureType.onLongPressStart, details.globalPosition);
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _addGestureEvent(
        PlutoGridGestureType.onLongPressMoveUpdate, details.globalPosition);
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
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
        readOnly: widget.column!.readOnly,
        width: widget.width,
        height: widget.height,
        hasFocus: widget.stateManager.hasFocus,
        isCurrentCell: isCurrentCell,
        isEditing: isEditing,
        selectingMode: selectingMode,
        isSelectedCell: isSelectedCell,
        configuration: widget.stateManager.configuration,
        cellPadding: widget.column!.cellPadding,
        child: _BuildCell(
          stateManager: widget.stateManager,
          rowIdx: widget.rowIdx,
          column: widget.column,
          cell: widget.cell,
          isCurrentCell: isCurrentCell,
          isEditing: isEditing,
        ),
      ),
    );
  }
}

class _CellContainer extends StatelessWidget {
  final bool? readOnly;
  final Widget? child;
  final double? width;
  final double? height;
  final bool? hasFocus;
  final bool? isCurrentCell;
  final bool? isEditing;
  final PlutoGridSelectingMode? selectingMode;
  final bool? isSelectedCell;
  final PlutoGridConfiguration? configuration;
  final double? cellPadding;

  _CellContainer({
    this.readOnly,
    this.child,
    this.width,
    this.height,
    this.hasFocus,
    this.isCurrentCell,
    this.isEditing,
    this.selectingMode,
    this.isSelectedCell,
    this.configuration,
    this.cellPadding,
  });

  Color? _currentCellColor() {
    if (!hasFocus!) {
      return null;
    }

    if (!isEditing!) {
      return selectingMode!.isRow ? configuration!.activatedColor : null;
    }

    return readOnly == true
        ? configuration!.cellColorInReadOnlyState
        : configuration!.cellColorInEditState;
  }

  BoxDecoration _boxDecoration() {
    if (isCurrentCell!) {
      return BoxDecoration(
        color: _currentCellColor(),
        border: Border.all(
          color: configuration!.activatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell!) {
      return BoxDecoration(
        color: configuration!.activatedColor,
        border: Border.all(
          color: configuration!.activatedBorderColor,
          width: 1,
        ),
      );
    } else {
      return configuration!.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: configuration!.borderColor,
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
          horizontal: cellPadding ?? configuration!.defaultCellPadding,
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
  final PlutoGridStateManager? stateManager;
  final int? rowIdx;
  final PlutoColumn? column;
  final PlutoCell? cell;
  final bool? isCurrentCell;
  final bool? isEditing;

  const _BuildCell({
    Key? key,
    this.stateManager,
    this.rowIdx,
    this.column,
    this.cell,
    this.isCurrentCell,
    this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isCurrentCell! && isEditing! && column!.enableEditingMode == true) {
      if (column!.type.isSelect) {
        return PlutoSelectCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
        );
      } else if (column!.type.isNumber) {
        return PlutoNumberCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
        );
      } else if (column!.type.isDate) {
        return PlutoDateCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
        );
      } else if (column!.type.isTime) {
        return PlutoTimeCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
        );
      } else if (column!.type.isText) {
        return PlutoTextCell(
          stateManager: stateManager,
          cell: cell,
          column: column,
        );
      }
    }

    return PlutoDefaultCell(
      stateManager: stateManager!,
      cell: cell,
      column: column,
      rowIdx: rowIdx,
    );
  }
}

enum CellEditingStatus {
  init,
  changed,
  updated,
}

extension CellEditingStatusExtension on CellEditingStatus? {
  bool get isChanged {
    return CellEditingStatus.changed == this;
  }
}
