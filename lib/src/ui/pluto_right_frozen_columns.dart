part of '../../pluto_grid.dart';

class PlutoRightFrozenColumns extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;

  PlutoRightFrozenColumns(this.stateManager);

  @override
  _PlutoRightFrozenColumnsState createState() =>
      _PlutoRightFrozenColumnsState();
}

abstract class _PlutoRightFrozenColumnsStateWithChange
    extends _PlutoStateWithChange<PlutoRightFrozenColumns> {
  List<PlutoColumn> columns;

  double width;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>>(
        columns,
        widget.stateManager.rightFrozenColumns,
        compare: listEquals,
      );

      width = update<double>(
        width,
        widget.stateManager.rightFrozenColumnsWidth,
      );
    });
  }
}

class _PlutoRightFrozenColumnsState
    extends _PlutoRightFrozenColumnsStateWithChange {
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
