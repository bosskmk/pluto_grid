import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridChangeColumnSortEvent extends PlutoGridEvent {
  PlutoGridChangeColumnSortEvent({
    required this.column,
    required this.oldSort,
  });

  final PlutoColumn column;

  final PlutoColumnSort oldSort;

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
