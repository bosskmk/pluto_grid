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

  void init() {}
}
