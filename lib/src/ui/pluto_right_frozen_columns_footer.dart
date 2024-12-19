import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoRightFrozenColumnsFooter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoRightFrozenColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoRightFrozenColumnsFooterState createState() =>
      PlutoRightFrozenColumnsFooterState();
}

class PlutoRightFrozenColumnsFooterState
    extends PlutoStateWithChange<PlutoRightFrozenColumnsFooter> {
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
      stateManager.rightFrozenColumns,
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

    bool showRightFrozen =
        stateManager.showFrozenColumn && stateManager.hasRightFrozenColumns;

    final bool showColumnFooter = stateManager.showColumnFooter;

    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.footerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: showRightFrozen ? Radius.zero : null,
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
                  topLeft: Radius.zero,
                  topRight: showColumnFooter &&
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomLeft: showRightFrozen ? Radius.zero : null,
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
