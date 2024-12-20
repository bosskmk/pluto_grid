import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoRightFrozenColumns extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoRightFrozenColumns(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoRightFrozenColumnsState createState() => PlutoRightFrozenColumnsState();
}

class PlutoRightFrozenColumnsState
    extends PlutoStateWithChange<PlutoRightFrozenColumns> {
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
      stateManager.rightFrozenColumns,
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

    bool showRightFrozen =
        stateManager.showFrozenColumn && stateManager.hasRightFrozenColumns;

    final bool showColumnFooter = stateManager.showColumnFooter;

    final headerSpacing = stateManager.style.headerSpacing;

    var decoration = style.rightFrozenDecoration ??
        style.headerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topLeft: showRightFrozen ? Radius.zero : null,
                    bottomLeft: showColumnFooter ? Radius.zero : null,
                    bottomRight: showRightFrozen ? Radius.zero : null,
                  ),
          border: Border.all(
            color: style.gridBorderColor,
            width: PlutoGridSettings.gridBorderWidth,
          ),
        );

    BorderRadiusGeometry borderRadius = BorderRadius.zero;
    List<BoxShadow>? boxShadow;
    Border borderGradient = Border(
      top: BorderSide(
        color: style.gridBorderColor,
        width: PlutoGridSettings.gridBorderWidth,
      ),
    );

    if (stateManager.style.rightFrozenDecoration != null &&
        stateManager.style.rightFrozenDecoration is BoxDecoration) {
      boxShadow =
          (stateManager.style.rightFrozenDecoration as BoxDecoration).boxShadow;
    }

    if (decoration is BoxDecoration) {
      if (decoration.border is Border &&
          boxShadow != null &&
          boxShadow.isNotEmpty) {
        final decorationHeader =
            (stateManager.style.headerDecoration is BoxDecoration?)
                ? stateManager.style.headerDecoration as BoxDecoration?
                : null;

        final border = decorationHeader?.border is Border
            ? decorationHeader?.border as Border
            : null;

        if (decorationHeader != null) {
          borderGradient = Border(
            top: BorderSide(
              color: border?.top.color ?? Colors.transparent,
              width: border?.top.width ?? 0,
            ),
          );
        }
      }

      decoration = decoration.copyWith(
        boxShadow: [],
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topLeft: Radius.zero,
                  bottomLeft: Radius.zero,
                  bottomRight: (headerSpacing == null || headerSpacing <= 0)
                      ? Radius.zero
                      : null,
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
            left: 0,
            child: Container(
              width: boxShadow.first.blurRadius,
              decoration: BoxDecoration(
                border: borderGradient,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    stateManager.style.headerDecoration is BoxDecoration?
                        ? (stateManager.style.headerDecoration
                                    as BoxDecoration?)
                                ?.color ??
                            Colors.transparent
                        : style.gridBorderColor,
                    boxShadow.first.color,
                  ],
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (boxShadow != null && boxShadow.isNotEmpty)
              SizedBox(width: boxShadow.first.blurRadius - 2),
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
                      frozen: PlutoColumnFrozen.end,
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
          ],
        ),
      ],
    );
  }
}
