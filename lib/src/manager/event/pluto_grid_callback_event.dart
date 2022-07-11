import 'package:pluto_grid/pluto_grid.dart';

/// [callback] This is an event that calls the function.
/// Usually used to debounce and throttle a specific function.
class PlutoGridCallbackEvent extends PlutoGridEvent {
  PlutoGridCallbackEvent({
    required this.callback,
    super.type,
    super.duration,
  });

  final void Function() callback;

  @override
  void handler(PlutoGridStateManager stateManager) {
    callback();
  }
}
