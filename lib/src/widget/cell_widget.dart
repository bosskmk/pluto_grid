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

    _selectionSubject.stream
        .debounceTime(Duration(milliseconds: 4))
        .listen((event) {
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
    final bool changedIsCurrentCell =
        widget.stateManager.isCurrentCell(widget.cell);

    final bool changedIsEditing = widget.stateManager.isEditing;

    final PlutoSelectingMode changedSelectingMode =
        widget.stateManager.selectingMode;

    final bool changedIsSelectedCell = _getIsSelectedCell();

    bool checkCellValue = widget.stateManager.checkCellValue;

    dynamic changedCellValue;

    if (checkCellValue) {
      // 키보드로 셀 이동을 빠르게 할 때 이 부분에서 느려진다.
      // 키보드 이동을 제외한 값 변경의 확인이 필요한 부분에서만 호출.
      changedCellValue = widget
          .stateManager.rows[widget.rowIdx].cells[widget.column.field].value;
    }

    if ((checkCellValue && _cellValue != changedCellValue) ||
        _isCurrentCell != changedIsCurrentCell ||
        (_isCurrentCell && _isEditing != changedIsEditing) ||
        _selectingMode != changedSelectingMode ||
        _isSelectedCell != changedIsSelectedCell) {
      setState(() {
        if (checkCellValue) {
          _cellValue = changedCellValue;
        }

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
    if (widget.stateManager.selectingMode.isNone) {
      return false;
    }

    switch (move) {
      case MoveDirection.Left:
        var leftFixedColumnWidth = widget.stateManager.showFixedColumn
            ? widget.stateManager.leftFixedColumnsWidth
            : 0;

        return selectingOffset.dx <
            widget.stateManager.gridGlobalOffset.dx +
                PlutoDefaultSettings.gridPadding +
                PlutoDefaultSettings.gridBorderWidth +
                leftFixedColumnWidth +
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Right:
        var rightFixedColumnWidth = widget.stateManager.showFixedColumn
            ? widget.stateManager.rightFixedColumnsWidth
            : 0;

        return selectingOffset.dx >
            (widget.stateManager.gridGlobalOffset.dx +
                    widget.stateManager.maxWidth) -
                rightFixedColumnWidth -
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Up:
        return selectingOffset.dy <
            widget.stateManager.gridGlobalOffset.dy +
                PlutoDefaultSettings.gridBorderWidth +
                PlutoDefaultSettings.rowTotalHeight +
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Down:
        return selectingOffset.dy >
            widget.stateManager.gridGlobalOffset.dy +
                widget.stateManager.offsetHeight -
                PlutoDefaultSettings.offsetScrollingFromEdge;
    }

    return false;
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
      return Text(
        widget.column.type.isNumber
            ? widget.column.type.number.applyFormat(_cellValue)
            : _cellValue.toString(),
        style: widget.stateManager.configuration.cellTextStyle,
        overflow: TextOverflow.ellipsis,
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
    this.isCurrentCell,
    this.isEditing,
    this.selectingMode,
    this.isSelectedCell,
    this.configuration,
  });

  Color _currentCellColor() {
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
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
