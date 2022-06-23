import 'package:pluto_grid/pluto_grid.dart';

abstract class IVisibilityState {
  void updateColumnStartPosition({bool notify = false});
}

mixin VisibilityState implements IPlutoGridState {
  @override
  void updateColumnStartPosition({bool notify = false}) {
    double leftX = 0;
    double bodyX = 0;
    double rightX = 0;

    for (final column in refColumns.originalList) {
      if (column.hide) {
        continue;
      }

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

    try {
      // todo : https://github.com/google/flutter.widgets/pull/398
      final double bodyWidth = maxWidth! - bodyLeftOffset - bodyRightOffset;
      scroll!.horizontal!.applyViewportDimension(bodyWidth);

      if (notify) {
        scroll!.horizontal!.notifyListeners();
      }
    } catch (e) {
      //
    }
  }
}
