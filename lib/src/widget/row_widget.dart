part of pluto_grid;

class RowWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoRow row;
  final List<int> columnIndexes;

  RowWidget({
    this.stateManager,
    this.row,
    this.columnIndexes,
  });

  @override
  _RowWidgetState createState() => _RowWidgetState();
}

class _RowWidgetState extends State<RowWidget> {
  @override
  Widget build(BuildContext context) {
//    return Row(
//      children: widget.row.cells.entries
//          .where((entry) => widget.columnIndexes.indexOf(entry.key) > -1)
//          .map((entry) {
//        return CellWidget(
//          stateManager: widget.stateManager,
//          cell: entry.value,
//          width: widget.stateManager.columns[entry.key].width,
//          height: widget.stateManager.style.rowHeight,
//        );
//      }).toList(growable: false),
//    );
    return Row(
      children: widget.columnIndexes.map((columnIdx) {
        return CellWidget(
          stateManager: widget.stateManager,
          cell: widget.row.cells.entries
              .firstWhere((entry) =>
                  entry.key == widget.stateManager.columns[columnIdx].field)
              .value,
          width: widget.stateManager.columns[columnIdx].width,
          height: widget.stateManager.style.rowHeight,
        );
      }).toList(growable: false),
    );
  }
}
