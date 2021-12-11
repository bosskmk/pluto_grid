import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLeftFrozenColumns extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoLeftFrozenColumns(this.stateManager);

  @override
  _PlutoLeftFrozenColumnsState createState() => _PlutoLeftFrozenColumnsState();
}

abstract class _PlutoLeftFrozenColumnsStateWithChange
    extends PlutoStateWithChange<PlutoLeftFrozenColumns> {
  bool? showColumnGroups;

  List<PlutoColumn>? columns;

  List<PlutoColumnGroupPair>? columnGroups;

  int? itemCount;

  double? width;

  @override
  void onChange() {
    resetState((update) {
      showColumnGroups = update<bool?>(
        showColumnGroups,
        widget.stateManager.showColumnGroups,
      );

      columns = update<List<PlutoColumn>?>(
        columns,
        widget.stateManager.leftFrozenColumns,
        compare: listEquals,
      );

      if (changed) {
        columnGroups = widget.stateManager.separateLinkedGroup(
          columnGroupList: widget.stateManager.refColumnGroups!,
          columns: columns!,
        );
      }

      itemCount = update<int?>(itemCount, _getItemCount());

      width =
          update<double?>(width, widget.stateManager.leftFrozenColumnsWidth);
    });
  }

  int _getItemCount() {
    return showColumnGroups == true ? columnGroups!.length : columns!.length;
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
        itemCount: itemCount,
        itemBuilder: (ctx, i) {
          return showColumnGroups == true
              ? PlutoBaseColumnGroup(
                  stateManager: widget.stateManager,
                  columnGroup: columnGroups![i],
                  depth: widget.stateManager.columnGroupDepth(
                    widget.stateManager.refColumnGroups!,
                  ),
                )
              : PlutoBaseColumn(
                  stateManager: widget.stateManager,
                  column: columns![i],
                );
        },
      ),
    );
  }
}
