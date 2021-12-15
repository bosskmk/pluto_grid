import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class ContextModel<
    Widget extends HasPlutoStateManager<PlutoGridStateManager>> {
  bool get resolved =>
      _widget != null && !_widget!.stateManager.hasRemainingFrame;

  @protected
  Widget get widget => _widget!;

  Widget? _widget;

  void updateContext(Widget widget) {
    _widget = widget;
  }

  Future<Widget> resolve() {
    if (resolved) {
      return Future.value(widget);
    }

    final completer = Completer<Widget>();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      completer.complete(widget);
    });

    return completer.future;
  }
}
