import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBaseColumnGroup extends StatelessWidget
    implements PlutoVisibilityLayoutChild {
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
  double get width => columnGroup.width;

  @override
  double get startPosition => columnGroup.startPosition;

  @override
  bool get keepAlive => false;

  @override
  Widget build(BuildContext context) {
    if (columnGroup.group.expandedColumn == true) {
      return _ExpandedColumn(
        stateManager: stateManager,
        column: columnGroup.columns.first,
        height: ((depth + 1) * stateManager.columnHeight),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

  EdgeInsets get _padding =>
      columnGroup.group.titlePadding ??
      stateManager.configuration!.style.defaultColumnTitlePadding;

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

    final style = stateManager.style;

    return Container(
      height: groupTitleHeight,
      padding: _padding,
      decoration: BoxDecoration(
        color: columnGroup.group.backgroundColor,
        border: BorderDirectional(
          end: style.enableColumnBorderVertical
              ? BorderSide(
                  color: style.borderColor,
                  width: 1.0,
                )
              : BorderSide.none,
          bottom: style.enableColumnBorderHorizontal
              ? BorderSide(
                  color: style.borderColor,
                  width: 1.0,
                )
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: _title,
            children: _children,
          ),
          style: style.columnTextStyle,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          maxLines: 1,
          textAlign: columnGroup.group.titleTextAlign.value,
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
    return LayoutId(
      id: column.field,
      child: PlutoBaseColumn(
        stateManager: stateManager,
        column: column,
      ),
    );
  }

  Widget _makeChildWidget(PlutoColumnGroupPair columnGroupPair) {
    return LayoutId(
      id: columnGroupPair.key,
      child: PlutoBaseColumnGroup(
        stateManager: stateManager,
        columnGroup: columnGroupPair,
        depth: depth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (columnGroup.group.hasFields) {
      return CustomMultiChildLayout(
        delegate: ColumnsLayout(stateManager, columnGroup.columns),
        children: columnGroup.columns.map(_makeFieldWidget).toList(),
      );
    }

    return CustomMultiChildLayout(
      delegate: ColumnGroupLayout(stateManager, _separateLinkedGroup, depth),
      children: _separateLinkedGroup.map(_makeChildWidget).toList(),
    );
  }
}

class ColumnGroupLayout extends MultiChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumnGroupPair> separateLinkedGroups;

  late double totalHeightOfGroup;

  int depth;

  ColumnGroupLayout(this.stateManager, this.separateLinkedGroups, this.depth)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    totalHeightOfGroup = (depth + 1) * stateManager.columnHeight;

    totalHeightOfGroup += stateManager.columnFilterHeight;

    var totalWidthOfGroup = separateLinkedGroups.fold<double>(
      0,
      (previousValue, element) =>
          previousValue +
          element.columns.fold(
            0,
            (previousValue, element) => previousValue + element.width,
          ),
    );

    return Size(totalWidthOfGroup, totalHeightOfGroup);
  }

  @override
  void performLayout(Size size) {
    double dx = 0;

    for (PlutoColumnGroupPair pair in separateLinkedGroups) {
      final double width = pair.columns.fold<double>(
        0,
        (previousValue, element) => previousValue + element.width,
      );

      var boxConstraints = BoxConstraints.tight(
        Size(width, totalHeightOfGroup),
      );

      layoutChild(pair.key, boxConstraints);

      positionChild(pair.key, Offset(dx, 0));

      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class ColumnsLayout extends MultiChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ColumnsLayout(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  double totalColumnsHeight = 0;

  @override
  Size getSize(BoxConstraints constraints) {
    totalColumnsHeight = 0;

    totalColumnsHeight = stateManager.columnHeight;

    totalColumnsHeight += stateManager.columnFilterHeight;

    double width = columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    return Size(width, totalColumnsHeight);
  }

  @override
  void performLayout(Size size) {
    double dx = 0;

    for (PlutoColumn col in columns) {
      final double width = col.width;

      var boxConstraints = BoxConstraints.tight(
        Size(width, totalColumnsHeight),
      );

      layoutChild(col.field, boxConstraints);

      positionChild(col.field, Offset(dx, 0));

      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
