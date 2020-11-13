part of '../../pluto_grid.dart';

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
    final stream =
        subject.stream.where((event) => event is! PlutoMoveUpdateEvent);

    final throttleStream = subject.stream
        .where((event) => event is PlutoMoveUpdateEvent)
        .throttleTime(Duration(milliseconds: 800));

    MergeStream([stream, throttleStream]).listen(_handler);
  }

  void addEvent(PlutoEvent event) {
    subject.add(event);
  }

  void _handler(PlutoEvent event) {
    event._handler(stateManager);
  }
}
