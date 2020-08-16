part of pluto_grid;

class RowWidget extends StatelessWidget {
  final PlutoStateManager stateManager;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  RowWidget({
    Key key,
    this.stateManager,
    this.row,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: columns.map((column) {
        return CellWidget(
          stateManager: stateManager,
          cell: row.cells.entries
              .firstWhere((entry) => entry.key == column.field)
              .value,
          width: column.width,
          height: stateManager.style.rowHeight,
        );
      }).toList(growable: false),
    );
  }
}
