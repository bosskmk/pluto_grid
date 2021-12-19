// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/widgets.dart';
import 'package:pluto_grid/src/widgets/pluto_lifecycle.dart';

class PlutoLifecycle extends StatefulWidget implements HasPlutoLifecycle {
  @override
  final void Function(AppLifecycleState state) eventCallback;

  @override
  final Widget child;

  const PlutoLifecycle({
    required this.eventCallback,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoLifecycleState createState() => _PlutoLifecycleState();
}

class _PlutoLifecycleState extends State<PlutoLifecycle> {
  @override
  void initState() {
    super.initState();

    html.window.addEventListener('focus', onFocus);

    html.window.addEventListener('blur', onBlur);
  }

  @override
  void dispose() {
    html.window.removeEventListener('focus', onFocus);

    html.window.removeEventListener('blur', onBlur);

    super.dispose();
  }

  void onFocus(html.Event e) {
    widget.eventCallback(AppLifecycleState.resumed);
  }

  void onBlur(html.Event e) {
    widget.eventCallback(AppLifecycleState.paused);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
