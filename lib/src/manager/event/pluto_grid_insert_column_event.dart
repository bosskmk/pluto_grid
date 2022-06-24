import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridInsertColumnEvent extends PlutoGridEvent {
  final int index;

  PlutoGridInsertColumnEvent({
    required this.index,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: const Duration(milliseconds: debounceMilliseconds),
        );

  static const int debounceMilliseconds = 300;

  static const int resumeMilliseconds = debounceMilliseconds + 100;

  @override
  void handler(PlutoGridStateManager? stateManager) async {
    if (stateManager!.eventManager!.subscription.isPaused) {
      return;
    }
  }
}
