part of '../../pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  PlutoBaseRow({
    Key key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _RowContainerWidget(
      stateManager: stateManager,
      rowIdx: rowIdx,
      row: row,
      columns: columns,
      child: Row(
        children: columns.map((column) {
          return PlutoBaseCell(
            key: row.cells[column.field]._key,
            stateManager: stateManager,
            cell: row.cells[column.field],
            width: column.width,
            height: stateManager.rowHeight,
            column: column,
            rowIdx: rowIdx,
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _RowContainerWidget extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;
  final Widget child;

  _RowContainerWidget({
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
    this.child,
  });

  @override
  __RowContainerWidgetState createState() => __RowContainerWidgetState();
}

class __RowContainerWidgetStateWithChangeKeepAlive
    extends _PlutoStateWithChangeKeepAlive<_RowContainerWidget> {
  bool isCurrentRow;

  bool isSelectedRow;

  bool isSelecting;

  bool isCheckedRow;

  bool isDragTarget;

  bool isTopDragTarget;

  bool isBottomDragTarget;

  bool hasCurrentSelectingPosition;

  bool keepFocus;

  @override
  void onChange() {
    resetState((update) {
      isCurrentRow = update<bool>(
        isCurrentRow,
        widget.stateManager.currentRowIdx == widget.rowIdx,
      );

      isSelectedRow = update<bool>(
        isSelectedRow,
        widget.stateManager.isSelectedRow(widget.row.key),
      );

      isSelecting = update<bool>(isSelecting, widget.stateManager.isSelecting);

      isCheckedRow = update<bool>(isCheckedRow, widget.row.checked);

      isDragTarget = update<bool>(
        isDragTarget,
        widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
      );

      isTopDragTarget = update<bool>(
        isTopDragTarget,
        widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx),
      );

      isBottomDragTarget = update<bool>(
        isBottomDragTarget,
        widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx),
      );

      hasCurrentSelectingPosition = update<bool>(
        hasCurrentSelectingPosition,
        widget.stateManager.hasCurrentSelectingPosition,
      );

      keepFocus = update<bool>(
        keepFocus,
        isCurrentRow && widget.stateManager.keepFocus,
      );

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(widget.stateManager.isRowBeingDragged(widget.row.key));
      }
    });
  }
}

class __RowContainerWidgetState
    extends __RowContainerWidgetStateWithChangeKeepAlive {
  Color rowColor() {
    if (isDragTarget) return widget.stateManager.configuration.checkedColor;

    final bool checkCurrentRow =
        isCurrentRow && (!isSelecting && !hasCurrentSelectingPosition);

    final bool checkSelectedRow =
        widget.stateManager.isSelectedRow(widget.row.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return Colors.transparent;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow
          ? widget.stateManager.configuration.activatedColor
          : Colors.transparent;
    }

    if (!widget.stateManager.hasFocus) {
      return Colors.transparent;
    }

    return checkCurrentRow
        ? widget.stateManager.configuration.activatedColor
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: BoxDecoration(
        color: isCheckedRow
            ? Color.alphaBlend(const Color(0x11757575), rowColor())
            : rowColor(),
        border: Border(
          top: isDragTarget && isTopDragTarget
              ? BorderSide(
                  width: PlutoGridSettings.rowBorderWidth,
                  color: widget.stateManager.configuration.activatedBorderColor,
                )
              : BorderSide.none,
          bottom: BorderSide(
            width: PlutoGridSettings.rowBorderWidth,
            color: isDragTarget && isBottomDragTarget
                ? widget.stateManager.configuration.activatedBorderColor
                : widget.stateManager.configuration.borderColor,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
