import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRightFrozenColumns extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoRightFrozenColumns(this.stateManager);

  @override
  _PlutoRightFrozenColumnsState createState() =>
      _PlutoRightFrozenColumnsState();
}

abstract class _PlutoRightFrozenColumnsStateWithChange
    extends PlutoStateWithChange<PlutoRightFrozenColumns> {
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
