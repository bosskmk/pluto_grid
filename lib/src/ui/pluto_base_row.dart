import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;
  final Color? backgroundColor;

  PlutoBaseRow({
    Key? key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _RowContainerWidget(
      backgroundColor: backgroundColor,
      stateManager: stateManager!,
      rowIdx: rowIdx,
      row: row,
      columns: columns,
      child: Row(
        children: columns!.map((column) {
          return PlutoBaseCell(
            key: row!.cells[column.field]!.key,
            stateManager: stateManager!,
            cell: row!.cells[column.field],
            width: column.width,
            height: stateManager!.rowHeight,
            column: column,
            rowIdx: rowIdx,
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;
  final Widget? child;
  final Color? backgroundColor;

  _RowContainerWidget({
    required this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
    this.child,
    this.backgroundColor,
  });

  @override
  __RowContainerWidgetState createState() => __RowContainerWidgetState();
}

abstract class __RowContainerWidgetStateWithChangeKeepAlive
    extends PlutoStateWithChangeKeepAlive<_RowContainerWidget> {
  bool? isCurrentRow;

  bool? isSelectedRow;

  bool? isSelecting;

  bool? isCheckedRow;

  bool? isDragTarget;

  bool? isTopDragTarget;

  bool? isBottomDragTarget;

  bool? hasCurrentSelectingPosition;

  bool? hasFocus;

  @override
  void onChange() {
    resetState((update) {
      isCurrentRow = update<bool?>(
        isCurrentRow,
        widget.stateManager.currentRowIdx == widget.rowIdx,
      );

      isSelectedRow = update<bool?>(
        isSelectedRow,
        widget.stateManager.isSelectedRow(widget.row!.key),
      );

      isSelecting = update<bool?>(isSelecting, widget.stateManager.isSelecting);

      isCheckedRow = update<bool?>(isCheckedRow, widget.row!.checked);

      isDragTarget = update<bool?>(
        isDragTarget,
        widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
      );

      isTopDragTarget = update<bool?>(
        isTopDragTarget,
        widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx),
      );

      isBottomDragTarget = update<bool?>(
        isBottomDragTarget,
        widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx),
      );

      hasCurrentSelectingPosition = update<bool?>(
        hasCurrentSelectingPosition,
        widget.stateManager.hasCurrentSelectingPosition,
      );

      hasFocus = update<bool?>(
        hasFocus,
        isCurrentRow! && widget.stateManager.hasFocus,
      );

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(widget.stateManager.isRowBeingDragged(widget.row!.key));
      }
    });
  }
}

class __RowContainerWidgetState
    extends __RowContainerWidgetStateWithChangeKeepAlive {
  Color rowColor() {
    if (isDragTarget!) return widget.stateManager.configuration!.checkedColor;

    final bool checkCurrentRow =
        isCurrentRow! && (!isSelecting! && !hasCurrentSelectingPosition!);

    final bool checkSelectedRow =
        widget.stateManager.isSelectedRow(widget.row!.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return widget.backgroundColor ?? Colors.transparent;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow
          ? widget.stateManager.configuration!.activatedColor
          : widget.backgroundColor ?? Colors.transparent;
    }

    if (!hasFocus!) {
      return widget.backgroundColor ?? Colors.transparent;
    }

    return checkCurrentRow
        ? widget.stateManager.configuration!.activatedColor
        : widget.backgroundColor ?? Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: BoxDecoration(
        color: isCheckedRow!
            ? Color.alphaBlend(const Color(0x11757575), rowColor())
            : rowColor(),
        border: Border(
          top: isDragTarget! && isTopDragTarget!
              ? BorderSide(
                  width: PlutoGridSettings.rowBorderWidth,
                  color:
                      widget.stateManager.configuration!.activatedBorderColor,
                )
              : BorderSide.none,
          bottom: BorderSide(
            width: PlutoGridSettings.rowBorderWidth,
            color: isDragTarget! && isBottomDragTarget!
                ? widget.stateManager.configuration!.activatedBorderColor
                : widget.stateManager.configuration!.borderColor,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
