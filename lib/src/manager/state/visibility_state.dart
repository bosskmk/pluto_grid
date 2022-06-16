import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class VisibilityBuildController extends ChangeNotifier {
  double _visibleLeft = 0;

  double get visibleLeft => _visibleLeft;

  double _visibleRight = 0;

  double get visibleRight => _visibleRight;

  double get leftColumnStart =>
      leftVisibleColumn == null ? 0 : leftVisibleColumn!.startPosition;

  double get leftColumnEnd => leftVisibleColumn == null
      ? 0
      : leftVisibleColumn!.startPosition + leftVisibleColumn!.width;

  double get rightColumnStart =>
      rightVisibleColumn == null ? 0 : rightVisibleColumn!.startPosition;

  double get rightColumnEnd => rightVisibleColumn == null
      ? 0
      : rightVisibleColumn!.startPosition + rightVisibleColumn!.width;

  PlutoColumn? leftVisibleColumn;

  PlutoColumn? rightVisibleColumn;

  double _visibleMaxWidth = 0;

  bool _showFrozenColumn = false;

  bool visibleColumn(PlutoColumn column) {
    if (_showFrozenColumn && column.frozen.isFrozen) {
      return true;
    } else if (column.startPosition <= _visibleRight &&
        column.startPosition + column.width >= _visibleLeft) {
      return true;
    } else {
      return false;
    }
  }

  bool visibleColumnGroupPair(PlutoColumnGroupPair columnGroup) {
    return visibleColumn(columnGroup.firstColumn) ||
        visibleColumn(columnGroup.lastColumn);
  }

  bool correctOffset({
    required double leftOffset,
    required double rightOffset,
  }) {
    if (leftColumnEnd < leftOffset ||
        leftColumnStart > rightOffset ||
        rightColumnStart > rightOffset ||
        rightColumnEnd < leftOffset) {
      return false;
    }

    return true;
  }

  void update({
    required double left,
    required double right,
    required double maxWidth,
    required showFrozenColumn,
    required List<PlutoColumn> columns,
    bool forceUpdate = false,
  }) {
    if (!_needsUpdate(
      left: left,
      right: right,
      maxWidth: maxWidth,
      showFrozenColumn: showFrozenColumn,
    )) {
      if (!forceUpdate) {
        return;
      }
    }

    leftVisibleColumn = null;
    rightVisibleColumn = null;
    PlutoColumn? previous;

    for (final column in columns) {
      final bool visible = visibleColumn(column);

      if (leftVisibleColumn == null && visible && column.frozen.isNone) {
        leftVisibleColumn = column;
      } else if (leftVisibleColumn != null &&
          rightVisibleColumn == null &&
          !visible &&
          column.frozen.isNone) {
        rightVisibleColumn = previous;
      }

      previous = column;
    }

    notifyListeners();
  }

  bool _needsUpdate({
    required double left,
    required double right,
    required double maxWidth,
    required showFrozenColumn,
  }) {
    if (_visibleLeft == left &&
        _visibleRight == right &&
        _visibleMaxWidth == maxWidth &&
        _showFrozenColumn == showFrozenColumn) {
      return false;
    }

    _visibleLeft = left;
    _visibleRight = right;
    _visibleMaxWidth = maxWidth;
    _showFrozenColumn = showFrozenColumn;

    final bool sameBoundScroll = leftColumnStart <= _visibleLeft &&
        _visibleLeft <= leftColumnEnd &&
        rightColumnStart <= _visibleRight &&
        _visibleRight <= rightColumnEnd;

    if (sameBoundScroll) {
      return false;
    }

    return true;
  }
}

abstract class IVisibilityState {
  VisibilityBuildController get visibilityBuildController;

  void updateHorizontalVisibilityState({bool forceUpdate = false});

  void updateColumnStartPosition({bool forceUpdate = false});

  void removeVisibilityColumnElements(Set<String> columnFields);
}

mixin VisibilityState implements IPlutoGridState {
  final _visibilityBuildController = VisibilityBuildController();

  @override
  VisibilityBuildController get visibilityBuildController =>
      _visibilityBuildController;

  @override
  void updateHorizontalVisibilityState({bool forceUpdate = false}) {
    _performUpdateHorizontalVisibility(forceUpdate: forceUpdate);

    if (!forceUpdate) {
      eventManager!.addEvent(PlutoGridCallbackEvent(
        callback: _performUpdateHorizontalVisibility,
        type: PlutoGridEventType.debounce,
        duration: const Duration(milliseconds: 10),
      ));
    }
  }

  @override
  void updateColumnStartPosition({bool forceUpdate = false}) {
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

    updateHorizontalVisibilityState(forceUpdate: forceUpdate);
  }

  @override
  void removeVisibilityColumnElements(Set<String> columnFields) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateColumnStartPosition(forceUpdate: true);
    });
  }

  void _performUpdateHorizontalVisibility({bool forceUpdate = false}) {
    if (scroll?.bodyRowsHorizontal?.hasClients != true) {
      return;
    }

    final visibleLeft = scroll!.bodyRowsHorizontal!.offset;
    final visibleRight =
        visibleLeft + scroll!.bodyRowsHorizontal!.position.viewportDimension;

    _visibilityBuildController.update(
      left: visibleLeft,
      right: visibleRight,
      maxWidth: scroll!.maxScrollHorizontal,
      showFrozenColumn: showFrozenColumn,
      columns: refColumns.originalList,
      forceUpdate: forceUpdate,
    );
  }
}
