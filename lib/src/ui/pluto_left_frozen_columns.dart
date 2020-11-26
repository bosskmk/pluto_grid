part of '../../pluto_grid.dart';

class PlutoLeftFrozenColumns extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;

  PlutoLeftFrozenColumns(this.stateManager);

  @override
  _PlutoLeftFrozenColumnsState createState() => _PlutoLeftFrozenColumnsState();
}

abstract class _PlutoLeftFrozenColumnsStateWithChange
    extends _PlutoStateWithChange<PlutoLeftFrozenColumns> {
  List<PlutoColumn> columns;

  double width;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>>(
        columns,
        widget.stateManager.leftFrozenColumns,
        compare: listEquals,
      );

      width = update<double>(width, widget.stateManager.leftFrozenColumnsWidth);
    });
  }
}

class _PlutoLeftFrozenColumnsState
    extends _PlutoLeftFrozenColumnsStateWithChange {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: columns.length,
        itemBuilder: (ctx, i) {
          return PlutoBaseColumn(
            stateManager: widget.stateManager,
            column: columns[i],
          );
        },
      ),
    );
  }
}
