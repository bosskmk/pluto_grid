import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLeftFrozenColumns extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoLeftFrozenColumns(
    this.stateManager, {
    Key? key,
  }) : super(key: key);

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

      if (changed && showColumnGroups == true) {
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
          return _ColumnOrColumnGroup(
            stateManager: widget.stateManager,
            columnGroup: columnGroups?[i],
            column: columns?[i],
            showColumnGroup: showColumnGroups == true,
          );
        },
      ),
    );
  }
}

class _ColumnOrColumnGroup extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumnGroupPair? columnGroup;

  final PlutoColumn? column;

  final bool showColumnGroup;

  const _ColumnOrColumnGroup({
    required this.stateManager,
    required this.columnGroup,
    required this.column,
    required this.showColumnGroup,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showColumnGroup
        ? PlutoBaseColumnGroup(
            stateManager: stateManager,
            columnGroup: columnGroup!,
            depth: stateManager.columnGroupDepth(
              stateManager.refColumnGroups!,
            ),
          )
        : PlutoBaseColumn(
            stateManager: stateManager,
            column: column!,
          );
  }
}
