import 'dart:async';

import 'package:flutter/widgets.dart';

abstract class ContextModel<Widget> {
  bool get resolved;

  @protected
  Widget get widget;

  void updateContext(Widget widget);

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
