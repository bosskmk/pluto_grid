import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
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

  testWidgets(
      'enableSorting 가 기본값 true 인 상태에서 '
      'title 을 탭하면 toggleSortColumn 함수가 호출 되어야 한다.',
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

  testWidgets(
      'enableSorting 가 false 인 상태에서 '
      'InkWell 위젯이 없어야 한다.',
      (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
      enableSorting: false,
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

    Finder inkWell = find.byType(InkWell);

    // then
    expect(inkWell, findsNothing);

    verifyNever(stateManager.toggleSortColumn(captureAny));
  });

  testWidgets(
      'WHEN Column 이 enableDraggable false'
      'THEN Draggable 이 노출 되지 않아야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
      enableDraggable: false,
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
    final draggable = find.byType(Draggable);

    expect(draggable, findsNothing);
  });

  testWidgets(
      'WHEN Column 이 enableDraggable true'
      'THEN Draggable 이 노출 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
      enableDraggable: true,
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
    final draggable = find.byType(Draggable);

    expect(draggable, findsOneWidget);
  });

  testWidgets(
      'WHEN Column 이 enableContextMenu false'
      'THEN HeaderIcon 이 노출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
      enableContextMenu: false,
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
    final headerIcon = find.byType(HeaderIcon);

    expect(headerIcon, findsNothing);
  });

  testWidgets(
      'WHEN Column 이 enableContextMenu true'
      'THEN HeaderIcon 이 노출 된다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
      enableContextMenu: true,
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
    final headerIcon = find.byType(HeaderIcon);

    expect(headerIcon, findsOneWidget);
  });
}
