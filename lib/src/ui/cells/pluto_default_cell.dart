import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoDefaultCell extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  const PlutoDefaultCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoDefaultCellState createState() => _PlutoDefaultCellState();
}

abstract class _PlutoDefaultCellStateWithChange
    extends PlutoStateWithChange<PlutoDefaultCell> {
  bool? _canRowDrag;

  @override
  void onChange() {
    resetState((update) {
      _canRowDrag = update<bool?>(
        _canRowDrag,
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
        if (widget.column.enableRowDrag && _canRowDrag!)
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
  List<PlutoRow> get _draggingRows {
    if (widget.stateManager.currentSelectingRows.isEmpty) {
      return [widget.row];
    }

    if (widget.stateManager.isSelectedRow(widget.row.key)) {
      return widget.stateManager.currentSelectingRows;
    }

    // In case there are selected rows,
    // if the dragging row is not included in it,
    // the selection of rows is invalidated.
    widget.stateManager.clearCurrentSelecting(notify: false);

    return [widget.row];
  }

  void _handleOnPointerDown(PointerDownEvent event) {
    widget.stateManager.setIsDraggingRow(true, notify: false);

    widget.stateManager.setDragRows(_draggingRows);
  }

  void _handleOnPointerMove(PointerMoveEvent event) {
    // Do not drag while rows are selected.
    if (widget.stateManager.isSelecting) {
      widget.stateManager.setIsDraggingRow(false);

      return;
    }

    widget.stateManager.eventManager.addEvent(PlutoGridScrollUpdateEvent(
      offset: event.position,
    ));

    int? targetRowIdx = widget.stateManager.getRowIdxByOffset(
      event.position.dy,
    );

    widget.stateManager.setDragTargetRowIdx(targetRowIdx);
  }

  void _handleOnPointerUp(PointerUpEvent event) {
    widget.stateManager.setIsDraggingRow(false);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleOnPointerDown,
      onPointerMove: _handleOnPointerMove,
      onPointerUp: _handleOnPointerUp,
      child: Draggable<PlutoRow>(
        data: widget.row,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: FractionalTranslation(
          translation: const Offset(-0.08, -0.5),
          child: Material(
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
        ),
        child: widget.dragIcon,
      ),
    );
  }
}

class _CheckboxSelectionWidget extends PlutoStatefulWidget {
  final PlutoColumn column;

  final PlutoRow row;

  @override
  final PlutoGridStateManager stateManager;

  const _CheckboxSelectionWidget({
    required this.column,
    required this.row,
    required this.stateManager,
  });

  @override
  __CheckboxSelectionWidgetState createState() =>
      __CheckboxSelectionWidgetState();
}

abstract class __CheckboxSelectionWidgetStateWithChange
    extends PlutoStateWithChange<_CheckboxSelectionWidget> {
  bool? _checked;

  @override
  void onChange() {
    resetState((update) {
      _checked = update<bool?>(_checked, widget.row.checked);
    });
  }
}

class __CheckboxSelectionWidgetState
    extends __CheckboxSelectionWidgetStateWithChange {
  void _handleOnChanged(bool? changed) {
    if (changed == _checked) {
      return;
    }

    widget.stateManager.setRowChecked(widget.row, changed == true);

    if (widget.stateManager.onRowChecked != null) {
      widget.stateManager.onRowChecked!(
        PlutoGridOnRowCheckedOneEvent(row: widget.row, isChecked: changed),
      );
    }

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration!.iconColor,
      activeColor: widget.stateManager.configuration!.activatedBorderColor,
      checkColor: widget.stateManager.configuration!.activatedColor,
    );
  }
}

class _BuildDefaultCellWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final PlutoColumn column;
  final PlutoCell cell;

  const _BuildDefaultCellWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return column.hasRenderer
        ? column.renderer!(PlutoColumnRendererContext(
            column: column,
            rowIdx: rowIdx,
            row: row,
            cell: cell,
            stateManager: stateManager,
          ))
        : Text(
            column.formattedValueForDisplay(cell.value),
            style: stateManager.configuration!.cellTextStyle.copyWith(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: column.textAlign.value,
          );
  }
}
