import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;

  PlutoBaseRow({
    Key? key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onWillAccept: (List<PlutoRow?>? draggingRows) {
        if (draggingRows == null || draggingRows.isEmpty) {
          return false;
        }

        final selectedRows = stateManager!.currentSelectingRows.isNotEmpty
            ? stateManager!.currentSelectingRows
            : draggingRows;

        return selectedRows.firstWhere(
              (element) => element?.key == row?.key,
              orElse: () => null,
            ) ==
            null;
      },
      onMove: (DragTargetDetails details) async {
        final draggingRows = stateManager!.currentSelectingRows.isNotEmpty
            ? stateManager!.currentSelectingRows
            : details.data as List<PlutoRow?>;

        stateManager!.eventManager!.addEvent(
          PlutoGridDragRowsEvent(
            rows: draggingRows,
            targetIdx: rowIdx!,
            offset: details.offset,
          ),
        );
      },
      builder: (dragContext, candidate, rejected) {
        return _RowContainerWidget(
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
  final PlutoGridStateManager stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final List<PlutoColumn>? columns;
  final Widget? child;

  _RowContainerWidget({
    required this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
    this.child,
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

      final alreadyTarget = widget.stateManager.dragRows?.firstWhere(
              (element) => element?.key == widget.row?.key,
              orElse: () => null) !=
          null;

      isDragTarget = update<bool?>(
        isDragTarget,
        !alreadyTarget && widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
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
  Color getDefaultRowColor() {
    if (widget.stateManager.rowColorCallback == null) {
      return Colors.transparent;
    }

    return widget.stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: widget.rowIdx!,
        row: widget.row!,
        stateManager: widget.stateManager,
      ),
    );
  }

  Color rowColor() {
    final Color defaultColor = getDefaultRowColor();

    if (isDragTarget!)
      return widget.stateManager.configuration!.cellColorInReadOnlyState;

    final bool checkCurrentRow =
        isCurrentRow! && (!isSelecting! && !hasCurrentSelectingPosition!);

    final bool checkSelectedRow =
        widget.stateManager.isSelectedRow(widget.row!.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return defaultColor;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow
          ? widget.stateManager.configuration!.activatedColor
          : defaultColor;
    }

    if (!hasFocus!) {
      return defaultColor;
    }

    return checkCurrentRow
        ? widget.stateManager.configuration!.activatedColor
        : defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Color _rowColor = rowColor();

    return Container(
      decoration: BoxDecoration(
        color: isCheckedRow!
            ? Color.alphaBlend(const Color(0x11757575), _rowColor)
            : _rowColor,
        border: Border(
          top: isTopDragTarget!
              ? BorderSide(
                  width: PlutoGridSettings.rowBorderWidth,
                  color:
                      widget.stateManager.configuration!.activatedBorderColor,
                )
              : BorderSide.none,
          bottom: BorderSide(
            width: PlutoGridSettings.rowBorderWidth,
            color: isBottomDragTarget!
                ? widget.stateManager.configuration!.activatedBorderColor
                : widget.stateManager.configuration!.borderColor,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
