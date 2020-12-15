import 'dart:async';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

class PlutoEventManager {
  PlutoStateManager stateManager;

  PlutoEventManager({
    this.stateManager,
  });

  PublishSubject<PlutoEvent> subject = PublishSubject<PlutoEvent>();

  void dispose() {
    subject.close();
  }

  void init() {
    bool Function(PlutoEvent event) isThrottle = (event) {
      return event is PlutoMoveUpdateEvent;
    };

    final stream = subject.stream.where((event) => !isThrottle(event));

    final throttleStream = subject.stream
        .where((event) => isThrottle(event))
        .throttleTime(const Duration(milliseconds: 800));

    MergeStream([stream, throttleStream]).listen(_handler);
  }

  void addEvent(PlutoEvent event) {
    subject.add(event);
  }

  StreamSubscription<PlutoEvent> listener(
    void onData(PlutoEvent event),
  ) {
    return subject.stream.listen(onData);
  }

  void _handler(PlutoEvent event) {
    event.handler(stateManager);
  }
}
