import 'package:pluto_grid/pluto_grid.dart';

/// Event called when a row is dragged.
class PlutoGridDragRowsEvent extends PlutoGridEvent {
  final List<PlutoRow> rows;
  final int targetIdx;

  PlutoGridDragRowsEvent({
    required this.rows,
    required this.targetIdx,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: const Duration(milliseconds: debounceMilliseconds),
        );

  static const int debounceMilliseconds = 300;

  static const int resumeMilliseconds = debounceMilliseconds + 100;

  static bool _pause = false;

  @override
  void handler(PlutoGridStateManager? stateManager) async {
    if (_pause) {
      return;
    }

    stateManager!.moveRowsByIndex(
      rows,
      targetIdx,
    );

    _pause = true;

    await Future.delayed(
      const Duration(milliseconds: resumeMilliseconds),
      () => _pause = false,
    );
  }
}
