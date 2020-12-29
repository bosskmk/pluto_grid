import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

class MockPlutoEventManager extends Mock implements PlutoGridEventManager {
  @override
  PublishSubject<PlutoGridEvent> get subject => MockPublishSubject();
}

class MockPublishSubject extends Mock
    implements PublishSubject<PlutoGridEvent> {}

class MockStreamSubscription<PlutoEvent> extends Mock
    implements StreamSubscription<PlutoEvent> {}
