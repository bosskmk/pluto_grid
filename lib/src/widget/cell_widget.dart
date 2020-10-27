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

  final _selectionSubject = PublishSubject<Function()>();

  final _scrollSubject = PublishSubject<Function()>();

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

    _selectionSubject.close();

    _scrollSubject.close();

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

    _selectionSubject.stream.listen((event) {
      event();
    });

    _scrollSubject.stream
        .throttleTime(Duration(milliseconds: 800))
        .listen((event) {
      event();
    });

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

  bool _needMovingScroll(Offset selectingOffset, MoveDirection move) {
    return widget.stateManager.needMovingScroll(selectingOffset, move);
  }

  void _scrollForDraggableSelection(MoveDirection move) {
    if (move == null) {
      return;
    }

    final LinkedScrollControllerGroup scroll = move.horizontal
        ? widget.stateManager.scroll.horizontal
        : widget.stateManager.scroll.vertical;

    final double offset = move.isLeft || move.isUp
        ? -PlutoDefaultSettings.offsetScrollingFromEdgeAtOnce
        : PlutoDefaultSettings.offsetScrollingFromEdgeAtOnce;

    scroll.animateTo(scroll.offset + offset,
        curve: Curves.ease, duration: Duration(milliseconds: 800));
  }

  Widget _buildCell() {
    if (!_isCurrentCell || !_isEditing) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          widget.column.formattedValueForDisplay(_cellValue),
          style: widget.stateManager.configuration.cellTextStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: widget.column.textAlign.value,
        ),
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

    throw ('Type not implemented.');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (TapDownDetails details) {
        if (!widget.stateManager.hasFocus) {
          widget.stateManager.setKeepFocus(true);

          if (_isCurrentCell) {
            return;
          }
        }

        if (widget.stateManager.isSelectingInteraction()) {
          if (widget.stateManager.keyPressed.shift) {
            final int columnIdx =
                widget.stateManager.columnIndex(widget.column);

            widget.stateManager.setCurrentSelectingPosition(
                columnIdx: columnIdx, rowIdx: widget.rowIdx);
          } else if (widget.stateManager.keyPressed.ctrl) {
            widget.stateManager.toggleSelectingRow(widget.rowIdx);
          }
        } else {
          if (widget.stateManager.mode.isSelect) {
            if (_isCurrentCell) {
              widget.stateManager.handleOnSelected();
            } else {
              widget.stateManager.setCurrentCell(widget.cell, widget.rowIdx);
            }
          } else {
            if (_isCurrentCell && _isEditing != true) {
              widget.stateManager.setEditing(true);
            } else {
              widget.stateManager.setCurrentCell(widget.cell, widget.rowIdx);
            }
          }
        }
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_isCurrentCell) {
          widget.stateManager.setSelecting(true);

          if (_selectingMode.isRow) {
            widget.stateManager.toggleSelectingRow(widget.rowIdx);
          }
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (_isCurrentCell) {
          _selectionSubject.add(() {
            widget.stateManager
                .setCurrentSelectingPositionWithOffset(details.globalPosition);
          });

          _scrollSubject.add(() {
            if (_needMovingScroll(details.globalPosition, MoveDirection.Left)) {
              _scrollForDraggableSelection(MoveDirection.Left);
            } else if (_needMovingScroll(
                details.globalPosition, MoveDirection.Right)) {
              _scrollForDraggableSelection(MoveDirection.Right);
            }

            if (_needMovingScroll(details.globalPosition, MoveDirection.Up)) {
              _scrollForDraggableSelection(MoveDirection.Up);
            } else if (_needMovingScroll(
                details.globalPosition, MoveDirection.Down)) {
              _scrollForDraggableSelection(MoveDirection.Down);
            }
          });
        }
      },
      onLongPressEnd: (LongPressEndDetails details) {
        if (_isCurrentCell) {
          widget.stateManager.setSelecting(false);
        }
      },
      child: _BackgroundColorWidget(
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

class _BackgroundColorWidget extends StatelessWidget {
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

  _BackgroundColorWidget({
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
          : BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(
          horizontal: PlutoDefaultSettings.cellPadding),
      decoration: _boxDecoration(),
      child: child,
    );
  }
}

enum _CellEditingStatus {
  INIT,
  CHANGED,
  UPDATED,
}

extension _CellEditingStatusExtension on _CellEditingStatus {
  bool get isChanged {
    return _CellEditingStatus.CHANGED == this;
  }
}
