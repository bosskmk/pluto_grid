import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridSetColumnFilterEvent extends PlutoGridEvent {
  PlutoGridSetColumnFilterEvent({required this.filterRows});

  final List<PlutoRow> filterRows;

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
