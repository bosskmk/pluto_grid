import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ContextModel<Widget extends HasPlutoStateManager> {
  bool get resolved =>
      _widget != null && !_widget!.stateManager.hasRemainingFrame;

  Widget? _widget;

  void bindWidget(Widget widget) {
    _widget = widget;
  }

  Future<Widget> resolveWidget() {
    if (resolved) {
      return Future.value(_widget);
    }

    final completer = Completer<Widget>();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      completer.complete(_widget);
    });

    return completer.future;
  }
}
