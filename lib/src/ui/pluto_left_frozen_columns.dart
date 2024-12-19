import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoLeftFrozenColumns extends PlutoStatefulWidget {
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
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _showColumnGroups = update<bool>(
      _showColumnGroups,
      stateManager.showColumnGroups,
    );

    _columns = update<List<PlutoColumn>>(
      _columns,
      stateManager.leftFrozenColumns,
      compare: listEquals,
    );

    _columnGroups = update<List<PlutoColumnGroupPair>>(
      _columnGroups,
      stateManager.separateLinkedGroup(
        columnGroupList: stateManager.refColumnGroups,
        columns: _columns,
      ),
    );

    _itemCount = update<int>(_itemCount, _getItemCount());
  }

  int _getItemCount() {
    return _showColumnGroups == true ? _columnGroups.length : _columns.length;
  }

  Widget _makeColumnGroup(PlutoColumnGroupPair e) {
    return LayoutId(
      id: e.key,
      child: PlutoBaseColumnGroup(
        stateManager: stateManager,
        columnGroup: e,
        depth: stateManager.columnGroupDepth(stateManager.refColumnGroups),
      ),
    );
  }

  Widget _makeColumn(PlutoColumn e) {
    return LayoutId(
      id: e.field,
      child: PlutoBaseColumn(
        stateManager: stateManager,
        column: e,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.configuration.style;

    bool showLeftFrozen =
        stateManager.showFrozenColumn && stateManager.hasLeftFrozenColumns;

    final headerSpacing = stateManager.style.headerSpacing;

    var decoration = style.headerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topRight: showLeftFrozen ? Radius.zero : null,
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
          border: Border.all(
            color: style.gridBorderColor,
            width: PlutoGridSettings.gridBorderWidth,
          ),
        );

    BorderRadiusGeometry borderRadius = BorderRadius.zero;

    if (decoration is BoxDecoration) {
      decoration = decoration.copyWith(
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topRight: Radius.zero,
                  bottomLeft: (headerSpacing == null || headerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomRight: Radius.zero,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomMultiChildLayout(
          delegate: MainColumnLayoutDelegate(
            stateManager: stateManager,
            columns: _columns,
            columnGroups: _columnGroups,
            frozen: PlutoColumnFrozen.start,
            textDirection: stateManager.textDirection,
          ),
          children: _showColumnGroups == true
              ? _columnGroups.map(_makeColumnGroup).toList(growable: false)
              : _columns.map(_makeColumn).toList(growable: false),
        ),
      ),
    );
  }
}
