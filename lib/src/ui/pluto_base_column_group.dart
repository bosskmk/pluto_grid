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
  }) : super(key: columnGroup.key);

  int get _childrenDepth => columnGroup.group.hasChildren
      ? stateManager.columnGroupDepth(columnGroup.group.children!)
      : 0;

  @override
  Widget build(BuildContext context) {
    return columnGroup.group.expandedColumn == true
        ? _ExpandedColumn(
            stateManager: stateManager,
            column: columnGroup.columns.first,
            height: (depth + 1) * stateManager.columnHeight,
          )
        : Column(
            children: [
              _ColumnGroupTitle(
                stateManager: stateManager,
                columnGroup: columnGroup,
                depth: depth,
                childrenDepth: _childrenDepth,
              ),
              _ColumnGroup(
                stateManager: stateManager,
                columnGroup: columnGroup,
                depth: _childrenDepth,
              ),
            ],
          );
  }
}

class _ExpandedColumn extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final double height;

  const _ExpandedColumn({
    required this.stateManager,
    required this.column,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return PlutoBaseColumn(
      stateManager: stateManager,
      column: column,
      columnTitleHeight: height,
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
        ? (depth - childrenDepth) * stateManager.columnHeight
        : depth * stateManager.columnHeight;

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

  List<PlutoColumnGroupPair> get _separateLinkedGroup =>
      stateManager.separateLinkedGroup(
        columnGroupList: columnGroup.group.children!,
        columns: columnGroup.columns,
      );

  Widget _makeFieldWidget(PlutoColumn column) {
    return PlutoBaseColumn(
      stateManager: stateManager,
      column: column,
    );
  }

  Widget _makeChildWidget(PlutoColumnGroupPair columnGroupPair) {
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
          ? columnGroup.columns.map(_makeFieldWidget).toList()
          : _separateLinkedGroup.map(_makeChildWidget).toList(),
    );
  }
}
