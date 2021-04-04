import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoGridEvent {
  void handler(PlutoGridStateManager? stateManager);
}
