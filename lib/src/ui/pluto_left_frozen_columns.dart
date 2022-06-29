import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLeftFrozenColumns extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoLeftFrozenColumns(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoLeftFrozenColumnsState createState() => PlutoLeftFrozenColumnsState();
}

class PlutoLeftFrozenColumnsState
    extends PlutoStateWithChange<PlutoLeftFrozenColumns> {
  List<PlutoColumn> _columns = [];

  List<PlutoColumnGroupPair> _columnGroups = [];

  bool _showColumnGroups = false;

  int _itemCount = 0;

  @override
  void initState() {
    super.initState();

    updateState();
  }

  @override
  void updateState() {
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      widget.stateManager.showColumnGroups,
    );

    _columns = update<List<PlutoColumn>>(
      _columns,
      widget.stateManager.leftFrozenColumns,
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
    return CustomMultiChildLayout(
        delegate: MainColumnLayoutDelegate(
          stateManager: widget.stateManager,
          columns: _columns,
          columnGroups: _columnGroups,
          frozen: PlutoColumnFrozen.left,
        ),
        children: _showColumnGroups == true
            ? _columnGroups.map(_buildColumnGroup).toList()
            : _columns.map(_buildColumn).toList());
  }
}
