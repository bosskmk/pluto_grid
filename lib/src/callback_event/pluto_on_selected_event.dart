part of '../../pluto_grid.dart';

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoOnSelectedEvent event);

class PlutoOnSelectedEvent {
  final PlutoRow row;
  final PlutoCell cell;

  PlutoOnSelectedEvent({
    this.row,
    this.cell,
  });
}
