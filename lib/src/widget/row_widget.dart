part of '../../pluto_grid.dart';

class RowWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  RowWidget({
    Key key,
    this.stateManager,
    this.rowIdx,
    this.row,
    this.columns,
  }) : super(key: key);

  @override
  _RowWidgetState createState() => _RowWidgetState();
}

class _RowWidgetState extends State<RowWidget> {
  bool _isCurrentRow;

  bool _isSelectedRow;

  bool _isSelecting;

  bool _isCheckedRow;

  bool _isDragTarget;

  bool _isTopOfDragTarget;

  bool _isBottomOfDragTarget;

  bool _hasCurrentSelectingPosition;

  bool _keepFocus;

  List<Function()> disposeList = [];

  @override
  void dispose() {
    disposeList.forEach((_dispose) => _dispose());

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);

    _isSelecting = widget.stateManager.isSelecting;

    _isCheckedRow = widget.row.checked;

    _isDragTarget = false;

    _isTopOfDragTarget = false;

    _isBottomOfDragTarget = false;

    _hasCurrentSelectingPosition =
        widget.stateManager.hasCurrentSelectingPosition;

    _keepFocus = widget.stateManager.keepFocus;

    widget.stateManager.addListener(changeStateListener);

    disposeList
        .add(() => widget.stateManager.removeListener(changeStateListener));

    disposeList.add(widget.stateManager.eventManager.subject.stream
        .listen(handlePlutoEvent)
        .cancel);
  }

  void changeStateListener() {
    if (_isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx) ||
        _isSelectedRow != widget.stateManager.isSelectedRow(widget.row.key) ||
        _isSelecting != widget.stateManager.isSelecting ||
        _isCheckedRow != widget.row.checked ||
        _hasCurrentSelectingPosition !=
            widget.stateManager.hasCurrentSelectingPosition ||
        _keepFocus != widget.stateManager.keepFocus) {
      setState(() {
        _isCurrentRow = (widget.stateManager.currentRowIdx == widget.rowIdx);
        _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);
        _isSelecting = widget.stateManager.isSelecting;
        _isCheckedRow = widget.row.checked;
        _hasCurrentSelectingPosition =
            widget.stateManager.hasCurrentSelectingPosition;
        _keepFocus = widget.stateManager.keepFocus;
      });
    }
  }

  void handlePlutoEvent(PlutoEvent event) {
    bool changedIsDragTarget = false;

    bool changedIsTopOfDragTarget = false;

    bool changedIsBottomOfDragTarget = false;

    if (event is PlutoDragEvent) {
      if (event.itemType.isRows && event.dragType.isUpdate) {
        final _dragTargetId =
            widget.stateManager.getRowIdxByOffset(event.offset.dy);

        if (_dragTargetId != null) {
          changedIsDragTarget = _dragTargetId <= widget.rowIdx &&
              widget.rowIdx < _dragTargetId + event.dragData.length;

          changedIsTopOfDragTarget = _dragTargetId == widget.rowIdx;

          changedIsBottomOfDragTarget =
              widget.rowIdx == _dragTargetId + event.dragData.length - 1;
        }
      }
    }

    if (_isDragTarget != changedIsDragTarget ||
        _isTopOfDragTarget != changedIsTopOfDragTarget ||
        _isBottomOfDragTarget != changedIsBottomOfDragTarget) {
      setState(() {
        _isDragTarget = changedIsDragTarget;
        _isTopOfDragTarget = changedIsTopOfDragTarget;
        _isBottomOfDragTarget = changedIsBottomOfDragTarget;
      });
    }
  }

  Color rowColor() {
    if (_isDragTarget) return widget.stateManager.configuration.checkedColor;

    final bool checkCurrentRow =
        _isCurrentRow && (!_isSelecting && !_hasCurrentSelectingPosition);

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
    return Container(
      decoration: BoxDecoration(
        color: _isCheckedRow
            ? Color.alphaBlend(Color(0x11757575), rowColor())
            : rowColor(),
        border: Border(
          top: _isDragTarget && _isTopOfDragTarget
              ? BorderSide(
                  width: PlutoDefaultSettings.rowBorderWidth,
                  color: widget.stateManager.configuration.activatedBorderColor,
                )
              : BorderSide.none,
          bottom: BorderSide(
            width: PlutoDefaultSettings.rowBorderWidth,
            color: _isDragTarget && _isBottomOfDragTarget
                ? widget.stateManager.configuration.activatedBorderColor
                : widget.stateManager.configuration.borderColor,
          ),
        ),
      ),
      child: Row(
        children: widget.columns.map((column) {
          return CellWidget(
            key: widget.row.cells[column.field]._key,
            stateManager: widget.stateManager,
            cell: widget.row.cells[column.field],
            width: column.width,
            height: PlutoDefaultSettings.rowHeight,
            column: column,
            rowIdx: widget.rowIdx,
          );
        }).toList(growable: false),
      ),
    );
  }
}
