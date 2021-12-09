import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseColumnGroup extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumnGroup group;
  final List<PlutoColumn> columns;
  final int depth;

  PlutoBaseColumnGroup({
    required this.stateManager,
    required this.group,
    required this.columns,
    required this.depth,
  });

  @override
  _PlutoBaseColumnState createState() => _PlutoBaseColumnState();
}

abstract class _PlutoBaseColumnStateWithChange
    extends PlutoStateWithChange<PlutoBaseColumnGroup> {
  @override
  void onChange() {
    // resetState((update) {
    //   showColumnFilter = update<bool?>(
    //     showColumnFilter,
    //     widget.stateManager.showColumnFilter,
    //   );
    // });
  }
}

class _PlutoBaseColumnState extends _PlutoBaseColumnStateWithChange {
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    final int childrenDepth = widget.group.hasChildren
        ? PlutoColumnGroupHelper.maxDepth(
            columnGroupList: widget.group.children!,
          )
        : 0;

    final double groupTitleHeight = widget.group.hasChildren
        ? (widget.depth - childrenDepth) * PlutoGridSettings.rowHeight
        : widget.depth * PlutoGridSettings.rowHeight;

    final double groupTitleWidth = widget.columns.fold<double>(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    if (widget.group.hasFields) {
      children = widget.columns.map((column) {
        return PlutoBaseColumn(
          stateManager: widget.stateManager,
          column: column,
        );
      }).toList();
    } else {
      final columnGroups = PlutoColumnGroupHelper.separateLinkedGroup(
        columnGroupList: widget.group.children!,
        columns: widget.columns,
      );

      children = columnGroups
          .map((e) => PlutoBaseColumnGroup(
                stateManager: widget.stateManager,
                group: e.group,
                columns: e.columns,
                depth: childrenDepth,
              ))
          .toList();
    }

    return Column(
      children: [
        Container(
          height: groupTitleHeight,
          width: groupTitleWidth,
          child: Text(widget.group.title),
        ),
        Container(
          child: Row(children: children),
        ),
      ],
    );
  }
}
