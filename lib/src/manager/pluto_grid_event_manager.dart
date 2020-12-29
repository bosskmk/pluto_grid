import 'dart:async';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

class PlutoGridEventManager {
  PlutoGridStateManager stateManager;

  PlutoGridEventManager({
    this.stateManager,
  });

  final PublishSubject<PlutoGridEvent> _subject =
      PublishSubject<PlutoGridEvent>();

  PublishSubject<PlutoGridEvent> get subject => _subject;

  void dispose() {
    _subject.close();
  }

  void init() {
    bool Function(PlutoGridEvent event) isThrottle = (event) {
      return event is PlutoGridMoveUpdateEvent;
    };

    final stream = _subject.stream.where((event) => !isThrottle(event));

    final throttleStream = _subject.stream
        .where((event) => isThrottle(event))
        .throttleTime(const Duration(milliseconds: 800));

    MergeStream([stream, throttleStream]).listen(_handler);
  }

  void addEvent(PlutoGridEvent event) {
    _subject.add(event);
  }

  StreamSubscription<PlutoGridEvent> listener(
    void onData(PlutoGridEvent event),
  ) {
    return _subject.stream.listen(onData);
  }

  void _handler(PlutoGridEvent event) {
    event.handler(stateManager);
  }
}
