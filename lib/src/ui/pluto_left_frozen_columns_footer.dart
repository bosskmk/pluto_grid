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
    List<BoxShadow>? boxShadow;
    Border borderGradient = Border(
      bottom: BorderSide(
        color: style.gridBorderColor,
        width: PlutoGridSettings.gridBorderWidth,
      ),
    );

    if (stateManager.style.leftFrozenDecoration != null &&
        stateManager.style.leftFrozenDecoration is BoxDecoration) {
      boxShadow =
          (stateManager.style.leftFrozenDecoration as BoxDecoration).boxShadow;
    }

    if (decoration is BoxDecoration) {
      if (decoration.border is Border &&
          boxShadow != null &&
          boxShadow.isNotEmpty) {
        final decorationFooter =
            (stateManager.style.footerDecoration is BoxDecoration?)
                ? stateManager.style.footerDecoration as BoxDecoration?
                : null;

        final border = decorationFooter?.border is Border
            ? decorationFooter?.border as Border
            : null;

        if (decorationFooter != null) {
          borderGradient = Border(
            bottom: BorderSide(
              color: border?.bottom.color ?? Colors.transparent,
              width: border?.bottom.width ?? 0,
            ),
          );
        }
      }

      decoration = decoration.copyWith(
        boxShadow: [],
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
                color: stateManager.style.footerDecoration is BoxDecoration?
                    ? (stateManager.style.footerDecoration as BoxDecoration?)
                        ?.color
                    : style.gridBorderColor,
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
            Container(
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
            ),
            if (boxShadow != null && boxShadow.isNotEmpty)
              SizedBox(width: boxShadow.first.blurRadius - 2),
          ],
        ),
      ],
    );
  }
}
