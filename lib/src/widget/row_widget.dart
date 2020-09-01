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

  bool _isSelecting;

  PlutoCellPosition _selectingPosition;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    _isSelecting = widget.stateManager.isSelecting;

    _selectingPosition = widget.stateManager.currentSelectingPosition;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (_isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx) ||
        _isSelecting != widget.stateManager.isSelecting ||
        _selectingPosition != widget.stateManager.currentSelectingPosition) {
      setState(() {
        _isCurrentRow = (widget.stateManager.currentRowIdx == widget.rowIdx);
        _isSelecting = widget.stateManager.isSelecting;
        _selectingPosition = widget.stateManager.currentSelectingPosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isCurrentRow &&
                (!_isSelecting && _selectingPosition == null) &&
                widget.stateManager.gridFocusNode.hasFocus
            ? PlutoDefaultSettings.currentRowColor
            : Colors.white,
        border: const Border(
          bottom: const BorderSide(
            width: PlutoDefaultSettings.rowBorderWidth,
            color: PlutoDefaultSettings.rowBorderColor,
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
