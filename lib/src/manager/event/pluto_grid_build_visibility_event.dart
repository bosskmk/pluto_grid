import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      if (!element.mounted) {
        continue;
      }

      final widget = element.widget as PlutoVisibilityColumn;

      element.visitChildElements((elementChild) {
        final oldVisible =
            elementChild.widget is! PlutoVisibilityReplacementWidget;

        if (widget.child.column.visible != oldVisible) {
          if (widget.child.column.visible) {
            found.add(element);
          } else {
            element.performRebuild();
          }
        }
      });
    }

    WidgetsBinding.instance.scheduleTask(() {
      for (final element in found) {
        element.markNeedsBuild();
      }
    }, Priority.touch);
  }
}
