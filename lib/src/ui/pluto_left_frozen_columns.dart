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

    var decoration = style.leftFrozenDecoration ??
        style.headerDecoration ??
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
    Border borderGradient = const Border();
    List<BoxShadow>? boxShadow;

    if (stateManager.style.leftFrozenDecoration != null &&
        stateManager.style.leftFrozenDecoration is BoxDecoration) {
      boxShadow =
          (stateManager.style.leftFrozenDecoration as BoxDecoration).boxShadow;
    }

    if (decoration is BoxDecoration) {
      if (decoration.border is Border &&
          boxShadow != null &&
          boxShadow.isNotEmpty) {
        final border = (decoration.border as Border);

        borderGradient = Border(
          top: BorderSide(
            color: border.top.color,
            width: border.top.width,
          ),
          bottom: BorderSide(
            color: border.bottom.color,
            width: border.bottom.width,
          ),
        );
      }

      decoration = decoration.copyWith(
        boxShadow: [],
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

    return Stack(
      children: [
        if (boxShadow != null && boxShadow.isNotEmpty)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              width: boxShadow.first.blurRadius,
              decoration: BoxDecoration(
                border: borderGradient,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    boxShadow.first.color,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
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
                        ? _columnGroups
                            .map(_makeColumnGroup)
                            .toList(growable: false)
                        : _columns.map(_makeColumn).toList(growable: false),
                  ),
                ),
              ),
            ),
            if (boxShadow != null && boxShadow.isNotEmpty)
              SizedBox(width: boxShadow.first.blurRadius - 2),
          ],
        ),
      ],
    );
  }
}
