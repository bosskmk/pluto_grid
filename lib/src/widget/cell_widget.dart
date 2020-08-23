part of pluto_grid;

class CellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final double width;
  final double height;
  final PlutoColumn column;
  final int rowIdx;

  CellWidget({
    this.stateManager,
    this.cell,
    this.width,
    this.height,
    this.column,
    this.rowIdx,
  }) : super(key: cell._key);

  @override
  _CellWidgetState createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with AutomaticKeepAliveClientMixin {
  String _cellValue;

  bool _isCurrentCell;

  bool _isEditing;

  bool _isSelectedCell;

  PlutoCellPosition _selectingPosition;

  final _selectionSubject = ReplaySubject<Function()>();

  final _scrollSubject = ReplaySubject<Function()>();

  @override
  bool get wantKeepAlive => true;

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

    super.initState();
  }

  void changeStateListener() {
    final String changedCellValue = widget
        .stateManager.rows[widget.rowIdx].cells[widget.column.field].value;

    final bool changedIsCurrentCell =
        widget.stateManager.isCurrentCell(widget.cell);

    final bool changedIsEditing = widget.stateManager.isEditing;

    final bool changedIsSelectedCell = _getIsSelectedCell();

    final PlutoCellPosition changedSelectingPosition =
        widget.stateManager.currentSelectingPosition;

    if (_cellValue != changedCellValue ||
        _isCurrentCell != changedIsCurrentCell ||
        _isEditing != changedIsEditing ||
        _isSelectedCell != changedIsSelectedCell ||
        _selectingPosition != changedSelectingPosition) {
      setState(() {
        _cellValue = changedCellValue;
        _isCurrentCell = changedIsCurrentCell;
        _isEditing = changedIsEditing;
        _isSelectedCell = changedIsSelectedCell;
        _selectingPosition = changedSelectingPosition;
      });
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

    final _columnIndexes = widget.stateManager.columnIndexesByShowFixed();

    for (var i = 0; i < _columnIndexes.length; i += 1) {
      if (widget.stateManager.columns[_columnIndexes[i]].field ==
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
                widget.stateManager.layout.maxHeight -
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
        _cellValue,
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
        if (_isCurrentCell && _isEditing != true) {
          widget.stateManager.setEditing(true);
        } else {
          widget.stateManager.setCurrentCell(widget.cell, widget.rowIdx);
        }
      },
      onTapUp: (TapUpDetails details) {
        if (widget.stateManager.mode.isSelectRow) {
          widget.stateManager.handleOnSelectedRow();
        }
      },
      onLongPressStart: (LongPressStartDetails details) {
        if (_isCurrentCell && _isEditing != true) {
          widget.stateManager.setSelecting(true);
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        if (_isCurrentCell && _isEditing != true) {
          _selectionSubject.add(() {
            widget.stateManager
                .setCurrentSelectingPosition(details.globalPosition);
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
        if (_isCurrentCell && _isEditing != true) {
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

  Color _color() {
    return isEditing == true && readOnly != true ? Colors.white : null;
  }

  BoxDecoration _boxDecoration() {
    if (isCurrentCell) {
      return BoxDecoration(
        color: _color(),
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
