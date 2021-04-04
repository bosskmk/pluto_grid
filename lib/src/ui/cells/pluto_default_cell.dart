import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoDefaultCell extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;
  final int? rowIdx;

  PlutoDefaultCell({
    required this.stateManager,
    this.cell,
    this.column,
    this.rowIdx,
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
  PlutoRow? get thisRow => widget.stateManager.getRowByIdx(widget.rowIdx);

  bool get isCurrentRowSelected {
    return widget.stateManager.isSelectedRow(thisRow?.key);
  }

  void addDragEventOfRow({
    PlutoGridDragType? type,
    Offset? offset,
  }) {
    if (offset != null) {
      offset += Offset(0.0, (widget.stateManager.rowTotalHeight / 2));
    }

    widget.stateManager.eventManager!.addEvent(
      PlutoGridDragRowsEvent(
        offset: offset,
        dragType: type,
        rows: isCurrentRowSelected
            ? widget.stateManager.currentSelectingRows
            : [thisRow],
      ),
    );
  }

  void _handleOnDragStarted() {
    addDragEventOfRow(type: PlutoGridDragType.start);
  }

  void _handleOnDragUpdated(Offset offset) {
    addDragEventOfRow(
      type: PlutoGridDragType.update,
      offset: offset,
    );

    widget.stateManager.eventManager!.addEvent(PlutoGridMoveUpdateEvent(
      offset: offset,
    ));
  }

  void _handleOnDragEnd(DraggableDetails dragDetails) {
    addDragEventOfRow(
      type: PlutoGridDragType.end,
      offset: dragDetails.offset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellWidget = _BuildDefaultCellWidget(
      stateManager: widget.stateManager,
      rowIdx: widget.rowIdx,
      row: thisRow,
      column: widget.column,
      cell: widget.cell,
    );

    return Row(
      children: [
        // todo : When onDragUpdated is added to the Draggable, remove the listener.
        // https://github.com/flutter/flutter/pull/68185
        if (widget.column!.enableRowDrag && canRowDrag!)
          _RowDragIconWidget(
            column: widget.column,
            stateManager: widget.stateManager,
            onDragStarted: _handleOnDragStarted,
            onDragUpdated: _handleOnDragUpdated,
            onDragEnd: _handleOnDragEnd,
            feedbackWidget: cellWidget,
            dragIcon: Icon(
              Icons.drag_indicator,
              size: widget.stateManager.configuration!.iconSize,
              color: widget.stateManager.configuration!.iconColor,
            ),
          ),
        if (widget.column!.enableRowChecked)
          _CheckboxSelectionWidget(
            column: widget.column,
            row: thisRow,
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
  final PlutoColumn? column;
  final PlutoGridStateManager? stateManager;
  final VoidCallback? onDragStarted;
  final DragUpdatedCallback? onDragUpdated;
  final DragEndCallback? onDragEnd;
  final Widget? dragIcon;
  final Widget? feedbackWidget;

  const _RowDragIconWidget({
    Key? key,
    this.column,
    this.stateManager,
    this.onDragStarted,
    this.onDragUpdated,
    this.onDragEnd,
    this.dragIcon,
    this.feedbackWidget,
  }) : super(key: key);

  @override
  __RowDragIconWidgetState createState() => __RowDragIconWidgetState();
}

class __RowDragIconWidgetState extends State<_RowDragIconWidget> {
  final GlobalKey _feedbackKey = GlobalKey();

  bool _isDragging = false;

  Offset? get _offsetFeedback {
    if (_feedbackKey.currentContext == null) {
      return null;
    }

    final RenderBox renderBoxRed =
        _feedbackKey.currentContext!.findRenderObject() as RenderBox;

    return renderBoxRed.localToGlobal(Offset.zero);
  }

  void _onPointerMove(PointerMoveEvent _) {
    if (_isDragging == false) {
      return;
    }

    widget.onDragUpdated!(_offsetFeedback ?? _.position);
  }

  void _onDragStarted() {
    _isDragging = true;
    widget.onDragStarted!();
  }

  void _onDragEnd(DraggableDetails _) {
    _isDragging = false;
    widget.onDragEnd!(_);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      child: Draggable(
        onDragStarted: _onDragStarted,
        onDragEnd: _onDragEnd,
        feedback: Material(
          key: _feedbackKey,
          child: PlutoShadowContainer(
            width: widget.column!.width,
            height: widget.stateManager!.rowHeight,
            backgroundColor:
                widget.stateManager!.configuration!.gridBackgroundColor,
            borderColor: widget.stateManager!.configuration!.activatedBorderColor,
            child: Row(
              children: [
                widget.dragIcon!,
                Expanded(
                  child: widget.feedbackWidget!,
                ),
              ],
            ),
          ),
        ),
        child: widget.dragIcon!,
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
