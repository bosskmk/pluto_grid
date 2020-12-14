import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// Event : Such as DragUpdate or LongPressMoveUpdate.
class PlutoMoveUpdateEvent extends PlutoEvent {
  final Offset offset;

  PlutoMoveUpdateEvent({
    this.offset,
  });

  void handler(PlutoStateManager stateManager) {
    if (offset == null) {
      return;
    }

    if (stateManager.needMovingScroll(offset, MoveDirection.left)) {
      _scroll(stateManager, MoveDirection.left);
    } else if (stateManager.needMovingScroll(offset, MoveDirection.right)) {
      _scroll(stateManager, MoveDirection.right);
    }

    if (stateManager.needMovingScroll(offset, MoveDirection.up)) {
      _scroll(stateManager, MoveDirection.up);
    } else if (stateManager.needMovingScroll(offset, MoveDirection.down)) {
      _scroll(stateManager, MoveDirection.down);
    }
  }

  void _scroll(PlutoStateManager stateManager, MoveDirection move) {
    if (move == null) {
      return;
    }

    final LinkedScrollControllerGroup scroll = move.horizontal
        ? stateManager.scroll.horizontal
        : stateManager.scroll.vertical;

    final double offset = move.isLeft || move.isUp
        ? -PlutoGridSettings.offsetScrollingFromEdgeAtOnce
        : PlutoGridSettings.offsetScrollingFromEdgeAtOnce;

    scroll.animateTo(scroll.offset + offset,
        curve: Curves.ease, duration: const Duration(milliseconds: 800));
  }
}
