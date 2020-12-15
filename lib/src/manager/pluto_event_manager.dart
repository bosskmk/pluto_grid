import 'dart:async';

import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

class PlutoEventManager {
  PlutoStateManager stateManager;

  PlutoEventManager({
    this.stateManager,
  });

  final PublishSubject<PlutoEvent> _subject = PublishSubject<PlutoEvent>();

  PublishSubject<PlutoEvent> get subject => _subject;

  void dispose() {
    _subject.close();
  }

  void init() {
    bool Function(PlutoEvent event) isThrottle = (event) {
      return event is PlutoMoveUpdateEvent;
    };

    final stream = _subject.stream.where((event) => !isThrottle(event));

    final throttleStream = _subject.stream
        .where((event) => isThrottle(event))
        .throttleTime(const Duration(milliseconds: 800));

    MergeStream([stream, throttleStream]).listen(_handler);
  }

  void addEvent(PlutoEvent event) {
    _subject.add(event);
  }

  StreamSubscription<PlutoEvent> listener(
    void onData(PlutoEvent event),
  ) {
    return _subject.stream.listen(onData);
  }

  void _handler(PlutoEvent event) {
    event.handler(stateManager);
  }
}
