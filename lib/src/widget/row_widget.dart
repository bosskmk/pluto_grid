part of pluto_grid;

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
  bool isCurrentRow;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    isCurrentRow = widget.stateManager.currentRowIdx == widget.rowIdx;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (isCurrentRow != (widget.stateManager.currentRowIdx == widget.rowIdx)) {
      setState(() {
        isCurrentRow = (widget.stateManager.currentRowIdx == widget.rowIdx);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentRow
            ? Color.fromRGBO(235, 235, 235, 100)
            : Colors.white,
        border: const Border(
          bottom: const BorderSide(
            width: PlutoDefaultSettings.rowBorderWidth,
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: widget.columns.map((column) {
          return CellWidget(
            stateManager: widget.stateManager,
            cell: widget.row.cells.entries
                .firstWhere((entry) => entry.key == column.field)
                .value,
            width: column.width,
            height: widget.stateManager.style.rowHeight,
            column: column,
            rowIdx: widget.rowIdx,
          );
        }).toList(growable: false),
      ),
    );
  }
}
