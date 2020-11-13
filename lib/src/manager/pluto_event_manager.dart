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
    subject.stream.listen(_handler);
  }

  void addEvent(PlutoEvent event) {
    subject.add(event);
  }

  void _handler(PlutoEvent event) {
    event._handler(stateManager);
  }
}
