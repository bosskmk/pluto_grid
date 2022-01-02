import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridDragColumnEvent extends PlutoGridEvent {
  final PlutoColumn column;
  final PlutoColumn targetColumn;

  PlutoGridDragColumnEvent({
    required this.column,
    required this.targetColumn,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: const Duration(milliseconds: debounceMilliseconds),
        );

  static const int debounceMilliseconds = 300;

  static const int resumeMilliseconds = debounceMilliseconds + 100;

  @override
  void handler(PlutoGridStateManager? stateManager) async {
    if (stateManager!.eventManager.subscription.isPaused) {
      return;
    }

    stateManager.moveColumn(column: column, targetColumn: targetColumn);

    stateManager.eventManager.subscription.pause();

    await Future.delayed(
      const Duration(milliseconds: resumeMilliseconds),
      () => stateManager.eventManager.subscription.resume(),
    );
  }
}
