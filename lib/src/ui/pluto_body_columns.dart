import 'package:flutter/cupertino.dart';
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
  bool? _showColumnGroups;

  List<PlutoColumn>? _columns;

  List<PlutoColumnGroupPair>? _columnGroups;

  int? _itemCount;

  double? _width;

  @override
  void onChange() {
    resetState((update) {
      _showColumnGroups = update<bool?>(
        _showColumnGroups,
        widget.stateManager.showColumnGroups,
      );

      _columns = update<List<PlutoColumn>?>(
        _columns,
        _getColumns(),
        compare: listEquals,
      );

      if (changed && _showColumnGroups == true) {
        _columnGroups = widget.stateManager.separateLinkedGroup(
          columnGroupList: widget.stateManager.refColumnGroups!,
          columns: _columns!,
        );
      }

      _itemCount = update<int?>(_itemCount, _getItemCount());

      _width = update<double?>(_width, _getWidth());
    });
  }

  List<PlutoColumn> _getColumns() {
    return widget.stateManager.showFrozenColumn
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups!.length : _columns!.length;
  }

  double _getWidth() {
    return widget.stateManager.showFrozenColumn
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }
}

class _PlutoBodyColumnsState extends _PlutoBodyColumnsStateWithChange {
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scroll = widget.stateManager.scroll!.horizontal!.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: CustomMultiChildLayout(
          delegate: MainColumnLayoutDelegate(widget.stateManager, _columns!),
          children: _showColumnGroups == true
              ? _columnGroups!
                  .map((PlutoColumnGroupPair e) => LayoutId(
                        id: e.key,
                        child: PlutoBaseColumnGroup(
                          stateManager: widget.stateManager,
                          columnGroup: e,
                          depth: widget.stateManager.columnGroupDepth(
                            widget.stateManager.refColumnGroups!,
                          ),
                        ),
                      ))
                  .toList()
              : _columns!
                  .map((e) => LayoutId(
                        id: e.field,
                        child: PlutoBaseColumn(
                          stateManager: widget.stateManager,
                          column: e,
                        ),
                      ))
                  .toList()),
    );
  }
}

class MainColumnLayoutDelegate extends MultiChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  MainColumnLayoutDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

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
            0, (previousValue, element) => previousValue += element.width),
        totalColumnsHeight);
  }

  @override
  void performLayout(Size size) {
    if (stateManager.showColumnGroups) {
      var separateLinkedGroup = stateManager.separateLinkedGroup(
          columnGroupList: stateManager.columnGroups, columns: columns);
      double dx = 0;
      for (PlutoColumnGroupPair pair in separateLinkedGroup) {
        if (!hasChild(pair.key)) continue;
        final double width = pair.columns.fold<double>(
            0, (previousValue, element) => previousValue + element.width);
        var boxConstraints =
            BoxConstraints.tight(Size(width, totalColumnsHeight));
        layoutChild(pair.key, boxConstraints);
        positionChild(pair.key, Offset(dx, 0));
        dx += width;
      }
    } else {
      double dx = 0;
      for (PlutoColumn col in columns) {
        var width = col.width;
        var boxConstraints =
            BoxConstraints.tight(Size(width, totalColumnsHeight));
        layoutChild(col.field, boxConstraints);
        positionChild(col.field, Offset(dx, 0));
        dx += width;
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
