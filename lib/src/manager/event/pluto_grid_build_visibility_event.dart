import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBuildVisibilityEvent extends PlutoGridEvent {
  PlutoBuildVisibilityEvent({
    required this.elements,
    super.type,
    super.duration,
  });

  final Iterable<PlutoVisibilityColumnElement> elements;

  @override
  void handler(PlutoGridStateManager stateManager) {
    final List<PlutoVisibilityColumnElement> found = [];

    for (final element in elements) {
      final widget = element.widget as PlutoVisibilityColumn;

      element.visitChildElements((elementChild) {
        final oldVisible =
            elementChild.widget is! PlutoVisibilityReplacementWidget;

        if (widget.child.column.visible != oldVisible) {
          found.add(element);
        }
      });
    }

    if (type.isNormal) {
      for (final element in found) {
        element.markNeedsBuild();
      }
    } else {
      WidgetsBinding.instance.endOfFrame.then((value) {
        for (final element in found) {
          element.markNeedsBuild();
        }
      });
    }
  }
}
