part of '../../../pluto_grid.dart';

/// Event : Such as DragUpdate or LongPressMoveUpdate.
class PlutoMoveUpdateEvent extends PlutoEvent {
  final Offset offset;

  PlutoMoveUpdateEvent({
    this.offset,
  });

  void _handler(PlutoStateManager stateManager) {
    if (offset == null) {
      return;
    }

    if (stateManager.needMovingScroll(offset, MoveDirection.Left)) {
      _scroll(stateManager, MoveDirection.Left);
    } else if (stateManager.needMovingScroll(offset, MoveDirection.Right)) {
      _scroll(stateManager, MoveDirection.Right);
    }

    if (stateManager.needMovingScroll(offset, MoveDirection.Up)) {
      _scroll(stateManager, MoveDirection.Up);
    } else if (stateManager.needMovingScroll(offset, MoveDirection.Down)) {
      _scroll(stateManager, MoveDirection.Down);
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
        ? -PlutoDefaultSettings.offsetScrollingFromEdgeAtOnce
        : PlutoDefaultSettings.offsetScrollingFromEdgeAtOnce;

    scroll.animateTo(scroll.offset + offset,
        curve: Curves.ease, duration: const Duration(milliseconds: 800));
  }
}
