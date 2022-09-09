import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoLeftFrozenColumnsFooter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoLeftFrozenColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoLeftFrozenColumnsFooterState createState() =>
      PlutoLeftFrozenColumnsFooterState();
}

class PlutoLeftFrozenColumnsFooterState
    extends PlutoStateWithChange<PlutoLeftFrozenColumnsFooter> {
  List<PlutoColumn> _columns = [];

  int _itemCount = 0;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState();
  }

  @override
  void updateState() {
    _columns = update<List<PlutoColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _getItemCount());
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.isLTR
        ? stateManager.leftFrozenColumns
        : stateManager.leftFrozenColumns.reversed.toList(growable: false);
  }

  int _getItemCount() {
    return _columns.length;
  }

  Widget _buildColumn(e) {
    return LayoutId(
      id: e.field,
      child: PlutoBaseColumnFooter(
        stateManager: stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
        delegate: ColumnFooterLayoutDelegate(
          stateManager: stateManager,
          columns: _columns,
        ),
        children: _columns.map(_buildColumn).toList());
  }
}
