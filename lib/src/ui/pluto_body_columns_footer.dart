import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'ui.dart';

class PlutoBodyColumnsFooter extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyColumnsFooter(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyColumnsFooterState createState() => PlutoBodyColumnsFooterState();
}

class PlutoBodyColumnsFooterState
    extends PlutoStateWithChange<PlutoBodyColumnsFooter> {
  List<PlutoColumn> _columns = [];

  int _itemCount = 0;

  late final ScrollController _scroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _scroll = stateManager.scroll.horizontal!.addAndGet();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _scroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _columns = update<List<PlutoColumn>>(
      _columns,
      _getColumns(),
      compare: listEquals,
    );

    _itemCount = update<int>(_itemCount, _columns.length);
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  PlutoVisibilityLayoutId _makeFooter(PlutoColumn e) {
    return PlutoVisibilityLayoutId(
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

    bool showRightFrozen =
        stateManager.showFrozenColumn && stateManager.hasRightFrozenColumns;

    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.footerDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius:
              style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: showLeftFrozen ? Radius.zero : null,
                    bottomRight: showRightFrozen ? Radius.zero : null,
                  ),
          border: Border.all(
            color: style.gridBorderColor,
            width: PlutoGridSettings.gridBorderWidth,
          ),
        );

    BorderRadiusGeometry borderRadius = BorderRadius.zero;

    if (decoration is BoxDecoration) {
      if (decoration.border is Border) {
        final border = decoration.border as Border;

        decoration = decoration.copyWith(
          border: Border(
            top: border.top,
            bottom: border.bottom,
            left: showLeftFrozen ? BorderSide.none : border.left,
            right: showRightFrozen ? BorderSide.none : border.right,
          ),
        );
      }

      decoration = decoration.copyWith(
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topLeft: showLeftFrozen ||
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  topRight: showRightFrozen ||
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomLeft: showLeftFrozen ? Radius.zero : null,
                  bottomRight: showRightFrozen ? Radius.zero : null,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: stateManager.configuration.style.footerHeight,
            decoration: decoration,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: PlutoVisibilityLayout(
                        delegate: ColumnFooterLayoutDelegate(
                          stateManager: stateManager,
                          columns: _columns,
                          textDirection: stateManager.textDirection,
                        ),
                        scrollController: _scroll,
                        initialViewportDimension:
                            MediaQuery.of(context).size.width,
                        children:
                            _columns.map(_makeFooter).toList(growable: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ColumnFooterLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  final TextDirection textDirection;

  ColumnFooterLayoutDelegate({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
  }) : super(relayout: stateManager.resizingChangeNotifier);

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      columns.fold(
        0,
        (previousValue, element) => previousValue += element.width,
      ),
      stateManager.columnFooterHeight,
    );
  }

  @override
  void performLayout(Size size) {
    final isLTR = textDirection == TextDirection.ltr;
    final items = isLTR ? columns : columns.reversed;
    double dx = 0;

    for (PlutoColumn col in items) {
      var width = col.width;

      if (hasChild(col.field)) {
        var boxConstraints = BoxConstraints.tight(
          Size(width, stateManager.columnFooterHeight),
        );

        layoutChild(col.field, boxConstraints);

        positionChild(col.field, Offset(dx, 0));
      }
      dx += width;
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
