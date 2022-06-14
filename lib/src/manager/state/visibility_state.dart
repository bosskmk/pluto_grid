import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [VisibilityStateNotifier]
/// checks whether the scrollable widget is located within the screen area.
///
/// [PlutoRow] automatically checks whether to render according to the scroll position in ListView.builder.
///
/// [PlutoCell] refers to the value of [PlutoColumn.startPosition]
/// to manually check whether to render as a child of [CustomMultiChildLayout].
class VisibilityStateNotifier extends ChangeNotifier {
  double _visibleLeft = 0;

  double _visibleRight = 0;

  double _visibleMaxWidth = 0;

  bool _showFrozenColumn = false;

  double _lastLeftBoundX1 = 0;

  double _lastLeftBoundX2 = 0;

  double _lastRightBoundX1 = 0;

  double _lastRightBoundX2 = 0;

  /// Calculate the width of the column as wide as the [visibleMarginWidth] value
  /// to the left and right of the area visible on the screen.
  static double visibleMarginWidth = 0;

  /// Returns whether the column is located in the screen area.
  bool visibleColumn(PlutoColumn column) {
    if (_showFrozenColumn && column.frozen.isFrozen) {
      return true;
    } else if (column.startPosition <= _visibleRight + visibleMarginWidth &&
        column.startPosition + column.width >=
            _visibleLeft - visibleMarginWidth) {
      return true;
    } else {
      return false;
    }
  }

  /// Update the values for calculating the screen area according to the scroll position.
  void update({
    required double left,
    required double right,
    required double maxWidth,
    required showFrozenColumn,
    required FilteredList<PlutoColumn> columns,
  }) {
    if (_visibleLeft == left &&
        _visibleRight == right &&
        _visibleMaxWidth == maxWidth &&
        _showFrozenColumn == showFrozenColumn) {
      return;
    }

    _visibleLeft = left;
    _visibleRight = right;
    _visibleMaxWidth = maxWidth;
    _showFrozenColumn = showFrozenColumn;

    final bool sameBoundScroll = _lastLeftBoundX1 <= _visibleLeft &&
        _visibleLeft <= _lastLeftBoundX2 &&
        _lastRightBoundX1 <= _visibleRight &&
        _visibleRight <= _lastRightBoundX2;

    if (sameBoundScroll) {
      return;
    }

    PlutoColumn? leftVisibleColumn;
    PlutoColumn? rightVisibleColumn;
    PlutoColumn? previous;

    for (final column in columns) {
      final visible = visibleColumn(column);

      if (leftVisibleColumn == null && visible) {
        leftVisibleColumn = column;
      } else if (leftVisibleColumn != null && !visible) {
        rightVisibleColumn = previous;
      }

      if (rightVisibleColumn != null) {
        break;
      }

      previous = column;
    }

    if (leftVisibleColumn != null) {
      _lastLeftBoundX1 = leftVisibleColumn.startPosition;
      _lastLeftBoundX2 =
          leftVisibleColumn.startPosition + leftVisibleColumn.width;
    }

    if (rightVisibleColumn != null) {
      _lastRightBoundX1 = rightVisibleColumn.startPosition;
      _lastRightBoundX2 =
          rightVisibleColumn.startPosition + rightVisibleColumn.width;
    }

    notifyListeners();
  }
}

/// Check whether the widget is rendered according to the scroll position
abstract class IVisibilityState {
  /// The [PlutoBaseCell] widget listens to this listener when built within the [PlutoBaseRow] widget.
  VisibilityStateNotifier get visibilityNotifier;

  /// [updateHorizontalVisibilityState] is added to the Offset change event listener
  /// of the grid's horizontal scroll when the [PlutoGrid] is initialized.
  ///
  /// Update the scroll position and screen area information of [VisibilityStateNotifier].
  void updateHorizontalVisibilityState({bool notify = true});

  /// [updateColumnStartPosition] is called when the width or position of a column
  /// or the show/hide state of a column is changed.
  ///
  /// When called, the value of [PlutoColumn.startPosition] is updated.
  void updateColumnStartPosition();
}

mixin VisibilityState implements IPlutoGridState {
  final _visibilityNotifier = VisibilityStateNotifier();

  @override
  VisibilityStateNotifier get visibilityNotifier => _visibilityNotifier;

  @override
  void updateHorizontalVisibilityState({bool notify = true}) {
    if (scroll?.bodyRowsHorizontal?.hasClients == null) {
      return;
    }

    final visibleLeft = scroll!.bodyRowsHorizontal!.offset;
    final visibleRight =
        visibleLeft + scroll!.bodyRowsHorizontal!.position.viewportDimension;

    _visibilityNotifier.update(
      left: visibleLeft,
      right: visibleRight,
      maxWidth: scroll!.maxScrollHorizontal,
      showFrozenColumn: showFrozenColumn,
      columns: refColumns,
    );
  }

  @override
  void updateColumnStartPosition() {
    double x = 0;

    for (final column in refColumns) {
      if (showFrozenColumn && column.frozen.isFrozen) {
        continue;
      }

      column.startPosition = x;

      x += column.width;
    }

    updateHorizontalVisibilityState();
  }
}
