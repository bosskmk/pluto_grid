import 'package:pluto_grid/pluto_grid.dart';

abstract class IVisibilityLayoutState {
  /// Set [PlutoColumn.startPosition] to [PlutoColumn.width].
  ///
  /// Set the horizontal position of the columns in the left area, center area, and right area
  /// according to the [PlutoColumn.frozen] value in [PlutoColumn.startPosition].
  ///
  /// This method should be called in an operation that dynamically changes the position of a column.
  /// Example) resizeColumn, frozenColumn, hideColumn...
  ///
  /// [notify] is called false in the normal case.
  /// When [notify] is called true,
  /// the notifyListeners of scrollController is forcibly called when build is not triggered.
  void updateVisibilityLayout({bool notify = false});
}

mixin VisibilityLayoutState implements IPlutoGridState {
  @override
  void updateVisibilityLayout({bool notify = false}) {
    if (refColumns.isEmpty) {
      return;
    }

    double leftX = 0;
    double bodyX = 0;
    double rightX = 0;

    PlutoAutoSize? autoSizeHelper;

    if (activatedColumnsAutoSize) {
      double offsetMaxWidth = maxWidth!;

      if (showFrozenColumn) {
        if (hasLeftFrozenColumns) {
          offsetMaxWidth -= PlutoGridSettings.gridBorderWidth;
        }

        if (hasRightFrozenColumns) {
          offsetMaxWidth -= PlutoGridSettings.gridBorderWidth;
        }
      }

      autoSizeHelper = getColumnsAutoSizeHelper(
        columns: refColumns,
        maxWidth: offsetMaxWidth,
      );
    }

    for (final column in refColumns) {
      if (autoSizeHelper != null) {
        column.width = autoSizeHelper.getItemSize(column.width);
      }

      if (showFrozenColumn) {
        switch (column.frozen) {
          case PlutoColumnFrozen.none:
            column.startPosition = bodyX;
            bodyX += column.width;
            break;
          case PlutoColumnFrozen.start:
            column.startPosition = leftX;
            leftX += column.width;
            break;
          case PlutoColumnFrozen.end:
            column.startPosition = rightX;
            rightX += column.width;
            break;
        }
      } else {
        column.startPosition = bodyX;
        column.frozen = PlutoColumnFrozen.none;
        bodyX += column.width;
      }
    }

    updateScrollViewport();

    if (notify) {
      scroll.horizontal?.notifyListeners();
    }
  }
}
