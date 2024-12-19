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

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _columns = update<List<PlutoColumn>>(
      _columns,
      stateManager.leftFrozenColumns,
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);
  }

  Widget _makeColumn(PlutoColumn e) {
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
    final style = stateManager.configuration.style;

    bool showLeftFrozen =
        stateManager.showFrozenColumn && stateManager.hasLeftFrozenColumns;

    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.leftFrozenDecoration ??
        style.footerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomRight: showLeftFrozen ? Radius.zero : null,
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
                  topLeft: (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  topRight: Radius.zero,
                  bottomRight: showLeftFrozen ? Radius.zero : null,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Container(
      height: stateManager.configuration.style.footerHeight,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CustomMultiChildLayout(
          delegate: ColumnFooterLayoutDelegate(
            stateManager: stateManager,
            columns: _columns,
            textDirection: stateManager.textDirection,
          ),
          children: _columns.map(_makeColumn).toList(growable: false),
        ),
      ),
    );
  }
}
