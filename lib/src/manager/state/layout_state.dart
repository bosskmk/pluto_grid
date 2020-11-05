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

  /// Whether to apply a fixed column according to the screen size.
  /// true : If there is a fixed column, the fixed column is exposed.
  /// false : If there is a fixed column but the screen is narrow, it is exposed as a normal column.
  bool get showFixedColumn;

  /// Global offset of Grid.
  Offset get gridGlobalOffset;

  bool get showHeader;

  bool get showFooter;

  bool get hasLeftFixedColumns;

  bool get hasRightFixedColumns;

  double get headerBottomOffset;

  double get footerTopOffset;

  double get columnHeight;

  double get rowsTopOffset;

  double get bodyTopOffset;

  double get bodyLeftOffset;

  double get bodyRightOffset;

  double get bodyLeftScrollOffset;

  double get bodyRightScrollOffset;

  double get bodyUpScrollOffset;

  double get bodyDownScrollOffset;

  double get rightFixedLeftOffset;

  double get scrollOffsetByFixedColumn;

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size);

  void resetShowFixedColumn({bool notify: true});

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

  bool get showFixedColumn => _showFixedColumn;

  bool _showFixedColumn;

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

  bool get hasLeftFixedColumns => leftFixedColumnsWidth > 0;

  bool get hasRightFixedColumns => rightFixedColumnsWidth > 0;

  double get headerBottomOffset => maxHeight - headerHeight;

  double get footerTopOffset =>
      maxHeight - footerHeight - PlutoDefaultSettings.totalShadowLineWidth;

  double get columnHeight => PlutoDefaultSettings.rowTotalHeight;

  double get rowsTopOffset => headerHeight + columnHeight;

  double get bodyTopOffset =>
      gridGlobalOffset.dy +
      PlutoDefaultSettings.gridBorderWidth +
      PlutoDefaultSettings.rowTotalHeight;

  double get bodyLeftOffset {
    return (showFixedColumn && leftFixedColumnsWidth > 0)
        ? leftFixedColumnsWidth + 1
        : 0;
  }

  double get bodyRightOffset {
    return (showFixedColumn && rightFixedColumnsWidth > 0)
        ? rightFixedColumnsWidth + 1
        : 0;
  }

  double get bodyLeftScrollOffset {
    final double leftFixedColumnWidth =
        showFixedColumn ? leftFixedColumnsWidth : 0;

    return gridGlobalOffset.dx +
        PlutoDefaultSettings.gridPadding +
        PlutoDefaultSettings.gridBorderWidth +
        leftFixedColumnWidth +
        PlutoDefaultSettings.offsetScrollingFromEdge;
  }

  double get bodyRightScrollOffset {
    final double rightFixedColumnWidth =
        showFixedColumn ? rightFixedColumnsWidth : 0;

    return (gridGlobalOffset.dx + maxWidth) -
        rightFixedColumnWidth -
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

  double get rightFixedLeftOffset =>
      maxWidth -
      bodyRightOffset -
      PlutoDefaultSettings.totalShadowLineWidth +
      1;

  double get scrollOffsetByFixedColumn {
    double offset = 0;

    offset += leftFixedColumnsWidth > 0 ? 1 : 0;
    offset += rightFixedColumnsWidth > 0 ? 1 : 0;

    return offset;
  }

  void setLayout(BoxConstraints size) {
    final _isShowFixedColumn = isShowFixedColumn(size.maxWidth);

    final bool notify = _showFixedColumn != _isShowFixedColumn;

    _maxWidth = size.maxWidth;
    _maxHeight = size.maxHeight;
    _showFixedColumn = _isShowFixedColumn;

    _gridGlobalOffset = null;

    if (notify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void resetShowFixedColumn({bool notify: true}) {
    _showFixedColumn = isShowFixedColumn(_maxWidth);

    if (notify) {
      notifyListeners();
    }
  }

  @visibleForTesting
  void setGridGlobalOffset(Offset offset) {
    _gridGlobalOffset = offset;
  }
}
