import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ILayoutState {
  ChangeNotifier get resizingChangeNotifier;

  /// Screen width
  double? get maxWidth;

  /// Screen height
  double? get maxHeight;

  /// grid header height
  double get headerHeight;

  /// grid footer height
  double get footerHeight;

  double get columnRowContainerHeight;

  double get rowContainerHeight;

  /// Global offset of Grid.
  Offset? get gridGlobalOffset;

  /// Whether to apply a frozen column according to the screen size.
  /// true : If there is a frozen column, the frozen column is exposed.
  /// false : If there is a frozen column but the screen is narrow, it is exposed as a normal column.
  bool get showFrozenColumn;

  bool get showColumnTitle;

  bool get showColumnFooter;

  bool get showColumnFilter;

  bool get showHeader;

  bool get showFooter;

  bool get showLoading;

  bool get hasLeftFrozenColumns;

  bool get hasRightFrozenColumns;

  double get headerBottomOffset;

  double get footerTopOffset;

  double get columnHeight;

  double get columnFooterHeight;

  double get columnGroupHeight;

  double get columnFilterHeight;

  double get columnBottomOffset;

  double get rowsTopOffset;

  double get rowHeight;

  double get rowTotalHeight;

  double get bodyTopOffset;

  double get bodyLeftOffset;

  double get bodyRightOffset;

  double get bodyLeftScrollOffset;

  double get bodyRightScrollOffset;

  double get bodyUpScrollOffset;

  double get bodyDownScrollOffset;

  double get leftFrozenRightOffset;

  double get rightFrozenLeftOffset;

  double get rightBlankOffset;

  double get scrollOffsetByFrozenColumn;

  TextDirection get textDirection;

  bool get isLTR;

  bool get isRTL;

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size);

  void setShowColumnTitle(bool flag, {bool notify = true});

  void setShowColumnFooter(bool flag, {bool notify = true});

  void setShowColumnFilter(bool flag, {bool notify = true});

  void setShowLoading(bool flag, {bool notify = true});

  void resetShowFrozenColumn();

  bool shouldShowFrozenColumns(double width);

  bool enoughFrozenColumnsWidth(double width);

  void notifyResizingListeners();

  void setTextDirection(TextDirection textDirection);

  @visibleForTesting
  void setGridGlobalOffset(Offset offset);
}

mixin LayoutState implements IPlutoGridState {
  @override
  ChangeNotifier get resizingChangeNotifier => _resizingChangeNotifier;

  final ChangeNotifier _resizingChangeNotifier = ChangeNotifier();

  @override
  double? get maxWidth => _maxWidth;

  double? _maxWidth;

  @override
  double? get maxHeight => _maxHeight;

  double? _maxHeight;

  double? _headerHeight;

  double? _footerHeight;

  double? _columnFooterHeight;

  set headerHeight(double value) {
    _headerHeight = value;
  }

  set footerHeight(double value) {
    _footerHeight = value;
  }

  set columnFooterHeight(double value) {
    _columnFooterHeight = value;
  }

  @override
  double get headerHeight {
    if (createHeader == null) {
      return 0;
    }

    return _headerHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _headerHeight!;
  }

  @override
  double get footerHeight {
    if (createFooter == null) {
      return 0;
    }

    return _footerHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _footerHeight!;
  }

  @override
  double get columnFooterHeight {
    if (!showColumnFooter) {
      return 0;
    }

    return _columnFooterHeight == null
        ? PlutoGridSettings.rowTotalHeight
        : _columnFooterHeight!;
  }

  @override
  double get columnRowContainerHeight =>
      maxHeight! - headerHeight - footerHeight;

  @override
  double get rowContainerHeight => maxHeight! - rowsTopOffset - footerHeight;

  @override
  Offset? get gridGlobalOffset {
    if (gridKey == null) {
      return _gridGlobalOffset;
    }

    final RenderBox? gridRenderBox =
        gridKey!.currentContext?.findRenderObject() as RenderBox?;

    if (gridRenderBox == null) {
      return _gridGlobalOffset;
    }

    _gridGlobalOffset = gridRenderBox.localToGlobal(Offset.zero);

    return _gridGlobalOffset;
  }

  Offset? _gridGlobalOffset;

  @override
  bool get showFrozenColumn => _showFrozenColumn == true;

  bool? _showFrozenColumn;

  @override
  bool get showColumnTitle => _showColumnTitle == true;

  bool? _showColumnTitle = true;

  @override
  bool get showColumnFooter => _showColumnFooter == true;

  bool? _showColumnFooter = false;

  @override
  bool get showColumnFilter => _showColumnFilter == true;

  bool? _showColumnFilter;

  @override
  bool get showHeader => createHeader != null;

  @override
  bool get showFooter => createFooter != null;

  @override
  bool get showLoading => _showLoading == true;

  bool? _showLoading;

  @override
  bool get hasLeftFrozenColumns =>
      refColumns.firstWhereOrNull((e) => e.frozen.isStart) != null;

  @override
  bool get hasRightFrozenColumns =>
      refColumns.firstWhereOrNull((e) => e.frozen.isEnd) != null;

  @override
  double get headerBottomOffset => maxHeight! - headerHeight;

  @override
  double get footerTopOffset =>
      maxHeight! - footerHeight - PlutoGridSettings.totalShadowLineWidth;

  @override
  double get columnHeight =>
      showColumnTitle ? configuration!.style.columnHeight : 0;

  @override
  double get columnGroupHeight =>
      showColumnGroups ? columnGroupDepth(columnGroups) * columnHeight : 0;

  @override
  double get columnFilterHeight =>
      showColumnFilter ? configuration!.style.columnFilterHeight : 0;

  @override
  double get columnBottomOffset =>
      maxHeight! - rowsTopOffset - PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rowsTopOffset =>
      headerHeight + columnGroupHeight + columnHeight + columnFilterHeight;

  @override
  double get rowHeight => configuration!.style.rowHeight;

  @override
  double get rowTotalHeight => rowHeight + PlutoGridSettings.rowBorderWidth;

  @override
  double get bodyTopOffset =>
      gridGlobalOffset!.dy +
      PlutoGridSettings.gridPadding +
      headerHeight +
      PlutoGridSettings.gridBorderWidth +
      columnGroupHeight +
      columnHeight +
      columnFilterHeight;

  @override
  double get bodyLeftOffset {
    return (showFrozenColumn && leftFrozenColumnsWidth > 0)
        ? leftFrozenColumnsWidth + PlutoGridSettings.gridBorderWidth
        : 0;
  }

  @override
  double get bodyRightOffset {
    return (showFrozenColumn && rightFrozenColumnsWidth > 0)
        ? rightFrozenColumnsWidth + PlutoGridSettings.gridBorderWidth
        : 0;
  }

  @override
  double get bodyLeftScrollOffset {
    return gridGlobalOffset!.dx +
        PlutoGridSettings.gridPadding +
        PlutoGridSettings.gridBorderWidth +
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyRightScrollOffset {
    return (gridGlobalOffset!.dx + maxWidth!) -
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyUpScrollOffset {
    return bodyTopOffset + PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyDownScrollOffset {
    return gridGlobalOffset!.dy +
        maxHeight! -
        footerHeight -
        columnFooterHeight -
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get leftFrozenRightOffset =>
      maxWidth! -
      leftFrozenColumnsWidth -
      PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rightFrozenLeftOffset =>
      maxWidth! -
      rightFrozenColumnsWidth -
      PlutoGridSettings.totalShadowLineWidth;

  @override
  double get rightBlankOffset =>
      rightFrozenLeftOffset -
      leftFrozenColumnsWidth -
      bodyColumnsWidth +
      PlutoGridSettings.totalShadowLineWidth +
      scroll!.horizontal!.offset;

  @override
  double get scrollOffsetByFrozenColumn {
    double offset = 0;

    if (_showFrozenColumn!) {
      offset +=
          leftFrozenColumnsWidth > 0 ? PlutoGridSettings.gridBorderWidth : 0;
      offset +=
          rightFrozenColumnsWidth > 0 ? PlutoGridSettings.gridBorderWidth : 0;
    }

    return offset;
  }

  @override
  TextDirection get textDirection => _textDirection;

  TextDirection _textDirection = TextDirection.ltr;

  @override
  bool get isLTR => textDirection == TextDirection.ltr;

  @override
  bool get isRTL => textDirection == TextDirection.rtl;

  @override
  void setLayout(BoxConstraints size) {
    final showFrozenColumn = shouldShowFrozenColumns(size.maxWidth);
    final bool changedShowFrozenColumn = _showFrozenColumn != showFrozenColumn;
    final bool changedMaxWidth = _maxWidth != size.maxWidth;

    _maxWidth = size.maxWidth;
    _maxHeight = size.maxHeight;
    _showFrozenColumn = showFrozenColumn;
    _gridGlobalOffset = null;

    if (changedShowFrozenColumn || changedMaxWidth) {
      updateVisibilityLayout();

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        notifyResizingListeners();
      });
    }

    if (enableColumnsAutoSize && !activatedColumnsAutoSize) {
      activateColumnsAutoSize();
    }
  }

  @override
  void setShowColumnTitle(bool flag, {bool notify = true}) {
    if (_showColumnTitle == flag) {
      return;
    }

    _showColumnTitle = flag;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setShowColumnFooter(bool flag, {bool notify = true}) {
    if (_showColumnFooter == flag) {
      return;
    }

    _showColumnFooter = flag;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setShowColumnFilter(bool flag, {bool notify = true}) {
    if (_showColumnFilter == flag) {
      return;
    }

    _showColumnFilter = flag;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setShowLoading(bool flag, {bool notify = true}) {
    if (_showLoading == flag) {
      return;
    }

    _showLoading = flag;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void resetShowFrozenColumn() {
    _showFrozenColumn = shouldShowFrozenColumns(maxWidth!);
  }

  @override
  bool shouldShowFrozenColumns(double width) {
    final bool hasFrozenColumn =
        leftFrozenColumns.isNotEmpty || rightFrozenColumns.isNotEmpty;

    return hasFrozenColumn && enoughFrozenColumnsWidth(width);
  }

  @override
  bool enoughFrozenColumnsWidth(double width) {
    return width >
        (leftFrozenColumnsWidth +
            rightFrozenColumnsWidth +
            PlutoGridSettings.bodyMinWidth +
            PlutoGridSettings.totalShadowLineWidth);
  }

  @override
  void notifyResizingListeners() {
    updateVisibilityLayout(notify: true);

    _resizingChangeNotifier.notifyListeners();
  }

  @override
  void setTextDirection(TextDirection textDirection) {
    _textDirection = textDirection;
  }

  @override
  @visibleForTesting
  void setGridGlobalOffset(Offset offset) {
    _gridGlobalOffset = offset;
  }
}
