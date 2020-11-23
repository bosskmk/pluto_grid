part of '../../../pluto_grid.dart';

abstract class ILayoutState {
  /// Screen width
  double get maxWidth;

  /// Screen height
  double get maxHeight;

  /// grid header height
  double get headerHeight;

  /// grid footer height
  double get footerHeight;

  double get offsetHeight;

  /// Whether to apply a frozen column according to the screen size.
  /// true : If there is a frozen column, the frozen column is exposed.
  /// false : If there is a frozen column but the screen is narrow, it is exposed as a normal column.
  bool get showFrozenColumn;

  /// Global offset of Grid.
  Offset get gridGlobalOffset;

  bool get showHeader;

  bool get showFooter;

  bool get showLoading;

  bool get hasLeftFrozenColumns;

  bool get hasRightFrozenColumns;

  double get headerBottomOffset;

  double get footerTopOffset;

  double get columnHeight;

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

  double get rightFrozenLeftOffset;

  double get rightBlankOffset;

  double get scrollOffsetByFrozenColumn;

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size);

  void resetShowFrozenColumn({bool notify = true});

  void setShowLoading(bool flag);

  @visibleForTesting
  void setGridGlobalOffset(Offset offset);
}

mixin LayoutState implements IPlutoState {
  double get maxWidth => _maxWidth;

  double _maxWidth;

  double get maxHeight => _maxHeight;

  double _maxHeight;

  double get headerHeight =>
      createHeader == null ? 0 : PlutoDefaultSettings.rowTotalHeight;

  double get footerHeight =>
      createFooter == null ? 0 : PlutoDefaultSettings.rowTotalHeight;

  double get offsetHeight => maxHeight - headerHeight - footerHeight;

  bool get showFrozenColumn => _showFrozenColumn;

  bool _showFrozenColumn;

  Offset get gridGlobalOffset {
    if (gridKey == null) {
      return _gridGlobalOffset;
    }

    final RenderBox gridRenderBox = gridKey.currentContext?.findRenderObject();

    if (gridRenderBox == null) {
      return _gridGlobalOffset;
    }

    _gridGlobalOffset = gridRenderBox.localToGlobal(Offset.zero);

    return _gridGlobalOffset;
  }

  Offset _gridGlobalOffset;

  bool get showHeader => headerHeight > 0;

  bool get showFooter => footerHeight > 0;

  bool get showLoading => _showLoading == true;

  bool _showLoading;

  bool get hasLeftFrozenColumns => leftFrozenColumnsWidth > 0;

  bool get hasRightFrozenColumns => rightFrozenColumnsWidth > 0;

  double get headerBottomOffset => maxHeight - headerHeight;

  double get footerTopOffset =>
      maxHeight - footerHeight - PlutoDefaultSettings.totalShadowLineWidth;

  // todo : set columnHeight from configuration.
  double get columnHeight => PlutoDefaultSettings.rowTotalHeight;

  double get rowsTopOffset => headerHeight + columnHeight;

  double get rowHeight => configuration.rowHeight;

  double get rowTotalHeight => rowHeight + PlutoDefaultSettings.rowBorderWidth;

  double get bodyTopOffset =>
      gridGlobalOffset.dy +
      headerHeight +
      PlutoDefaultSettings.gridBorderWidth +
      columnHeight;

  double get bodyLeftOffset {
    return (showFrozenColumn && leftFrozenColumnsWidth > 0)
        ? leftFrozenColumnsWidth + 1
        : 0;
  }

  double get bodyRightOffset {
    return (showFrozenColumn && rightFrozenColumnsWidth > 0)
        ? rightFrozenColumnsWidth + 1
        : 0;
  }

  double get bodyLeftScrollOffset {
    final double leftFrozenColumnWidth =
        showFrozenColumn ? leftFrozenColumnsWidth : 0;

    return gridGlobalOffset.dx +
        PlutoDefaultSettings.gridPadding +
        PlutoDefaultSettings.gridBorderWidth +
        leftFrozenColumnWidth +
        PlutoDefaultSettings.offsetScrollingFromEdge;
  }

  double get bodyRightScrollOffset {
    final double rightFrozenColumnWidth =
        showFrozenColumn ? rightFrozenColumnsWidth : 0;

    return (gridGlobalOffset.dx + maxWidth) -
        rightFrozenColumnWidth -
        PlutoDefaultSettings.offsetScrollingFromEdge;
  }

  double get bodyUpScrollOffset {
    return bodyTopOffset + PlutoDefaultSettings.offsetScrollingFromEdge;
  }

  double get bodyDownScrollOffset {
    return gridGlobalOffset.dy +
        offsetHeight -
        PlutoDefaultSettings.offsetScrollingFromEdge;
  }

  double get rightFrozenLeftOffset =>
      maxWidth -
      bodyRightOffset -
      PlutoDefaultSettings.totalShadowLineWidth +
      1;

  double get rightBlankOffset =>
      rightFrozenLeftOffset -
      leftFrozenColumnsWidth -
      bodyColumnsWidth +
      scroll.horizontal.offset;

  double get scrollOffsetByFrozenColumn {
    double offset = 0;

    if (_showFrozenColumn) {
      offset += leftFrozenColumnsWidth > 0 ? 1 : 0;
      offset += rightFrozenColumnsWidth > 0 ? 1 : 0;
    }

    return offset;
  }

  void setLayout(BoxConstraints size) {
    final _isShowFrozenColumn = isShowFrozenColumn(size.maxWidth);

    final bool notify = _showFrozenColumn != _isShowFrozenColumn;

    _maxWidth = size.maxWidth;
    _maxHeight = size.maxHeight;
    _showFrozenColumn = _isShowFrozenColumn;

    _gridGlobalOffset = null;

    updateCurrentCellPosition(notify: false);

    if (notify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void resetShowFrozenColumn({bool notify = true}) {
    _showFrozenColumn = isShowFrozenColumn(_maxWidth);

    if (notify) {
      notifyListeners();
    }
  }

  void setShowLoading(bool flag) {
    if (_showLoading == flag) {
      return;
    }

    _showLoading = flag;

    notifyListeners();
  }

  @visibleForTesting
  void setGridGlobalOffset(Offset offset) {
    _gridGlobalOffset = offset;
  }
}
