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
  bool _hasSortedColumn;

  PlutoRow get thisRow => widget.stateManager.getRowByIdx(widget.rowIdx);

  bool get isCurrentRowSelected {
    return widget.stateManager.isSelectedRow(thisRow?.key);
  }

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _hasSortedColumn = widget.stateManager.hasSortedColumn;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    bool changeHasSortedColumn = widget.stateManager.hasSortedColumn;

    if (_hasSortedColumn != changeHasSortedColumn) {
      setState(() {
        _hasSortedColumn = changeHasSortedColumn;
      });
    }
  }

  void addDragEventOfRow({
    PlutoDragType type,
    Offset offset,
  }) {
    if (offset != null) {
      offset += const Offset(0.0, (PlutoDefaultSettings.rowTotalHeight / 2));
    }

    widget.stateManager.eventManager.addEvent(
      PlutoDragRowsEvent(
        offset: offset,
        dragType: type,
        rows: isCurrentRowSelected
            ? widget.stateManager.currentSelectingRows
            : [thisRow],
      ),
    );
  }

  Icon getDragIcon() {
    return Icon(
      Icons.drag_indicator,
      size: 18,
      color: widget.stateManager.configuration.iconColor,
    );
  }

  Widget getCellWidget() {
    return widget.column.hasRenderer
        ? widget.column.renderer(PlutoColumnRendererContext(
            column: widget.column,
            rowIdx: widget.rowIdx,
            row: thisRow,
            cell: widget.cell,
            stateManager: widget.stateManager,
          ))
        : Text(
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
        // todo : When onDragUpdated is added to the Draggable, remove the listener.
        // https://github.com/flutter/flutter/pull/68185
        if (widget.column.enableRowDrag && !_hasSortedColumn)
          _RowDragIconWidget(
            column: widget.column,
            stateManager: widget.stateManager,
            onDragStarted: () {
              addDragEventOfRow(type: PlutoDragType.start);
            },
            onDragUpdated: (offset) {
              addDragEventOfRow(
                type: PlutoDragType.update,
                offset: offset,
              );

              widget.stateManager.eventManager.addEvent(PlutoMoveUpdateEvent(
                offset: offset,
              ));
            },
            onDragEnd: (dragDetails) {
              addDragEventOfRow(
                type: PlutoDragType.end,
                offset: dragDetails.offset,
              );
            },
            dragIcon: getDragIcon(),
            feedbackWidget: getCellWidget(),
          ),
        if (widget.column.enableRowChecked)
          _CheckboxSelectionWidget(
            column: widget.column,
            row: thisRow,
            stateManager: widget.stateManager,
          ),
        Expanded(
          child: getCellWidget(),
        ),
      ],
    );
  }
}

typedef DragUpdatedCallback = Function(Offset offset);

class _RowDragIconWidget extends StatefulWidget {
  final PlutoColumn column;
  final PlutoStateManager stateManager;
  final VoidCallback onDragStarted;
  final DragUpdatedCallback onDragUpdated;
  final DragEndCallback onDragEnd;
  final Widget dragIcon;
  final Widget feedbackWidget;

  const _RowDragIconWidget({
    Key key,
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

  Offset get _offsetFeedback {
    if (_feedbackKey.currentContext == null) {
      return null;
    }

    final RenderBox renderBoxRed =
        _feedbackKey.currentContext.findRenderObject();

    return renderBoxRed.localToGlobal(Offset.zero);
  }

  void _onPointerMove(PointerMoveEvent _) {
    if (_isDragging == false) {
      return;
    }

    widget.onDragUpdated(_offsetFeedback ?? _.position);
  }

  void _onDragStarted() {
    _isDragging = true;
    widget.onDragStarted();
  }

  void _onDragEnd(DraggableDetails _) {
    _isDragging = false;
    widget.onDragEnd(_);
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
          child: ShadowContainer(
            width: widget.column.width,
            height: PlutoDefaultSettings.rowHeight,
            backgroundColor:
                widget.stateManager.configuration.gridBackgroundColor,
            borderColor: widget.stateManager.configuration.activatedBorderColor,
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

class _CheckboxSelectionWidget extends StatefulWidget {
  final PlutoColumn column;
  final PlutoRow row;
  final PlutoStateManager stateManager;

  _CheckboxSelectionWidget({
    this.column,
    this.row,
    this.stateManager,
  });

  @override
  __CheckboxSelectionWidgetState createState() =>
      __CheckboxSelectionWidgetState();
}

class __CheckboxSelectionWidgetState extends State<_CheckboxSelectionWidget> {
  bool _checked;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _checked = widget.row.checked;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    bool changedChecked = widget.row.checked;

    if (_checked != changedChecked) {
      setState(() {
        _checked = changedChecked;
      });
    }
  }

  void _handleOnChanged(bool changed) {
    if (changed == _checked) {
      return;
    }

    widget.stateManager.setRowChecked(widget.row, changed);

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration.iconColor,
      activeColor: widget.stateManager.configuration.activatedBorderColor,
      checkColor: widget.stateManager.configuration.activatedColor,
    );
  }
}
