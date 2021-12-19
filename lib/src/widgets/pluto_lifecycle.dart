import 'package:flutter/widgets.dart';

abstract class HasPlutoLifecycle implements StatefulWidget {
  void Function(AppLifecycleState state) get eventCallback;

  Widget get child;
}

class PlutoLifecycle extends StatefulWidget implements HasPlutoLifecycle {
  const PlutoLifecycle({
    required this.eventCallback,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  final void Function(AppLifecycleState state) eventCallback;

  @override
  final Widget child;

  @override
  // ignore: no_logic_in_create_state
  createState() => throw UnimplementedError();
}
