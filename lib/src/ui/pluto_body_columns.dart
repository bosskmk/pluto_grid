import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBodyColumns extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoBodyColumns(
    this.stateManager, {
    Key? key,
  }) : super(key: key);

  @override
  _PlutoBodyColumnsState createState() => _PlutoBodyColumnsState();
}

abstract class _PlutoBodyColumnsStateWithChange
    extends PlutoStateWithChange<PlutoBodyColumns> {
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
        _getColumns(),
        compare: listEquals,
      );

      if (changed && showColumnGroups == true) {
        columnGroups = widget.stateManager.separateLinkedGroup(
          columnGroupList: widget.stateManager.refColumnGroups!,
          columns: columns!,
        );
      }

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
    return showColumnGroups == true ? columnGroups!.length : columns!.length;
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
