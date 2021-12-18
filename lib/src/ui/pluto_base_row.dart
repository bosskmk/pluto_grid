import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  const PlutoBaseRow({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onWillAccept: (List<PlutoRow?>? draggingRows) {
        if (draggingRows == null || draggingRows.isEmpty) {
          return false;
        }

        final selectedRows = stateManager.currentSelectingRows.isNotEmpty
            ? stateManager.currentSelectingRows
            : draggingRows;

        return selectedRows.firstWhere(
              (element) => element?.key == row.key,
              orElse: () => null,
            ) ==
            null;
      },
      onMove: (DragTargetDetails details) async {
        final draggingRows = stateManager.currentSelectingRows.isNotEmpty
            ? stateManager.currentSelectingRows
            : details.data as List<PlutoRow?>;

        stateManager.eventManager!.addEvent(
          PlutoGridDragRowsEvent(
            rows: draggingRows,
            targetIdx: rowIdx,
            offset: details.offset,
          ),
        );
      },
      builder: (dragContext, candidate, rejected) {
        return _RowContainerWidget(
          stateManager: stateManager,
          rowIdx: rowIdx,
          row: row,
          columns: columns,
          child: Row(
            children: columns.map((column) {
              return PlutoBaseCell(
                key: row.cells[column.field]!.key,
                stateManager: stateManager,
                cell: row.cells[column.field]!,
                width: column.width,
                height: stateManager.rowHeight,
                column: column,
                rowIdx: rowIdx,
                row: row,
              );
            }).toList(growable: false),
          ),
        );
      },
    );
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final List<PlutoColumn> columns;

  final Widget child;

  const _RowContainerWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.child,
    Key? key,
  }) : super(key: key);

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

  bool? isFocusedCurrentRow;

  Color? rowColor;

  @override
  void onChange() {
    resetState((update) {
      isCurrentRow = update<bool?>(
        isCurrentRow,
        widget.stateManager.currentRowIdx == widget.rowIdx,
      );

      isSelectedRow = update<bool?>(
        isSelectedRow,
        widget.stateManager.isSelectedRow(widget.row.key),
      );

      isSelecting = update<bool?>(isSelecting, widget.stateManager.isSelecting);

      isCheckedRow = update<bool?>(isCheckedRow, widget.row.checked);

      final alreadyTarget = widget.stateManager.dragRows?.firstWhere(
              (element) => element?.key == widget.row.key,
              orElse: () => null) !=
          null;

      final isDraggingRow = widget.stateManager.isDraggingRow;

      isDragTarget = update<bool?>(
        isDragTarget,
        !alreadyTarget && widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
        ignoreChange: !isDraggingRow,
      );

      isTopDragTarget = update<bool?>(
        isTopDragTarget,
        isDraggingRow &&
            widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx),
      );

      isBottomDragTarget = update<bool?>(
        isBottomDragTarget,
        isDraggingRow &&
            widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx),
      );

      hasCurrentSelectingPosition = update<bool?>(
        hasCurrentSelectingPosition,
        widget.stateManager.hasCurrentSelectingPosition,
      );

      isFocusedCurrentRow = update<bool?>(
        isFocusedCurrentRow,
        isCurrentRow! && widget.stateManager.hasFocus,
      );

      rowColor = update<Color?>(rowColor, getRowColor());

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(widget.stateManager.isRowBeingDragged(widget.row.key));
      }
    });
  }

  Color getDefaultRowColor() {
    if (widget.stateManager.rowColorCallback == null) {
      return widget.stateManager.configuration!.gridBackgroundColor;
    }

    return widget.stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: widget.rowIdx,
        row: widget.row,
        stateManager: widget.stateManager,
      ),
    );
  }

  Color getRowColor() {
    Color color = getDefaultRowColor();

    if (isDragTarget!) {
      color = widget.stateManager.configuration!.cellColorInReadOnlyState;
    } else {
      final bool checkCurrentRow = !widget.stateManager.selectingMode.isRow &&
          isFocusedCurrentRow! &&
          (!isSelecting! && !hasCurrentSelectingPosition!);

      final bool checkSelectedRow = widget.stateManager.selectingMode.isRow &&
          widget.stateManager.isSelectedRow(widget.row.key);

      if (checkCurrentRow || checkSelectedRow) {
        color = widget.stateManager.configuration!.activatedColor;
      }
    }

    return isCheckedRow!
        ? Color.alphaBlend(
            widget.stateManager.configuration!.checkedColor,
            color,
          )
        : color;
  }
}

class __RowContainerWidgetState
    extends __RowContainerWidgetStateWithChangeKeepAlive {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final decoration = BoxDecoration(
      color: rowColor,
      border: Border(
        top: isTopDragTarget!
            ? BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: widget.stateManager.configuration!.activatedBorderColor,
              )
            : BorderSide.none,
        bottom: BorderSide(
          width: PlutoGridSettings.rowBorderWidth,
          color: isBottomDragTarget!
              ? widget.stateManager.configuration!.activatedBorderColor
              : widget.stateManager.configuration!.borderColor,
        ),
      ),
    );

    return _AnimatedOrNormalContainer(
      enable: widget.stateManager.configuration!.enableRowColorAnimation,
      child: widget.child,
      decoration: decoration,
    );
  }
}

class _AnimatedOrNormalContainer extends StatelessWidget {
  final bool enable;

  final Widget child;

  final BoxDecoration decoration;

  const _AnimatedOrNormalContainer({
    required this.enable,
    required this.child,
    required this.decoration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enable
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: decoration,
            child: child,
          )
        : Container(
            decoration: decoration,
            child: child,
          );
  }
}
