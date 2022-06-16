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
  PlutoBodyColumnsState createState() => PlutoBodyColumnsState();
}

abstract class _PlutoBodyColumnsStateWithChange
    extends PlutoStateWithChange<PlutoBodyColumns> {
  ScrollController? _scroll;

  bool? _showColumnGroups;

  bool? _showColumnTitle;

  List<PlutoColumn>? _columns;

  List<PlutoColumnGroupPair>? _columnGroups;

  int? _itemCount;

  @override
  bool allowStream(event) {
    return event is! PlutoSetCurrentCellStreamNotifierEvent;
  }

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
  void onChange(event) {
    resetState((update) {
      _showColumnGroups = update<bool?>(
        _showColumnGroups,
        widget.stateManager.showColumnGroups,
      );

      _showColumnTitle = update<bool?>(
        _showColumnTitle,
        widget.stateManager.showColumnTitle,
      );

      _columns = update<List<PlutoColumn>?>(
        _columns,
        _getColumns(),
        compare: listEquals,
      );

      if (changed) {
        widget.stateManager.updateColumnStartPosition();
      }

      if (changed && _showColumnGroups == true) {
        _columnGroups = widget.stateManager.separateLinkedGroup(
          columnGroupList: widget.stateManager.refColumnGroups!,
          columns: _columns!,
        );
      }

      _itemCount = update<int?>(_itemCount, _getItemCount());
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
}

class PlutoBodyColumnsState extends _PlutoBodyColumnsStateWithChange {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: PlutoVisibilityLayout(
          delegate: MainColumnLayoutDelegate(widget.stateManager, _columns!),
          stateManager: widget.stateManager,
          children: _showColumnGroups == true
              ? _columnGroups!
                  .map((PlutoColumnGroupPair e) => PlutoVisibilityLayoutId(
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
                  .map((e) => PlutoVisibilityLayoutId(
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

    final double width =
        columns.isEmpty ? 0 : columns.last.startPosition + columns.last.width;

    return Size(
      width,
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

      for (PlutoColumnGroupPair pair in separateLinkedGroup) {
        if (!hasChild(pair.key)) continue;

        final double width = pair.lastColumn.startPosition +
            pair.lastColumn.width -
            pair.firstColumn.startPosition;

        var boxConstraints = BoxConstraints.tight(
          Size(width, totalColumnsHeight),
        );

        layoutChild(pair.key, boxConstraints);
        positionChild(pair.key, Offset(pair.firstColumn.startPosition, 0));
      }
    } else {
      for (PlutoColumn col in columns) {
        if (!hasChild(col.field)) continue;

        var width = col.width;

        var boxConstraints = BoxConstraints.tight(
          Size(width, totalColumnsHeight),
        );

        layoutChild(col.field, boxConstraints);
        positionChild(col.field, Offset(col.startPosition, 0));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
