import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Event called when a row is dragged.
class PlutoGridDragRowsEvent extends PlutoGridEvent {
  final List<PlutoRow?> rows;
  final int? targetIdx;
  final Offset? offset;

  PlutoGridDragRowsEvent({
    required this.rows,
    this.targetIdx,
    this.offset,
  }) : super(
          type: PlutoGridEventType.debounce,
          duration: const Duration(milliseconds: debounceMilliseconds),
        );

  static const int debounceMilliseconds = 300;

  static const int resumeMilliseconds = debounceMilliseconds + 100;

  void handler(PlutoGridStateManager? stateManager) async {
    if (stateManager!.eventManager!.subscription.isPaused) {
      return;
    }

    stateManager.moveRowsByIndex(
      rows,
      targetIdx,
    );

    stateManager.eventManager!.subscription.pause();

    await Future.delayed(
      const Duration(milliseconds: resumeMilliseconds),
      () => stateManager.eventManager!.subscription.resume(),
    );
  }
}
