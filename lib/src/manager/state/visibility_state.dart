import 'package:pluto_grid/pluto_grid.dart';

abstract class IVisibilityState {
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
  void updateVisibility({bool notify = false});
}

mixin VisibilityState implements IPlutoGridState {
  @override
  void updateVisibility({bool notify = false}) {
    double leftX = 0;
    double bodyX = 0;
    double rightX = 0;

    void updateShowFrozen(PlutoColumn column) {
      switch (column.frozen) {
        case PlutoColumnFrozen.none:
          column.startPosition = bodyX;
          bodyX += column.width;
          break;
        case PlutoColumnFrozen.left:
          column.startPosition = leftX;
          leftX += column.width;
          break;
        case PlutoColumnFrozen.right:
          column.startPosition = rightX;
          rightX += column.width;
          break;
      }
    }

    void updateNoneFrozen(PlutoColumn column) {
      column.startPosition = bodyX;
      column.frozen = PlutoColumnFrozen.none;
      bodyX += column.width;
    }

    final updater = showFrozenColumn ? updateShowFrozen : updateNoneFrozen;

    for (final column in refColumns.originalList) {
      if (column.hide) {
        continue;
      }

      updater(column);
    }

    updateScrollViewport();

    if (notify) {
      scroll?.horizontal?.notifyListeners();
    }
  }
}
