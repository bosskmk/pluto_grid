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

  bool _keepFocus;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);

    _isSelecting = widget.stateManager.isSelecting;

    _hasCurrentSelectingPosition =
        widget.stateManager.hasCurrentSelectingPosition;

    _keepFocus = widget.stateManager.keepFocus;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (_isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx) ||
        _isSelectedRow != widget.stateManager.isSelectedRow(widget.row.key) ||
        _isSelecting != widget.stateManager.isSelecting ||
        _hasCurrentSelectingPosition !=
            widget.stateManager.hasCurrentSelectingPosition ||
        _keepFocus != widget.stateManager.keepFocus) {
      setState(() {
        _isCurrentRow = (widget.stateManager.currentRowIdx == widget.rowIdx);
        _isSelectedRow = widget.stateManager.isSelectedRow(widget.row.key);
        _isSelecting = widget.stateManager.isSelecting;
        _hasCurrentSelectingPosition =
            widget.stateManager.hasCurrentSelectingPosition;
        _keepFocus = widget.stateManager.keepFocus;
      });
    }
  }

  Color rowColor() {
    final bool checkCurrentRow =
        _isCurrentRow && (!_isSelecting && !_hasCurrentSelectingPosition);

    final bool checkSelectedRow =
        widget.stateManager.isSelectedRow(widget.row.key);

    if (!checkCurrentRow && !checkSelectedRow) {
      return null;
    }

    if (widget.stateManager.selectingMode.isRow) {
      return checkSelectedRow
          ? widget.stateManager.configuration.activatedColor
          : null;
    }

    if (!widget.stateManager.hasFocus) {
      return null;
    }

    return checkCurrentRow
        ? widget.stateManager.configuration.activatedColor
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: rowColor(),
        border: Border(
          bottom: BorderSide(
            width: PlutoDefaultSettings.rowBorderWidth,
            color: widget.stateManager.configuration.borderColor,
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
