import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef VisibilityElements
    = Map<String, Map<Key, PlutoVisibilityColumnElement>>;

class VisibilityBuildController {
  double _visibleLeft = 0;

  double _visibleRight = 0;

  double _visibleMaxWidth = 0;

  bool _showFrozenColumn = false;

  double _lastLeftBoundX1 = 0;

  double _lastLeftBoundX2 = 0;

  double _lastRightBoundX1 = 0;

  double _lastRightBoundX2 = 0;

  static double visibleMarginWidth = 0;

  final VisibilityElements _visibilityColumnElements = {};

  VisibilityElements get visibilityColumnElements => _visibilityColumnElements;

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

  void update({
    required double left,
    required double right,
    required double maxWidth,
    required showFrozenColumn,
    required FilteredList<PlutoColumn> columns,
  }) {
    if (!_needsUpdate(
      left: left,
      right: right,
      maxWidth: maxWidth,
      showFrozenColumn: showFrozenColumn,
    )) {
      return;
    }

    PlutoColumn? leftVisibleColumn;
    PlutoColumn? rightVisibleColumn;
    PlutoColumn? previous;

    final List<PlutoVisibilityColumnElement> buildElements = [];

    for (final column in columns) {
      column.visible = visibleColumn(column);

      if (leftVisibleColumn == null && column.visible) {
        leftVisibleColumn = column;
      } else if (leftVisibleColumn != null && !column.visible) {
        rightVisibleColumn = previous;
      }

      previous = column;

      buildElements.addAll(
        _elementsToBuild(column: column, visible: column.visible),
      );
    }

    _updateHorizontalVisibleBound(
      leftVisibleColumn: leftVisibleColumn,
      rightVisibleColumn: rightVisibleColumn,
    );

    SchedulerBinding.instance.scheduleTask(() {
      for (final element in buildElements) {
        element.markNeedsBuild();
      }
    }, Priority.touch);
  }

  void addVisibilityColumnElement({
    required String field,
    required PlutoVisibilityColumnElement element,
  }) {
    if (!_visibilityColumnElements.containsKey(field)) {
      _visibilityColumnElements[field] = <Key, PlutoVisibilityColumnElement>{};
    }

    _visibilityColumnElements[field]![element.widget.key!] = element;
  }

  void removeVisibilityColumnElement({
    required String field,
    required PlutoVisibilityColumnElement element,
  }) {
    if (!_visibilityColumnElements.containsKey(field)) {
      return;
    }

    _visibilityColumnElements[field]!.remove(element.widget.key!);
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

    final bool sameBoundScroll = _lastLeftBoundX1 <= _visibleLeft &&
        _visibleLeft <= _lastLeftBoundX2 &&
        _lastRightBoundX1 <= _visibleRight &&
        _visibleRight <= _lastRightBoundX2;

    if (sameBoundScroll) {
      return false;
    }

    return true;
  }

  List<PlutoVisibilityColumnElement> _elementsToBuild({
    required PlutoColumn column,
    required bool visible,
  }) {
    if (!_visibilityColumnElements.containsKey(column.field)) {
      return [];
    }

    final Map<Key, PlutoVisibilityColumnElement> elements =
        _visibilityColumnElements[column.field]!;

    if (elements.isEmpty) {
      return [];
    }

    final List<PlutoVisibilityColumnElement> found = [];

    for (final element in elements.values) {
      element.visitChildElements((elementChild) {
        final oldVisible =
            elementChild.widget is! PlutoVisibilityReplacementWidget;

        if (visible != oldVisible) {
          found.add(element);
        }
      });
    }

    return found;
  }

  void _updateHorizontalVisibleBound({
    required PlutoColumn? leftVisibleColumn,
    required PlutoColumn? rightVisibleColumn,
  }) {
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
  }
}

abstract class IVisibilityState {
  VisibilityBuildController get visibilityBuildController;

  void updateHorizontalVisibilityState({bool notify = true});

  void updateColumnStartPosition();
}

mixin VisibilityState implements IPlutoGridState {
  final _visibilityBuildController = VisibilityBuildController();

  @override
  VisibilityBuildController get visibilityBuildController =>
      _visibilityBuildController;

  @override
  void updateHorizontalVisibilityState({bool notify = true}) {
    if (scroll?.bodyRowsHorizontal?.hasClients == null) {
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
