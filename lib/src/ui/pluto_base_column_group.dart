import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseColumnGroup extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumnGroupPair columnGroup;
  final int depth;

  PlutoBaseColumnGroup({
    required this.stateManager,
    required this.columnGroup,
    required this.depth,
  });

  int get childrenDepth => columnGroup.group.hasChildren
      ? stateManager.columnGroupDepth(columnGroup.group.children!)
      : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ColumnGroupTitle(
          stateManager: stateManager,
          columnGroup: columnGroup,
          depth: depth,
          childrenDepth: childrenDepth,
        ),
        _ColumnGroup(
          stateManager: stateManager,
          columnGroup: columnGroup,
          depth: childrenDepth,
        ),
      ],
    );
  }
}

class _ColumnGroupTitle extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumnGroupPair columnGroup;

  final int depth;

  final int childrenDepth;

  const _ColumnGroupTitle({
    required this.stateManager,
    required this.columnGroup,
    required this.depth,
    required this.childrenDepth,
  });

  double get _padding =>
      columnGroup.group.titlePadding ??
      stateManager.configuration!.defaultColumnTitlePadding;

  String? get _title =>
      columnGroup.group.titleSpan == null ? columnGroup.group.title : null;

  List<InlineSpan>? get _children => [
        if (columnGroup.group.titleSpan != null) columnGroup.group.titleSpan!,
      ];

  @override
  Widget build(BuildContext context) {
    final double groupTitleHeight = columnGroup.group.hasChildren
        ? (depth - childrenDepth) * PlutoGridSettings.rowHeight
        : depth * PlutoGridSettings.rowHeight;

    final double groupTitleWidth = columnGroup.columns.fold<double>(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    return Container(
      height: groupTitleHeight,
      width: groupTitleWidth,
      padding: EdgeInsets.symmetric(horizontal: _padding),
      decoration: BoxDecoration(
        border: Border(
          right: stateManager.configuration!.enableColumnBorder
              ? BorderSide(
                  color: stateManager.configuration!.borderColor,
                  width: 1.0,
                )
              : BorderSide.none,
          bottom: BorderSide(
            color: stateManager.configuration!.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: groupTitleWidth,
          child: Text.rich(
            TextSpan(
              text: _title,
              children: _children,
            ),
            style: stateManager.configuration!.columnTextStyle,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            textAlign: columnGroup.group.titleTextAlign.value,
          ),
        ),
      ),
    );
  }
}

class _ColumnGroup extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumnGroupPair columnGroup;

  final int depth;

  const _ColumnGroup({
    required this.stateManager,
    required this.columnGroup,
    required this.depth,
  });

  List<PlutoColumnGroupPair> get separateLinkedGroup =>
      stateManager.separateLinkedGroup(
        columnGroupList: columnGroup.group.children!,
        columns: columnGroup.columns,
      );

  Widget makeFieldWidget(PlutoColumn column) {
    return PlutoBaseColumn(
      stateManager: stateManager,
      column: column,
    );
  }

  Widget makeChildWidget(PlutoColumnGroupPair columnGroupPair) {
    return PlutoBaseColumnGroup(
      stateManager: stateManager,
      columnGroup: columnGroupPair,
      depth: depth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: columnGroup.group.hasFields
          ? columnGroup.columns.map(makeFieldWidget).toList()
          : separateLinkedGroup.map(makeChildWidget).toList(),
    );
  }
}
