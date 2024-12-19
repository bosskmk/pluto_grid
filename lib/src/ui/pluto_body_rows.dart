import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class PlutoBodyRows extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoBodyRows(
    this.stateManager, {
    super.key,
  });

  @override
  PlutoBodyRowsState createState() => PlutoBodyRowsState();
}

class PlutoBodyRowsState extends PlutoStateWithChange<PlutoBodyRows> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _verticalScroll;

  late final ScrollController _horizontalScroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();

    stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();

    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    _horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    _rows = stateManager.refRows;
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  @override
  Widget build(BuildContext context) {
    final scrollbarConfig = stateManager.configuration.scrollbar;

    final style = stateManager.configuration.style;

    bool showLeftFrozen =
        stateManager.showFrozenColumn && stateManager.hasLeftFrozenColumns;

    bool showRightFrozen =
        stateManager.showFrozenColumn && stateManager.hasRightFrozenColumns;

    final bool showColumnFooter = stateManager.showColumnFooter;

    final headerSpacing = stateManager.style.headerSpacing;
    final footerSpacing = stateManager.style.footerSpacing;

    var decoration = style.contentDecoration ??
        BoxDecoration(
          color: style.gridBackgroundColor,
          borderRadius: !showColumnFooter
              ? style.gridBorderRadius.resolve(TextDirection.ltr).copyWith(
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  )
              : null,
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
            top: (headerSpacing == null || headerSpacing <= 0)
                ? BorderSide.none
                : border.top,
<<<<<<< HEAD
            bottom: showColumnFooter &&
                    (footerSpacing == null || footerSpacing <= 0)
=======
            bottom: (footerSpacing == null || footerSpacing <= 0)
>>>>>>> b1df73a4047e89aeec13c320739024a8bbf58101
                ? BorderSide.none
                : border.bottom,
            left: showLeftFrozen ? BorderSide.none : border.left,
            right: showRightFrozen ? BorderSide.none : border.right,
          ),
        );
      }

      decoration = decoration.copyWith(
        borderRadius:
            decoration.borderRadius?.resolve(TextDirection.ltr).copyWith(
                  topLeft: showLeftFrozen ||
                          (headerSpacing == null || headerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  topRight: showRightFrozen ||
                          (headerSpacing == null || headerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomLeft: showLeftFrozen ||
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                  bottomRight: showRightFrozen ||
                          (footerSpacing == null || footerSpacing <= 0)
                      ? Radius.zero
                      : null,
                ),
      );

      borderRadius = decoration.borderRadius ?? BorderRadius.zero;
    }

    return Column(
      children: [
        if (headerSpacing != null && headerSpacing > 0)
          SizedBox(height: headerSpacing),
        Flexible(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: decoration,
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: PlutoScrollbar(
                      verticalController: scrollbarConfig.draggableScrollbar
                          ? _verticalScroll
                          : null,
                      horizontalController: scrollbarConfig.draggableScrollbar
                          ? _horizontalScroll
                          : null,
                      isAlwaysShown: scrollbarConfig.isAlwaysShown,
                      onlyDraggingThumb: scrollbarConfig.onlyDraggingThumb,
                      enableHover: PlatformHelper.isDesktop,
                      enableScrollAfterDragEnd:
                          scrollbarConfig.enableScrollAfterDragEnd,
                      thickness: scrollbarConfig.scrollbarThickness,
                      thicknessWhileDragging:
                          scrollbarConfig.scrollbarThicknessWhileDragging,
                      hoverWidth: scrollbarConfig.hoverWidth,
                      mainAxisMargin: scrollbarConfig.mainAxisMargin,
                      crossAxisMargin: scrollbarConfig.crossAxisMargin,
                      scrollBarColor: scrollbarConfig.scrollBarColor,
                      scrollBarTrackColor: scrollbarConfig.scrollBarTrackColor,
                      radius: scrollbarConfig.scrollbarRadius,
                      radiusWhileDragging:
                          scrollbarConfig.scrollbarRadiusWhileDragging,
                      longPressDuration: scrollbarConfig.longPressDuration,
                      child: SingleChildScrollView(
                        controller: _horizontalScroll,
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        child: CustomSingleChildLayout(
                          delegate: ListResizeDelegate(stateManager, _columns),
                          child: ListView.builder(
                            controller: _verticalScroll,
                            scrollDirection: Axis.vertical,
                            physics: const ClampingScrollPhysics(),
                            itemCount: _rows.length,
                            itemExtent: stateManager.rowTotalHeight,
                            addRepaintBoundaries: false,
                            itemBuilder: (ctx, i) {
                              return PlutoBaseRow(
                                key: ValueKey('body_row_${_rows[i].key}'),
                                rowIdx: i,
                                row: _rows[i],
                                columns: _columns,
                                stateManager: stateManager,
                                visibilityLayout: true,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (footerSpacing != null && footerSpacing > 0)
          SizedBox(height: footerSpacing),
      ],
    );
  }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}
