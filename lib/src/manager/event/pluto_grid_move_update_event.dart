import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// An event that occurs when dragging or moving after a long tap.
class PlutoGridMoveUpdateEvent extends PlutoGridEvent {
  final Offset offset;

  PlutoGridMoveUpdateEvent({
    this.offset,
  });

  void handler(PlutoGridStateManager stateManager) {
    if (offset == null) {
      return;
    }

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

  void _scroll(PlutoGridStateManager stateManager, PlutoMoveDirection move) {
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
