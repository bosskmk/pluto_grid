import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBodyColumns extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoBodyColumns(this.stateManager);

  @override
  _PlutoBodyColumnsState createState() => _PlutoBodyColumnsState();
}

abstract class _PlutoBodyColumnsStateWithChange
    extends PlutoStateWithChange<PlutoBodyColumns> {
  List<PlutoColumn>? columns;

  List<PlutoColumnGroupPair>? columnGroups;

  int? itemCount;

  double? width;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>?>(
        columns,
        _getColumns(),
        compare: listEquals,
      );

      columnGroups = update<List<PlutoColumnGroupPair>?>(
        columnGroups,
        PlutoColumnGroupHelper.separateLinkedGroup(
          columnGroupList: widget.stateManager.refColumnGroups!,
          columns: columns!,
        ),
        compare: listEquals,
      );

      itemCount = update<int?>(itemCount, _getItemCount());

      width = update<double?>(width, _getWidth());
    });
  }

  List<PlutoColumn> _getColumns() {
    return widget.stateManager.showFrozenColumn!
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  int _getItemCount() {
    return widget.stateManager.hasColumnGroups
        ? columnGroups!.length
        : columns!.length;
  }

  double _getWidth() {
    return widget.stateManager.showFrozenColumn!
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }
}

class _PlutoBodyColumnsState extends _PlutoBodyColumnsStateWithChange {
  ScrollController? scroll;

  @override
  void dispose() {
    scroll!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    scroll = widget.stateManager.scroll!.horizontal!.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView.builder(
        controller: scroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (ctx, i) {
          return widget.stateManager.hasColumnGroups
              ? PlutoBaseColumnGroup(
                  stateManager: widget.stateManager,
                  group: columnGroups![i].group,
                  columns: columnGroups![i].columns,
                  depth: PlutoColumnGroupHelper.maxDepth(
                    columnGroupList: widget.stateManager.refColumnGroups!,
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
