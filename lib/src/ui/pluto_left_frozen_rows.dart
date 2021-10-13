import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLeftFrozenRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoLeftFrozenRows(this.stateManager);

  @override
  _PlutoLeftFrozenRowsState createState() => _PlutoLeftFrozenRowsState();
}

abstract class _PlutoLeftFrozenRowsStateWithState
    extends PlutoStateWithChange<PlutoLeftFrozenRows> {
  List<PlutoColumn>? columns;

  List<PlutoRow?>? rows;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>?>(
        columns,
        widget.stateManager.leftFrozenColumns,
        compare: listEquals,
      );

      rows = update<List<PlutoRow?>?>(
        rows,
        widget.stateManager.refRows,
        compare: listEquals,
        destructureList: true,
      );
    });
  }
}

class _PlutoLeftFrozenRowsState extends _PlutoLeftFrozenRowsStateWithState {
  ScrollController? scroll;

  @override
  void dispose() {
    scroll!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    scroll = widget.stateManager.scroll!.vertical!.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: rows!.length,
      itemExtent: widget.stateManager.optimiseRowHeight ?? true ? widget.stateManager.rowTotalHeight : null,
      itemBuilder: (ctx, i) {
        return PlutoBaseRow(
          key: ValueKey('left_frozen_row_${rows![i]!.key}'),
          stateManager: widget.stateManager,
          rowIdx: i,
          row: rows![i],
          columns: columns,
        );
      },
    );
  }
}
