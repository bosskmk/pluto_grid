import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

class MockScrollController extends Mock implements ScrollController {}

class MockLinkedScrollControllerGroup extends Mock
    implements LinkedScrollControllerGroup {}

class MockPlutoScrollController extends Mock implements PlutoScrollController {
  @override
  LinkedScrollControllerGroup get vertical => MockLinkedScrollControllerGroup();

  @override
  ScrollController get bodyRowsVertical => MockScrollController();

  @override
  LinkedScrollControllerGroup get horizontal =>
      MockLinkedScrollControllerGroup();
}
