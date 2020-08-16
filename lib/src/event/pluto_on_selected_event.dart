part of pluto_grid;

typedef PlutoOnSelectedEventCallback = void Function(PlutoOnSelectedEvent event);

class PlutoOnSelectedEvent {
  final PlutoRow row;

  PlutoOnSelectedEvent({
    this.row,
  });
}
