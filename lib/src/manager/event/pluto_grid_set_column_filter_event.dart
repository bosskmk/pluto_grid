import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// If the value of [PlutoGridStateManager.filterOnlyEvent] is true,
/// an event is issued.
/// [PlutoInfinityScrollRows] or [PlutoLazyPagination] Event
/// for delegating filtering processing to widgets.
class PlutoGridSetColumnFilterEvent extends PlutoGridEvent {
  PlutoGridSetColumnFilterEvent({required this.filterRows});

  final List<PlutoRow> filterRows;

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
