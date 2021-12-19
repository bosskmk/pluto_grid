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

class _PlutoLifecycleState extends State<PlutoLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.eventCallback(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
