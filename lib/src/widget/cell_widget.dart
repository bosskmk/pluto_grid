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

  bool _isSelectedCell;

  PlutoCellPosition _selectingPosition;

  final _selectionSubject = ReplaySubject<Function()>();

  final _scrollSubject = ReplaySubject<Function()>();

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
    _cellValue = widget.cell.value;

    _isCurrentCell = widget.stateManager.isCurrentCell(widget.cell);

    _isEditing = widget.stateManager.isEditing;

    _isSelectedCell = _getIsSelectedCell();

    _selectingPosition = widget.stateManager.currentSelectingPosition;

    widget.stateManager.addListener(changeStateListener);

    _selectionSubject.debounceTime(Duration(milliseconds: 4)).listen((event) {
      event();
    });

    _scrollSubject.throttleTime(Duration(milliseconds: 800)).listen((event) {
      event();
    });

    _resetKeepAlive();

    super.initState();
  }

  void changeStateListener() {
    final bool changedIsCurrentCell =
        widget.stateManager.isCurrentCell(widget.cell);

    final bool changedIsEditing = widget.stateManager.isEditing;

    final bool changedIsSelectedCell = _getIsSelectedCell();

    final PlutoCellPosition changedSelectingPosition =
        widget.stateManager.currentSelectingPosition;

    bool checkCellValue = widget.stateManager._checkCellValue;

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
        _isSelectedCell != changedIsSelectedCell ||
        _selectingPosition != changedSelectingPosition) {
      setState(() {
        if (checkCellValue) {
          _cellValue = changedCellValue;
        }

        _isCurrentCell = changedIsCurrentCell;
        _isEditing = changedIsEditing;
        _isSelectedCell = changedIsSelectedCell;
        _selectingPosition = changedSelectingPosition;

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
    if (widget.stateManager.isCurrentCell(widget.cell) == true) {
      return false;
    }

    if (widget.stateManager.currentSelectingPosition == null) {
      return false;
    }

    PlutoCellPosition currentCellPosition =
        widget.stateManager.currentCellPosition;

    final bool inRangeOfRows = min(currentCellPosition.rowIdx,
                widget.stateManager.currentSelectingPosition.rowIdx) <=
            widget.rowIdx &&
        widget.rowIdx <=
            max(currentCellPosition.rowIdx,
                widget.stateManager.currentSelectingPosition.rowIdx);

    if (inRangeOfRows == false) {
      return false;
    }

    int columnIdx;

    final columnIndexes = widget.stateManager.columnIndexesByShowFixed();

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (widget.stateManager.columns[columnIndexes[i]].field ==
          widget.column.field) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      return false;
    }

    final bool inRangeOfColumns = min(currentCellPosition.columnIdx,
                widget.stateManager.currentSelectingPosition.columnIdx) <=
            columnIdx &&
        columnIdx <=
            max(currentCellPosition.columnIdx,
                widget.stateManager.currentSelectingPosition.columnIdx);

    if (inRangeOfColumns == false) {
      return false;
    }

    return true;
  }

  bool _needMovingScroll(Offset selectingOffset, MoveDirection move) {
    switch (move) {
      case MoveDirection.Left:
        var leftFixedColumnWidth = widget.stateManager.layout.showFixedColumn
            ? widget.stateManager.leftFixedColumnsWidth
            : 0;

        return selectingOffset.dx <
            widget.stateManager.gridGlobalOffset.dx +
                PlutoDefaultSettings.gridPadding +
                PlutoDefaultSettings.gridBorderWidth +
                leftFixedColumnWidth +
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Right:
        var rightFixedColumnWidth = widget.stateManager.layout.showFixedColumn
            ? widget.stateManager.rightFixedColumnsWidth
            : 0;

        return selectingOffset.dx >
            (widget.stateManager.gridGlobalOffset.dx +
                    widget.stateManager.layout.maxWidth) -
                rightFixedColumnWidth -
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Up:
        return selectingOffset.dy <
            widget.stateManager.gridGlobalOffset.dy +
                PlutoDefaultSettings.rowHeight +
                PlutoDefaultSettings.gridBorderWidth +
                PlutoDefaultSettings.rowBorderWidth +
                PlutoDefaultSettings.offsetScrollingFromEdge;
      case MoveDirection.Down:
        return selectingOffset.dy >
            widget.stateManager.gridGlobalOffset.dy +
                widget.stateManager.layout.offsetHeight -
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
        widget.column.type.name.isNumber
            ? widget.column.type.numberFormat(_cellValue)
            : _cellValue.toString(),
        overflow: TextOverflow.ellipsis,
      );
    }

    switch (widget.column.type.name) {
      case _PlutoColumnTypeName.Select:
        return SelectCellWidget(
          stateManager: widget.stateManager,
          cell: widget.cell,
          column: widget.column,
        );
      case _PlutoColumnTypeName.Number:
        return NumberCellWidget(
          stateManager: widget.stateManager,
          cell: widget.cell,
          column: widget.column,
        );
      case _PlutoColumnTypeName.Datetime:
        return DatetimeCellWidget(
          stateManager: widget.stateManager,
          cell: widget.cell,
          column: widget.column,
        );
      case _PlutoColumnTypeName.Text:
      default:
        return TextCellWidget(
          stateManager: widget.stateManager,
          cell: widget.cell,
          column: widget.column,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (TapDownDetails details) {
        if (widget.stateManager.keyPressed.shift &&
            widget.stateManager.currentCell != null) {
          final int columnIdx = widget.stateManager.columnIndex(widget.column);

          widget.stateManager.setCurrentSelectingPosition(
              columnIdx: columnIdx, rowIdx: widget.rowIdx);

          return;
        }

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
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_isCurrentCell) {
          widget.stateManager.setSelecting(true);
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
        isSelectedCell: _isSelectedCell,
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
  final bool isSelectedCell;

  _BackgroundColorWidget({
    this.readOnly,
    this.child,
    this.width,
    this.height,
    this.isCurrentCell,
    this.isEditing,
    this.isSelectedCell,
  });

  Color _boxColor() {
    if (isEditing != true) {
      return null;
    }

    return readOnly == true
        ? PlutoDefaultSettings.currentReadOnlyCellColor
        : PlutoDefaultSettings.currentEditingCellColor;
  }

  BoxDecoration _boxDecoration() {
    if (isCurrentCell) {
      return BoxDecoration(
        color: _boxColor(),
        border: Border.all(
          color: PlutoDefaultSettings.currentCellBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: PlutoDefaultSettings.currentRowColor,
        border: Border.all(
          color: PlutoDefaultSettings.currentCellBorderColor,
          width: 1,
        ),
      );
    } else {
      return BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: width,
      height: height,
      padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
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
