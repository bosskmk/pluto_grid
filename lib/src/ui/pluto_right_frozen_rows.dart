part of '../../pluto_grid.dart';

class PlutoRightFrozenRows extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;

  PlutoRightFrozenRows(this.stateManager);

  @override
  _PlutoRightFrozenRowsState createState() => _PlutoRightFrozenRowsState();
}

abstract class _PlutoRightFrozenRowsStateWithState
    extends _PlutoStateWithChange<PlutoRightFrozenRows> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>>(
        columns,
        widget.stateManager.rightFrozenColumns,
        compare: listEquals,
      );

      rows = update<List<PlutoRow>>(
        rows,
        widget.stateManager._rows,
        compare: listEquals,
        destructureList: true,
      );
    });
  }
}

class _PlutoRightFrozenRowsState extends _PlutoRightFrozenRowsStateWithState {
  ScrollController scroll;

  @override
  void dispose() {
    scroll.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    scroll = widget.stateManager.scroll.vertical.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      scrollDirection: Axis.vertical,
      itemCount: rows.length,
      itemExtent: widget.stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        return PlutoBaseRow(
          key: ValueKey('right_frozen_row_${rows[i]._key}'),
          stateManager: widget.stateManager,
          rowIdx: i,
          row: rows[i],
          columns: columns,
        );
      },
    );
  }
}
