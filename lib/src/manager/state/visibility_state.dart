import 'package:flutter/material.dart';
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
    required List<PlutoColumn> columns,
    required void Function(PlutoGridEvent) addEvent,
    bool forceUpdate = false,
  }) {
    if (!_needsUpdate(
      left: left,
      right: right,
      maxWidth: maxWidth,
      showFrozenColumn: showFrozenColumn,
    )) {
      if (forceUpdate != false) {
        return;
      }
    }

    PlutoColumn? leftVisibleColumn;
    PlutoColumn? rightVisibleColumn;
    PlutoColumn? previous;

    final List<PlutoVisibilityColumnElement> visibleElements = [];
    final List<PlutoVisibilityColumnElement> invisibleElements = [];

    for (final column in columns) {
      column.visible = visibleColumn(column);

      if (leftVisibleColumn == null && column.visible) {
        leftVisibleColumn = column;
      } else if (leftVisibleColumn != null &&
          rightVisibleColumn == null &&
          !column.visible) {
        rightVisibleColumn = previous;
      }

      previous = column;

      final elements = _elements(column: column, visible: column.visible);

      column.visible
          ? visibleElements.addAll(elements)
          : invisibleElements.addAll(elements);
    }

    _updateHorizontalVisibleBound(
      leftVisibleColumn: leftVisibleColumn,
      rightVisibleColumn: rightVisibleColumn,
    );

    addEvent(PlutoBuildVisibilityEvent(
      elements: visibleElements,
    ));

    addEvent(PlutoBuildVisibilityEvent(
      elements: invisibleElements,
      type: PlutoGridEventType.throttle,
      duration: const Duration(milliseconds: 300),
    ));
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

  Iterable<PlutoVisibilityColumnElement> _elements({
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

    return elements.values;
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
      columns: refColumns.originalList,
      addEvent: eventManager!.addEvent,
      forceUpdate: forceUpdate,
    );
  }

  @override
  void updateColumnStartPosition({bool forceUpdate = false}) {
    double x = 0;

    for (final column in refColumns) {
      if (showFrozenColumn && column.frozen.isFrozen) {
        continue;
      }

      column.startPosition = x;

      x += column.width;
    }

    updateHorizontalVisibilityState(forceUpdate: forceUpdate);
  }

  @override
  void removeVisibilityColumnElements(Set<String> columnFields) {
    visibilityBuildController.visibilityColumnElements.removeWhere(
      (key, value) => columnFields.contains(key),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateColumnStartPosition(forceUpdate: true);
    });
  }
}
