import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoEvent {
  void handler(PlutoStateManager stateManager);
}
