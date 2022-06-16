import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// An event that occurs when dragging or moving after a long tap.
class PlutoGridScrollUpdateEvent extends PlutoGridEvent {
  final Offset offset;

  PlutoGridScrollUpdateEvent({
    required this.offset,
  }) : super(
          type: PlutoGridEventType.throttleTrailing,
          duration: const Duration(milliseconds: 800),
        );

  @override
  void handler(PlutoGridStateManager stateManager) {
    if (stateManager.needMovingScroll(offset, PlutoMoveDirection.left)) {
      _scroll(stateManager, PlutoMoveDirection.left);
    } else if (stateManager.needMovingScroll(
        offset, PlutoMoveDirection.right)) {
      _scroll(stateManager, PlutoMoveDirection.right);
    }

    if (stateManager.needMovingScroll(offset, PlutoMoveDirection.up)) {
      _scroll(stateManager, PlutoMoveDirection.up);
    } else if (stateManager.needMovingScroll(offset, PlutoMoveDirection.down)) {
      _scroll(stateManager, PlutoMoveDirection.down);
    }
  }

  void _scroll(PlutoGridStateManager? stateManager, PlutoMoveDirection move) {
    final LinkedScrollControllerGroup scroll = move.horizontal
        ? stateManager!.scroll!.horizontal!
        : stateManager!.scroll!.vertical!;

    final double offset = move.isLeft || move.isUp
        ? -PlutoGridSettings.offsetScrollingFromEdgeAtOnce
        : PlutoGridSettings.offsetScrollingFromEdgeAtOnce;

    scroll.animateTo(scroll.offset + offset,
        curve: Curves.ease, duration: const Duration(milliseconds: 800));
  }
}
