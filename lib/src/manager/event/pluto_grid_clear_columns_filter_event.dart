import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// Event to clear the provided columns there filter
class PlutoGridClearColumnsFilterEvent extends PlutoGridEvent {
  final Iterable<PlutoColumn>? columns;
  final int? debounceMilliseconds;
  final PlutoGridEventType? eventType;

  PlutoGridClearColumnsFilterEvent({
    this.columns,
    this.debounceMilliseconds,
    this.eventType,
  }) : super(
          type: eventType ?? PlutoGridEventType.normal,
          duration: Duration(
              milliseconds: debounceMilliseconds?.abs() ??
                  PlutoGridSettings.debounceMillisecondsForColumnFilter),
        );

  @override
  void handler(PlutoGridStateManager stateManager) {
    stateManager.setFilterWithFilterRows([]);
  }
}
