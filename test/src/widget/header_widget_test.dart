import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../mock/mock_pluto_state_manager.dart';


void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();

    when(stateManager.style).thenReturn(PlutoStyle());
  });

  testWidgets('title 이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: HeaderWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    // then
    final text = find.text('header');
    expect(text, findsOneWidget);
  });

  testWidgets('title 을 탭하면 toggleSortColumn 함수가 호출 되어야 한다.',
      (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: HeaderWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));

    // then
    verify(stateManager.toggleSortColumn(captureAny)).called(1);
  });
}
