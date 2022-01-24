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
    return SizedBox(
      width: _width,
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: _itemCount,
        itemBuilder: (ctx, i) {
          return _showColumnGroups == true
              ? PlutoBaseColumnGroup(
                  stateManager: widget.stateManager,
                  columnGroup: _columnGroups![i],
                  depth: widget.stateManager.columnGroupDepth(
                    widget.stateManager.refColumnGroups!,
                  ),
                )
              : PlutoBaseColumn(
                  stateManager: widget.stateManager,
                  column: _columns![i],
                );
        },
      ),
    );
  }
}
