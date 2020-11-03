part of '../../../pluto_grid.dart';

class DefaultCellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;

  DefaultCellWidget({
    this.stateManager,
    this.cell,
    this.column,
    this.rowIdx,
  });

  @override
  _DefaultCellWidgetState createState() => _DefaultCellWidgetState();
}

class _DefaultCellWidgetState extends State<DefaultCellWidget> {
  PlutoRow get thisRow => widget.stateManager._rows[widget.rowIdx];

  bool get isCurrentRowSelected {
    if (!widget.stateManager.selectingMode.isRow) {
      return false;
    }

    if (widget.stateManager.currentSelectingRows.length < 1) {
      return false;
    }

    final PlutoRow row = thisRow;

    final PlutoRow selectedRow =
        widget.stateManager.currentSelectingRows.firstWhere(
      (element) => element.key == row.key,
      orElse: () => null,
    );

    return selectedRow != null;
  }

  Icon getDragIcon() {
    return Icon(
      Icons.drag_indicator,
      size: 18,
      color: widget.stateManager.configuration.iconColor,
    );
  }

  Widget getTextWidget() {
    return Text(
      widget.column.formattedValueForDisplay(widget.cell.value),
      style: widget.stateManager.configuration.cellTextStyle.copyWith(
        decoration: TextDecoration.none,
        fontWeight: FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: widget.column.textAlign.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.column.enableRowDrag)
          // todo : implement scrolling by onDragUpdate
          // https://github.com/flutter/flutter/pull/68185
          Draggable(
            onDragEnd: (dragDetails) {
              List<PlutoRow> rows = isCurrentRowSelected
                  ? widget.stateManager.currentSelectingRows
                  : [thisRow];

              widget.stateManager.moveRows(rows, dragDetails.offset.dy);
            },
            feedback: ShadowContainer(
              width: widget.column.width,
              height: PlutoDefaultSettings.rowHeight,
              backgroundColor:
                  widget.stateManager.configuration.gridBackgroundColor,
              borderColor:
                  widget.stateManager.configuration.activatedBorderColor,
              child: Row(
                children: [
                  getDragIcon(),
                  Expanded(
                    child: getTextWidget(),
                  ),
                ],
              ),
            ),
            child: getDragIcon(),
          ),
        Expanded(
          child: getTextWidget(),
        ),
      ],
    );
  }
}
