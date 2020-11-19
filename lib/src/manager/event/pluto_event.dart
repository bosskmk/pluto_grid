part of '../../../pluto_grid.dart';

abstract class PlutoEvent {
  void _handler(PlutoStateManager stateManager);

  @visibleForTesting
  void handler(PlutoStateManager stateManager) {
    _handler(stateManager);
  }
}
