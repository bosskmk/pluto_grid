import 'package:pluto_grid/pluto_grid.dart';

/// Occurs when the keyboard hits the end of the grid.
class PlutoCannotMoveCurrentCellEvent extends PlutoEvent {
  /// The position of the cell when it hits.
  final PlutoCellPosition cellPosition;

  /// The direction to move.
  final MoveDirection direction;

  PlutoCannotMoveCurrentCellEvent({
    this.cellPosition,
    this.direction,
  });

  void handler(PlutoStateManager stateManager) {}
}
