import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLeftFrozenRows extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoLeftFrozenRows(
    this.stateManager, {
    Key? key,
  }) : super(key: key);

  @override
  PlutoLeftFrozenRowsState createState() => PlutoLeftFrozenRowsState();
}

abstract class _PlutoLeftFrozenRowsStateWithState
    extends PlutoStateWithChange<PlutoLeftFrozenRows> {
  List<PlutoColumn>? _columns;

  List<PlutoRow?>? _rows;

  @override
  bool allowStream(event) {
    return !(event is PlutoSetCurrentCellStreamNotifierEvent ||
        event is PlutoVisibilityColumnStreamNotifierEvent);
  }

  @override
  void onChange(event) {
    resetState((update) {
      _columns = update<List<PlutoColumn>?>(
        _columns,
        widget.stateManager.leftFrozenColumns,
        compare: listEquals,
      );

      _rows = [
        ...update<List<PlutoRow?>?>(
          _rows,
          widget.stateManager.refRows,
          compare: listEquals,
        )!
      ];
    });
  }
}

class PlutoLeftFrozenRowsState extends _PlutoLeftFrozenRowsStateWithState {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scroll = widget.stateManager.scroll!.vertical!.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scroll,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: _rows!.length,
      itemExtent: widget.stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        return PlutoBaseRow(
          key: ValueKey('left_frozen_row_${_rows![i]!.key}'),
          rowIdx: i,
          row: _rows![i]!,
          columns: _columns!,
        );
      },
    );
  }
}
