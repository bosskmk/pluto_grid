import 'package:pluto_grid/pluto_grid.dart';

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
