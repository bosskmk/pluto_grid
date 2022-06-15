import 'package:pluto_grid/pluto_grid.dart';

enum PlutoGridEventType {
  normal,
  throttle,
  debounce,
}

extension PlutoGridEventTypeExtension on PlutoGridEventType {
  bool get isNormal => this == PlutoGridEventType.normal;

  bool get isThrottle => this == PlutoGridEventType.throttle;

  bool get isDebounce => this == PlutoGridEventType.debounce;
}

abstract class PlutoGridEvent {
  PlutoGridEvent({
    this.type = PlutoGridEventType.normal,
    this.duration,
  }) : assert(
          type.isNormal || duration != null,
          'If type is normal or type is not normal then duration is required.',
        );

  final PlutoGridEventType type;

  final Duration? duration;

  void handler(PlutoGridStateManager stateManager);
}
