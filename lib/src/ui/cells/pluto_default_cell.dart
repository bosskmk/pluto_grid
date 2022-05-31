import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class PlutoDefaultCell extends StatelessWidget {
  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  const PlutoDefaultCell({
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateManager = context.read<PlutoGridStateManager>();

    final canRowDrag = column.enableRowDrag &&
        context.select<PlutoGridStateManager, bool>(
          (value) => value.canRowDrag,
        );

    return Row(
      children: [
        if (canRowDrag)
          _RowDragIconWidget(
            column: column,
            row: row,
            rowIdx: rowIdx,
            stateManager: stateManager,
            feedbackWidget: _BuildDefaultCellWidget(
              stateManager: stateManager,
              rowIdx: rowIdx,
              row: row,
              column: column,
              cell: cell,
            ),
            dragIcon: Icon(
              Icons.drag_indicator,
              size: stateManager.configuration!.iconSize,
              color: stateManager.configuration!.iconColor,
            ),
          ),
        if (column.enableRowChecked)
          _CheckboxSelectionWidget(
            column: column,
            row: row,
            stateManager: stateManager,
          ),
        Expanded(
          child: _BuildDefaultCellWidget(
            stateManager: stateManager,
            rowIdx: rowIdx,
            row: row,
            column: column,
            cell: cell,
          ),
        ),
      ],
    );
  }
}

typedef DragUpdatedCallback = Function(Offset offset);

class _RowDragIconWidget extends StatelessWidget {
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

  List<PlutoRow> get _draggingRows {
    if (stateManager.currentSelectingRows.isEmpty) {
      return [row];
    }

    if (stateManager.isSelectedRow(row.key)) {
      return stateManager.currentSelectingRows;
    }

    // In case there are selected rows,
    // if the dragging row is not included in it,
    // the selection of rows is invalidated.
    stateManager.clearCurrentSelecting(notify: false);

    return [row];
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handleOnPointerDown,
      onPointerMove: _handleOnPointerMove,
      onPointerUp: _handleOnPointerUp,
      child: Draggable<PlutoRow>(
        data: row,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: FractionalTranslation(
          translation: const Offset(-0.08, -0.5),
          child: Material(
            child: PlutoShadowContainer(
              width: column.width,
              height: stateManager.rowHeight,
              backgroundColor: stateManager.configuration!.gridBackgroundColor,
              borderColor: stateManager.configuration!.activatedBorderColor,
              child: Row(
                children: [
                  dragIcon,
                  Expanded(
                    child: feedbackWidget,
                  ),
                ],
              ),
            ),
          ),
        ),
        child: dragIcon,
      ),
    );
  }

  void _handleOnPointerDown(PointerDownEvent event) {
    stateManager.setIsDraggingRow(true, notify: false);

    stateManager.setDragRows(_draggingRows);
  }

  void _handleOnPointerMove(PointerMoveEvent event) {
    // Do not drag while rows are selected.
    if (stateManager.isSelecting) {
      stateManager.setIsDraggingRow(false);

      return;
    }

    stateManager.eventManager!.addEvent(PlutoGridScrollUpdateEvent(
      offset: event.position,
    ));

    int? targetRowIdx = stateManager.getRowIdxByOffset(
      event.position.dy,
    );

    stateManager.setDragTargetRowIdx(targetRowIdx);
  }

  void _handleOnPointerUp(PointerUpEvent event) {
    stateManager.setIsDraggingRow(false);
  }
}

class _CheckboxSelectionWidget extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final PlutoRow row;

  const _CheckboxSelectionWidget({
    required this.stateManager,
    required this.column,
    required this.row,
  });

  @override
  __CheckboxSelectionWidgetState createState() =>
      __CheckboxSelectionWidgetState();
}

class __CheckboxSelectionWidgetState extends State<_CheckboxSelectionWidget> {
  bool? _checked;

  @override
  void initState() {
    super.initState();

    _checked = widget.row.checked;
  }

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
    _checked = context.select<PlutoGridStateManager, bool>(
        (value) => widget.row.checked == true);

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
    final text = context.select<PlutoGridStateManager, String>((value) {
      return column.formattedValueForDisplay(cell.value);
    });

    context.select<PlutoGridStateManager, bool>((value) {
      return value.isCurrentCell(cell);
    });

    context.select<PlutoGridStateManager, bool>((value) {
      return value.hasFocus;
    });

    return column.hasRenderer
        ? column.renderer!(PlutoColumnRendererContext(
            column: column,
            rowIdx: rowIdx,
            row: row,
            cell: cell,
            stateManager: stateManager,
          ))
        : Text(
            text,
            style: stateManager.configuration!.cellTextStyle.copyWith(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: column.textAlign.value,
          );
  }
}
