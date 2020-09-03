part of '../../pluto_grid.dart';

class PlutoEvent {}

/// Event for cell movement
class PlutoCanMoveCellEvent extends PlutoEvent {
  final PlutoCellPosition cellPosition;
  final MoveDirection direction;
  final bool canMoveCell;

  PlutoCanMoveCellEvent({
    this.cellPosition,
    this.direction,
    this.canMoveCell,
  });
}
