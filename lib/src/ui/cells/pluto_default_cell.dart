import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoDefaultCell extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;

  PlutoDefaultCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
  });

  @override
  _PlutoDefaultCellState createState() => _PlutoDefaultCellState();
}

abstract class _PlutoDefaultCellStateWithChange
    extends PlutoStateWithChange<PlutoDefaultCell> {
  bool? canRowDrag;

  @override
  void onChange() {
    resetState((update) {
      canRowDrag = update<bool?>(
        canRowDrag,
        widget.stateManager.canRowDrag,
      );
    });
  }
}

class _PlutoDefaultCellState extends _PlutoDefaultCellStateWithChange {
  @override
  Widget build(BuildContext context) {
    final cellWidget = _BuildDefaultCellWidget(
      stateManager: widget.stateManager,
      rowIdx: widget.rowIdx,
      row: widget.row,
      column: widget.column,
      cell: widget.cell,
    );

    return Row(
      children: [
        if (widget.column.enableRowDrag && canRowDrag!)
          _RowDragIconWidget(
            column: widget.column,
            row: widget.row,
            rowIdx: widget.rowIdx,
            stateManager: widget.stateManager,
            feedbackWidget: cellWidget,
            dragIcon: Icon(
              Icons.drag_indicator,
              size: widget.stateManager.configuration!.iconSize,
              color: widget.stateManager.configuration!.iconColor,
            ),
          ),
        if (widget.column.enableRowChecked)
          _CheckboxSelectionWidget(
            column: widget.column,
            row: widget.row,
            stateManager: widget.stateManager,
          ),
        Expanded(
          child: cellWidget,
        ),
      ],
    );
  }
}

typedef DragUpdatedCallback = Function(Offset offset);

class _RowDragIconWidget extends StatefulWidget {
  final PlutoColumn column;
  final PlutoRow row;
  final int rowIdx;
  final PlutoGridStateManager stateManager;
  final Widget dragIcon;
  final Widget feedbackWidget;

  const _RowDragIconWidget({
    required this.column,
    required this.row,
    required this.rowIdx,
    required this.stateManager,
    required this.dragIcon,
    required this.feedbackWidget,
    Key? key,
  }) : super(key: key);

  @override
  __RowDragIconWidgetState createState() => __RowDragIconWidgetState();
}

class __RowDragIconWidgetState extends State<_RowDragIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        final List<PlutoRow?> draggingRows =
            widget.stateManager.currentSelectingRows.isNotEmpty
                ? widget.stateManager.currentSelectingRows
                : [widget.row];

        widget.stateManager.setIsDraggingRow(true, notify: false);

        widget.stateManager.setDragRows(draggingRows);
        print(draggingRows[0]?.cells);
      },
      onPointerMove: (PointerMoveEvent event) {
        widget.stateManager.eventManager!.addEvent(PlutoGridScrollUpdateEvent(
          offset: event.position,
        ));

        int? targetRowIdx = widget.stateManager.getRowIdxByOffset(
          event.position.dy,
        );

        widget.stateManager.setDragTargetRowIdx(targetRowIdx);
      },
      onPointerUp: (PointerUpEvent event) {
        widget.stateManager.setIsDraggingRow(false);
      },
      child: Draggable<List<PlutoRow?>>(
        data: [widget.row],
        feedback: Material(
          child: PlutoShadowContainer(
            width: widget.column.width,
            height: widget.stateManager.rowHeight,
            backgroundColor:
                widget.stateManager.configuration!.gridBackgroundColor,
            borderColor:
                widget.stateManager.configuration!.activatedBorderColor,
            child: Row(
              children: [
                widget.dragIcon,
                Expanded(
                  child: widget.feedbackWidget,
                ),
              ],
            ),
          ),
        ),
        child: widget.dragIcon,
      ),
    );
  }
}

class _CheckboxSelectionWidget extends PlutoStatefulWidget {
  final PlutoColumn? column;
  final PlutoRow? row;
  final PlutoGridStateManager stateManager;

  _CheckboxSelectionWidget({
    this.column,
    this.row,
    required this.stateManager,
  });

  @override
  __CheckboxSelectionWidgetState createState() =>
      __CheckboxSelectionWidgetState();
}

abstract class __CheckboxSelectionWidgetStateWithChange
    extends PlutoStateWithChange<_CheckboxSelectionWidget> {
  bool? checked;

  @override
  void onChange() {
    resetState((update) {
      checked = update<bool?>(checked, widget.row!.checked);
    });
  }
}

class __CheckboxSelectionWidgetState
    extends __CheckboxSelectionWidgetStateWithChange {
  void _handleOnChanged(bool? changed) {
    if (changed == checked) {
      return;
    }

    widget.stateManager.setRowChecked(widget.row, changed);

    if (widget.stateManager.onRowChecked != null) {
      widget.stateManager.onRowChecked!(
        PlutoGridOnRowCheckedOneEvent(row: widget.row, isChecked: changed),
      );
    }

    setState(() {
      checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScaledCheckbox(
      value: checked,
      handleOnChanged: _handleOnChanged,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration!.iconColor,
      activeColor: widget.stateManager.configuration!.activatedBorderColor,
      checkColor: widget.stateManager.configuration!.activatedColor,
    );
  }
}

class _BuildDefaultCellWidget extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final int? rowIdx;
  final PlutoRow? row;
  final PlutoColumn? column;
  final PlutoCell? cell;

  const _BuildDefaultCellWidget({
    Key? key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.column,
    this.cell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return column!.hasRenderer
        ? column!.renderer!(PlutoColumnRendererContext(
            column: column,
            rowIdx: rowIdx,
            row: row,
            cell: cell,
            stateManager: stateManager,
          ))
        : Text(
            column!.formattedValueForDisplay(cell!.value),
            style: stateManager!.configuration!.cellTextStyle.copyWith(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: column!.textAlign.value,
          );
  }
}
