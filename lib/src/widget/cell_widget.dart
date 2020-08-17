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
          column: widget.column,
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
      child: _BackgroundColorWidget(
        readOnly: widget.column.type.readOnly,
        child: _buildCell(),
        width: widget.width,
        height: widget.height,
        isCurrentCell: _isCurrentCell,
        isEditing: _isEditing,
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

  _BackgroundColorWidget({
    this.readOnly,
    this.child,
    this.width,
    this.height,
    this.isCurrentCell,
    this.isEditing,
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
