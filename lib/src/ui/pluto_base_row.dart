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

class _RowContainerWidget extends StatefulWidget {
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

class __RowContainerWidgetState extends State<_RowContainerWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isCurrentRow;

  bool _isSelectedRow;

  bool _isSelecting;

  bool _isCheckedRow;

  bool _isDragTarget;

  bool _isTopDragTarget;

  bool _isBottomDragTarget;

  bool _hasCurrentSelectingPosition;

  bool _keepFocus;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    resetState();

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (_isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx) ||
        _isSelectedRow != widget.stateManager.isSelectedRow(widget.row.key) ||
        _isSelecting != widget.stateManager.isSelecting ||
        _isCheckedRow != widget.row.checked ||
        _isDragTarget !=
            widget.stateManager.isRowIdxDragTarget(widget.rowIdx) ||
        _isTopDragTarget !=
            widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx) ||
        _isBottomDragTarget !=
            widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx) ||
        _hasCurrentSelectingPosition !=
            widget.stateManager.hasCurrentSelectingPosition ||
        (_isCurrentRow == true &&
            _keepFocus != widget.stateManager.keepFocus)) {
      setState(() {
        resetState();
        _resetKeepAlive();
      });
    }
  }

  void resetState() {
    _isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);

    _isSelecting = widget.stateManager.isSelecting;

    _isCheckedRow = widget.row.checked;

    _isDragTarget = widget.stateManager.isRowIdxDragTarget(widget.rowIdx);

    _isTopDragTarget = widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx);

    _isBottomDragTarget =
        widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx);

    _hasCurrentSelectingPosition =
        widget.stateManager.hasCurrentSelectingPosition;

    _keepFocus = widget.stateManager.keepFocus;
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

  bool _keepAlive = false;

  KeepAliveHandle _keepAliveHandle;

  @override
  bool get wantKeepAlive => _keepAlive;

  @protected
  void updateKeepAlive() {
    if (wantKeepAlive) {
      if (_keepAliveHandle == null) _ensureKeepAlive();
    } else {
      if (_keepAliveHandle != null) _releaseKeepAlive();
    }
  }

  void _ensureKeepAlive() {
    assert(_keepAliveHandle == null);
    _keepAliveHandle = KeepAliveHandle();
    KeepAliveNotification(_keepAliveHandle).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle.release();
    _keepAliveHandle = null;
  }

  void _resetKeepAlive() {
    if (!widget.stateManager.mode.isNormal) {
      return;
    }

    final bool resetKeepAlive =
        widget.stateManager.isRowBeingDragged(widget.row.key);

    if (_keepAlive != resetKeepAlive) {
      _keepAlive = resetKeepAlive;

      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      decoration: BoxDecoration(
        color: _isCheckedRow
            ? Color.alphaBlend(const Color(0x11757575), rowColor())
            : rowColor(),
        border: Border(
          top: _isDragTarget && _isTopDragTarget
              ? BorderSide(
                  width: PlutoGridSettings.rowBorderWidth,
                  color: widget.stateManager.configuration.activatedBorderColor,
                )
              : BorderSide.none,
          bottom: BorderSide(
            width: PlutoGridSettings.rowBorderWidth,
            color: _isDragTarget && _isBottomDragTarget
                ? widget.stateManager.configuration.activatedBorderColor
                : widget.stateManager.configuration.borderColor,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
