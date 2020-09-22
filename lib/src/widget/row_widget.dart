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

  bool _hasCurrentSelectingPosition;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);

    _isSelecting = widget.stateManager.isSelecting;

    _hasCurrentSelectingPosition =
        widget.stateManager.hasCurrentSelectingPosition;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (_isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx) ||
        _isSelectedRow != widget.stateManager.isSelectedRow(widget.row.key) ||
        _isSelecting != widget.stateManager.isSelecting ||
        _hasCurrentSelectingPosition !=
            widget.stateManager.hasCurrentSelectingPosition) {
      setState(() {
        _isCurrentRow = (widget.stateManager.currentRowIdx == widget.rowIdx);
        _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);
        _isSelecting = widget.stateManager.isSelecting;
        _hasCurrentSelectingPosition =
            widget.stateManager.hasCurrentSelectingPosition;
      });
    }
  }

  Color rowColor() {
    if (!widget.stateManager.gridFocusNode.hasFocus) {
      return Colors.white;
    }

    final bool checkCurrentRow =
        _isCurrentRow && (!_isSelecting && !_hasCurrentSelectingPosition);

    final bool checkSelectedRow =
        widget.stateManager.isSelectedRow(widget.row.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return Colors.white;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow
          ? PlutoDefaultSettings.currentRowColor
          : Colors.white;
    }

    return checkCurrentRow
        ? PlutoDefaultSettings.currentRowColor
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: rowColor(),
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
