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

class _CellWidgetState extends State<CellWidget> {
  bool _isCurrentCell;

  bool _isEditing;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);
    super.dispose();
  }

  @override
  void initState() {
    _isCurrentCell = widget.stateManager.isCurrentCell(widget.cell);

    _isEditing = widget.stateManager.isEditing;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    final bool changedIsCurrentCell =
        widget.stateManager.isCurrentCell(widget.cell);

    final bool changedIsEditing = widget.stateManager.isEditing;

    if (_isCurrentCell != changedIsCurrentCell ||
        _isEditing != changedIsEditing) {
      setState(() {
        _isCurrentCell = changedIsCurrentCell;
        _isEditing = changedIsEditing;
      });
    }
  }

  BoxDecoration _boxDecoration() {
    if (_isCurrentCell) {
      return BoxDecoration(
        border: Border.all(
          color: Colors.lightBlue,
          width: 1,
        ),
      );
    } else {
      return BoxDecoration();
    }
  }

  Widget _buildCell() {
    if (!_isCurrentCell || !_isEditing) {
      return Text(
        widget.cell.value,
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
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration(),
        child: _buildCell(),
      ),
    );
  }
}
