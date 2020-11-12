part of '../../pluto_grid.dart';

typedef PlutoOnLoadedEventCallback = void Function(PlutoOnLoadedEvent event);

class PlutoOnLoadedEvent {
  final PlutoStateManager stateManager;

  PlutoOnLoadedEvent({
    this.stateManager,
  });
}
