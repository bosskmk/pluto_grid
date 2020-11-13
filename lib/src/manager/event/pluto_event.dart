part of '../../../pluto_grid.dart';

abstract class PlutoEvent {
  void _handler(PlutoStateManager stateManager);
}
