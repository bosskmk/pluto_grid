part of '../../pluto_grid.dart';

class CellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final double width;
  final double height;
  final PlutoColumn column;
  final int rowIdx;

  CellWidget({
    Key key,
    this.stateManager,
    this.cell,
    this.width,
    this.height,
    this.column,
    this.rowIdx,
  }) : super(key: key);

  @override
  _CellWidgetState createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with AutomaticKeepAliveClientMixin {
  dynamic _cellValue;

  bool _isCurrentCell;

  bool _isEditing;

  PlutoSelectingMode _selectingMode;

  bool _isSelectedCell;

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

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _cellValue = widget.cell.value;

    _isCurrentCell = widget.stateManager.isCurrentCell(widget.cell);

    _isEditing = widget.stateManager.isEditing;

    _selectingMode = widget.stateManager.selectingMode;

    _isSelectedCell = _getIsSelectedCell();

    widget.stateManager.addListener(changeStateListener);

    _resetKeepAlive();
  }

  void changeStateListener() {
    if (widget.stateManager._rows.length - 1 < widget.rowIdx) {
      return;
    }

    final bool changedIsCurrentCell =
        widget.stateManager.isCurrentCell(widget.cell);

    final bool changedIsEditing = widget.stateManager.isEditing;

    final PlutoSelectingMode changedSelectingMode =
        widget.stateManager.selectingMode;

    final bool changedIsSelectedCell = _getIsSelectedCell();

    final dynamic changedCellValue = widget
        .stateManager._rows[widget.rowIdx].cells[widget.column.field].value;

    if (_cellValue != changedCellValue ||
        _isCurrentCell != changedIsCurrentCell ||
        (_isCurrentCell && _isEditing != changedIsEditing) ||
        _selectingMode != changedSelectingMode ||
        _isSelectedCell != changedIsSelectedCell) {
      setState(() {
        _cellValue = changedCellValue;
        _isCurrentCell = changedIsCurrentCell;
        _isEditing = changedIsEditing;
        _selectingMode = changedSelectingMode;
        _isSelectedCell = changedIsSelectedCell;

        _resetKeepAlive();
      });
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

    final bool resetKeepAlive = _isCurrentCell;

    if (_keepAlive != resetKeepAlive) {
      _keepAlive = resetKeepAlive;

      updateKeepAlive();
    }
  }

  bool _getIsSelectedCell() {
    return widget.stateManager
        .isSelectedCell(widget.cell, widget.column, widget.rowIdx);
  }

  Widget _buildCell() {
    if (!_isCurrentCell || !_isEditing) {
      return DefaultCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
        rowIdx: widget.rowIdx,
      );
    }

    if (widget.column.type.isSelect) {
      return SelectCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
      );
    } else if (widget.column.type.isNumber) {
      return NumberCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
      );
    } else if (widget.column.type.isDate) {
      return DateCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
      );
    } else if (widget.column.type.isTime) {
      return TimeCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
      );
    } else if (widget.column.type.isText) {
      return TextCellWidget(
        stateManager: widget.stateManager,
        cell: widget.cell,
        column: widget.column,
      );
    }

    throw Exception('Type not implemented.');
  }

  void _addGestureEvent(PlutoGestureType gestureType, Offset offset) {
    widget.stateManager.eventManager.addEvent(
      PlutoCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: widget.cell,
        column: widget.column,
        rowIdx: widget.rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    _addGestureEvent(PlutoGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    _addGestureEvent(PlutoGestureType.onLongPressStart, details.globalPosition);
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    _addGestureEvent(
        PlutoGestureType.onLongPressMoveUpdate, details.globalPosition);
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    _addGestureEvent(PlutoGestureType.onLongPressEnd, details.globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: _handleOnTapUp,
      onLongPressStart: _handleOnLongPressStart,
      onLongPressMoveUpdate: _handleOnLongPressMoveUpdate,
      onLongPressEnd: _handleOnLongPressEnd,
      child: _CellContainerWidget(
        readOnly: widget.column.type.readOnly,
        child: _buildCell(),
        width: widget.width,
        height: widget.height,
        hasFocus: widget.stateManager.hasFocus,
        isCurrentCell: _isCurrentCell,
        isEditing: _isEditing,
        selectingMode: _selectingMode,
        isSelectedCell: _isSelectedCell,
        configuration: widget.stateManager.configuration,
      ),
    );
  }
}

class _CellContainerWidget extends StatelessWidget {
  final bool readOnly;
  final Widget child;
  final double width;
  final double height;
  final bool hasFocus;
  final bool isCurrentCell;
  final bool isEditing;
  final PlutoSelectingMode selectingMode;
  final bool isSelectedCell;
  final PlutoConfiguration configuration;

  _CellContainerWidget({
    this.readOnly,
    this.child,
    this.width,
    this.height,
    this.hasFocus,
    this.isCurrentCell,
    this.isEditing,
    this.selectingMode,
    this.isSelectedCell,
    this.configuration,
  });

  Color _currentCellColor() {
    if (!hasFocus) {
      return null;
    }

    if (!isEditing) {
      return selectingMode.isRow ? configuration.activatedColor : null;
    }

    return readOnly == true
        ? configuration.cellColorInReadOnlyState
        : configuration.cellColorInEditState;
  }

  BoxDecoration _boxDecoration() {
    if (isCurrentCell) {
      return BoxDecoration(
        color: _currentCellColor(),
        border: Border.all(
          color: configuration.activatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: configuration.activatedColor,
        border: Border.all(
          color: configuration.activatedBorderColor,
          width: 1,
        ),
      );
    } else {
      return configuration.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: configuration.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: _boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: PlutoDefaultSettings.cellPadding),
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: height,
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(),
          child: child,
        ),
      ),
    );
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated,
}

extension _CellEditingStatusExtension on _CellEditingStatus {
  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }
}
