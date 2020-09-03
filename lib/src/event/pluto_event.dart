part of '../../pluto_grid.dart';

class PlutoEvent {}

/// Event : Cannot move current cell
class PlutoCannotMoveCurrentCellEvent extends PlutoEvent {
  final PlutoCellPosition cellPosition;
  final MoveDirection direction;

  PlutoCannotMoveCurrentCellEvent({
    this.cellPosition,
    this.direction,
  });
}
