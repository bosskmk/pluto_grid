import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBodyColumns extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoBodyColumns(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyColumnsState createState() => PlutoBodyColumnsState();
}

class PlutoBodyColumnsState extends PlutoStateWithChange<PlutoBodyColumns> {
  List<PlutoColumn> _columns = [];

  List<PlutoColumnGroupPair> _columnGroups = [];

  bool _showColumnGroups = false;

  bool _showColumnTitle = false;

  int _itemCount = 0;

  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();

    _scroll = widget.stateManager.scroll!.horizontal!.addAndGet();

    updateState();
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  bool allowStream(event) {
    return event is! PlutoSetCurrentCellStreamNotifierEvent;
  }

  @override
  void updateState() {
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      widget.stateManager.showColumnGroups,
    );

    _showColumnTitle = update<bool>(
      _showColumnTitle,
      widget.stateManager.showColumnTitle,
    );

    _columns = update<List<PlutoColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    if (changed && _showColumnGroups == true) {
      _columnGroups = widget.stateManager.separateLinkedGroup(
        columnGroupList: widget.stateManager.refColumnGroups!,
        columns: _columns,
      );
    }

    _itemCount = update<int>(_itemCount, _getItemCount());
  }

  List<PlutoColumn> _getColumns() {
    return widget.stateManager.showFrozenColumn
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups.length : _columns.length;
  }

  Widget _buildColumnGroup(PlutoColumnGroupPair e) {
    return PlutoVisibilityLayoutId(
      id: e.key,
      child: PlutoBaseColumnGroup(
        stateManager: widget.stateManager,
        columnGroup: e,
        depth: widget.stateManager.columnGroupDepth(
          widget.stateManager.refColumnGroups!,
        ),
      ),
    );
  }

  Widget _buildColumn(e) {
    return PlutoVisibilityLayoutId(
      id: e.field,
      child: PlutoBaseColumn(
        stateManager: widget.stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: PlutoVisibilityLayout(
          delegate: MainColumnLayoutDelegate(
            stateManager: widget.stateManager,
            columns: _columns,
            frozen: PlutoColumnFrozen.none,
          ),
          scrollController: _scroll,
          initialViewportDimension: MediaQuery.of(context).size.width,
          children: _showColumnGroups == true
              ? _columnGroups.map(_buildColumnGroup).toList()
              : _columns.map(_buildColumn).toList()),
    );
  }
}

class MainColumnLayoutDelegate extends MultiChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  PlutoColumnFrozen frozen;

  MainColumnLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.frozen,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  double totalColumnsHeight = 0;

  @override
  Size getSize(BoxConstraints constraints) {
    totalColumnsHeight = 0;

    if (stateManager.showColumnGroups) {
      totalColumnsHeight =
          stateManager.columnGroupHeight + stateManager.columnHeight;
    } else {
      totalColumnsHeight = stateManager.columnHeight;
    }

    totalColumnsHeight += stateManager.columnFilterHeight;

    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      totalColumnsHeight,
    );
  }

  @override
  void performLayout(Size size) {
    if (stateManager.showColumnGroups) {
      var separateLinkedGroup = stateManager.separateLinkedGroup(
        columnGroupList: stateManager.columnGroups,
        columns: columns,
      );

      double dx = 0;

      for (PlutoColumnGroupPair pair in separateLinkedGroup) {
        final double width = pair.columns.fold<double>(
          0,
          (previousValue, element) => previousValue + element.width,
        );

        if (hasChild(pair.key)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(pair.key, boxConstraints);

          positionChild(pair.key, Offset(dx, 0));
        }

        dx += width;
      }
    } else {
      double dx = 0;

      for (PlutoColumn col in columns) {
        var width = col.width;

        if (hasChild(col.field)) {
          var boxConstraints = BoxConstraints.tight(
            Size(width, totalColumnsHeight),
          );

          layoutChild(col.field, boxConstraints);

          positionChild(col.field, Offset(dx, 0));
        }

        dx += width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
