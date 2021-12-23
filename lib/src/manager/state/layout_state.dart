import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ILayoutState {
  /// Screen width
  double? get maxWidth;

  /// Screen height
  double? get maxHeight;

  /// grid header height
  double get headerHeight;

  /// grid footer height
  double get footerHeight;

  double get offsetHeight;

  /// Global offset of Grid.
  Offset? get gridGlobalOffset;

  /// Whether to apply a frozen column according to the screen size.
  /// true : If there is a frozen column, the frozen column is exposed.
  /// false : If there is a frozen column but the screen is narrow, it is exposed as a normal column.
  bool? get showFrozenColumn;

  bool get showColumnFilter;

  bool get showHeader;

  bool get showFooter;

  bool get showLoading;

  bool get hasLeftFrozenColumns;

  bool get hasRightFrozenColumns;

  double get headerBottomOffset;

  double get footerTopOffset;

  double get columnHeight;

  double get columnGroupHeight;

  double get columnFilterHeight;

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

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size);

  void resetShowFrozenColumn({bool notify = true});

  void setShowColumnFilter(bool flag, {bool notify = true});

  void setShowLoading(bool flag);

  @visibleForTesting
  void setGridGlobalOffset(Offset offset);
}

mixin LayoutState implements IPlutoGridState {
  @override
  double? get maxWidth => _maxWidth;

  double? _maxWidth;

  @override
  double? get maxHeight => _maxHeight;

  double? _maxHeight;

  @override
  double get headerHeight =>
      createHeader == null ? 0 : PlutoGridSettings.rowTotalHeight;

  @override
  double get footerHeight =>
      createFooter == null ? 0 : PlutoGridSettings.rowTotalHeight;

  @override
  double get offsetHeight => maxHeight! - headerHeight - footerHeight;

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
  bool? get showFrozenColumn => _showFrozenColumn;

  bool? _showFrozenColumn;

  @override
  bool get showColumnFilter => _showColumnFilter == true;

  bool? _showColumnFilter;

  @override
  bool get showHeader => headerHeight > 0;

  @override
  bool get showFooter => footerHeight > 0;

  @override
  bool get showLoading => _showLoading == true;

  bool? _showLoading;

  @override
  bool get hasLeftFrozenColumns => leftFrozenColumnsWidth > 0;

  @override
  bool get hasRightFrozenColumns => rightFrozenColumnsWidth > 0;

  @override
  double get headerBottomOffset => maxHeight! - headerHeight;

  @override
  double get footerTopOffset =>
      maxHeight! - footerHeight - PlutoGridSettings.totalShadowLineWidth;

  @override
  double get columnHeight => configuration!.columnHeight;

  @override
  double get columnGroupHeight =>
      showColumnGroups ? columnGroupDepth(columnGroups) * columnHeight : 0;

  @override
  double get columnFilterHeight =>
      showColumnFilter ? configuration!.columnFilterHeight : 0;

  @override
  double get rowsTopOffset =>
      headerHeight + columnGroupHeight + columnHeight + columnFilterHeight;

  @override
  double get rowHeight => configuration!.rowHeight;

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
    return (showFrozenColumn! && leftFrozenColumnsWidth > 0)
        ? leftFrozenColumnsWidth + 1
        : 0;
  }

  @override
  double get bodyRightOffset {
    return (showFrozenColumn! && rightFrozenColumnsWidth > 0)
        ? rightFrozenColumnsWidth + 1
        : 0;
  }

  @override
  double get bodyLeftScrollOffset {
    final double leftFrozenColumnWidth =
        showFrozenColumn! ? leftFrozenColumnsWidth : 0;

    return gridGlobalOffset!.dx +
        PlutoGridSettings.gridPadding +
        PlutoGridSettings.gridBorderWidth +
        leftFrozenColumnWidth +
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get bodyRightScrollOffset {
    final double rightFrozenColumnWidth =
        showFrozenColumn! ? rightFrozenColumnsWidth : 0;

    return (gridGlobalOffset!.dx + maxWidth!) -
        rightFrozenColumnWidth -
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
        PlutoGridSettings.offsetScrollingFromEdge;
  }

  @override
  double get leftFrozenRightOffset => maxWidth! - bodyLeftOffset - 5;

  @override
  double get rightFrozenLeftOffset =>
      maxWidth! - bodyRightOffset - PlutoGridSettings.totalShadowLineWidth + 1;

  @override
  double get rightBlankOffset =>
      rightFrozenLeftOffset -
      leftFrozenColumnsWidth -
      bodyColumnsWidth +
      scroll!.horizontal!.offset;

  @override
  double get scrollOffsetByFrozenColumn {
    double offset = 0;

    if (_showFrozenColumn!) {
      offset += leftFrozenColumnsWidth > 0 ? 1 : 0;
      offset += rightFrozenColumnsWidth > 0 ? 1 : 0;
    }

    return offset;
  }

  @override
  void setLayout(BoxConstraints size) {
    final _isShowFrozenColumn = _availableToShowFrozenColumns(size.maxWidth);

    final bool notify = _showFrozenColumn != _isShowFrozenColumn;

    _maxWidth = size.maxWidth;
    _maxHeight = size.maxHeight;
    _showFrozenColumn = _isShowFrozenColumn;

    _gridGlobalOffset = null;

    updateCurrentCellPosition(notify: false);

    resetScrollToZero();

    if (notify) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  @override
  void resetShowFrozenColumn({bool notify = true}) {
    _showFrozenColumn = _availableToShowFrozenColumns(_maxWidth!);

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
  void setShowLoading(bool flag) {
    if (_showLoading == flag) {
      return;
    }

    _showLoading = flag;

    notifyListeners();
  }

  @override
  @visibleForTesting
  void setGridGlobalOffset(Offset offset) {
    _gridGlobalOffset = offset;
  }

  bool _availableToShowFrozenColumns(double width) {
    final bool hasFrozenColumn =
        leftFrozenColumns.isNotEmpty || rightFrozenColumns.isNotEmpty;

    return hasFrozenColumn &&
        width >
            (leftFrozenColumnsWidth +
                rightFrozenColumnsWidth +
                PlutoGridSettings.bodyMinWidth +
                PlutoGridSettings.totalShadowLineWidth);
  }
}
