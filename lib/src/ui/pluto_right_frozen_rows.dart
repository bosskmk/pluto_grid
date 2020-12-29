import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRightFrozenRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoRightFrozenRows(this.stateManager);

  @override
  _PlutoRightFrozenRowsState createState() => _PlutoRightFrozenRowsState();
}

abstract class _PlutoRightFrozenRowsStateWithState
    extends PlutoStateWithChange<PlutoRightFrozenRows> {
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
        widget.stateManager.refRows,
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
      physics: const ClampingScrollPhysics(),
      itemCount: rows.length,
      itemExtent: widget.stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        return PlutoBaseRow(
          key: ValueKey('right_frozen_row_${rows[i].key}'),
          stateManager: widget.stateManager,
          rowIdx: i,
          row: rows[i],
          columns: columns,
        );
      },
    );
  }
}
