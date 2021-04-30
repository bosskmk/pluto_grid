import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

class MockScrollPosition extends Mock implements ScrollPosition {
  @override
  double get maxScrollExtent =>
      (super.noSuchMethod(Invocation.getter(#position), returnValue: 0.0)
          as double);
}

class MockScrollController extends Mock implements ScrollController {
  @override
  ScrollPosition get position =>
      (super.noSuchMethod(Invocation.getter(#position),
          returnValue: MockScrollPosition()) as ScrollPosition);
}

class MockLinkedScrollControllerGroup extends Mock
    implements LinkedScrollControllerGroup {
  @override
  double get offset =>
      (super.noSuchMethod(Invocation.getter(#verticalOffset), returnValue: 0.0)
          as double);
}

class MockPlutoScrollController extends Mock
    implements PlutoGridScrollController {
  @override
  LinkedScrollControllerGroup get vertical => MockLinkedScrollControllerGroup();

  @override
  ScrollController get bodyRowsVertical => MockScrollController();

  @override
  LinkedScrollControllerGroup get horizontal =>
      MockLinkedScrollControllerGroup();

  @override
  double get verticalOffset =>
      (super.noSuchMethod(Invocation.getter(#verticalOffset), returnValue: 0.0)
          as double);

  @override
  double get maxScrollHorizontal =>
      (super.noSuchMethod(Invocation.getter(#verticalOffset), returnValue: 0.0)
          as double);

  @override
  double get maxScrollVertical =>
      (super.noSuchMethod(Invocation.getter(#verticalOffset), returnValue: 0.0)
          as double);
}
