import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget implements HasPlutoStateManager {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  PlutoBaseRow({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    Key? key,
  }) : super(key: key) {
    row.bindWidget(this);
  }

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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: columns.length,
            itemBuilder: (_, i) {
              final column = columns[i];

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
            },
          ),
        );
      },
    );
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;
  final Widget child;

  _RowContainerWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.child,
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

      hasFocus = update<bool?>(
        hasFocus,
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
      final bool checkCurrentRow = hasFocus! &&
          !widget.stateManager.selectingMode.isRow &&
          isCurrentRow! &&
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
