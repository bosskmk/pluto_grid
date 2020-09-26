import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
  });

  testWidgets('컬럼 타이틀이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ColumnWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    // then
    expect(find.text('column title'), findsOneWidget);
  });

  testWidgets('ColumnIcon 이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ColumnWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    // then
    expect(find.byType(ColumnIcon), findsOneWidget);
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
          child: ColumnWidget(
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
      'InkWell 위젯이 없어야 한다.', (WidgetTester tester) async {
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
          child: ColumnWidget(
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
          child: ColumnWidget(
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
          child: ColumnWidget(
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

  testWidgets('enableContextMenu 이 false 면 ColumnIcon 이 출력 되지 않아야 한다.',
      (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      enableContextMenu: false,
    );

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ColumnWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    // then
    expect(find.byType(ColumnIcon), findsNothing);
  });

  testWidgets('enableContextMenu 이 true 면 ColumnIcon 이 출력 되어야 한다.',
      (WidgetTester tester) async {
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
          child: ColumnWidget(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );

    // then
    final headerIcon = find.byType(ColumnIcon);

    expect(headerIcon, findsOneWidget);
  });

  group('고정 컬럼이 아닌 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final tapColumn = PlutoWidgetTestHelper('Tap column.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ColumnWidget(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      final columnIconGesture = find.ancestor(
          of: find.byType(IconButton), matching: find.byType(GestureDetector));

      await tester.tap(columnIconGesture);
    });

    tapColumn.test('기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('ToLeft'), findsOneWidget);
      expect(find.text('ToRight'), findsOneWidget);
      expect(find.text('AutoSize'), findsOneWidget);
    });

    tapColumn.test('ToLeft 를 탭하면 toggleFixedColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('ToLeft'));

      verify(stateManager.toggleFixedColumn(
        column.key,
        PlutoColumnFixed.Left,
      )).called(1);
    });

    tapColumn.test('ToRight 를 탭하면 toggleFixedColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('ToRight'));

      verify(stateManager.toggleFixedColumn(
        column.key,
        PlutoColumnFixed.Right,
      )).called(1);
    });

    tapColumn.test('AutoSize 를 탭하면 resizeColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([]);

      await tester.tap(find.text('AutoSize'));

      verify(stateManager.resizeColumn(
        column.key,
        argThat(isA<double>()),
      )).called(1);
    });
  });

  group('왼쪽 고정 컬럼인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      fixed: PlutoColumnFixed.Left,
    );

    final tapColumn = PlutoWidgetTestHelper('Tap column.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ColumnWidget(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      final columnIconGesture = find.ancestor(
          of: find.byType(IconButton), matching: find.byType(GestureDetector));

      await tester.tap(columnIconGesture);
    });

    tapColumn.test('고정 컬럼의 기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('Unfix'), findsOneWidget);
      expect(find.text('ToLeft'), findsNothing);
      expect(find.text('ToRight'), findsNothing);
      expect(find.text('AutoSize'), findsOneWidget);
    });

    tapColumn.test('Unfix 를 탭하면 toggleFixedColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Unfix'));

      verify(stateManager.toggleFixedColumn(
        column.key,
        PlutoColumnFixed.None,
      )).called(1);
    });

    tapColumn.test('AutoSize 를 탭하면 resizeColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([]);

      await tester.tap(find.text('AutoSize'));

      verify(stateManager.resizeColumn(
        column.key,
        argThat(isA<double>()),
      )).called(1);
    });
  });

  group('우측 고정 컬럼인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      fixed: PlutoColumnFixed.Right,
    );

    final tapColumn = PlutoWidgetTestHelper('Tap column.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ColumnWidget(
              stateManager: stateManager,
              column: column,
            ),
          ),
        ),
      );

      final columnIconGesture = find.ancestor(
          of: find.byType(IconButton), matching: find.byType(GestureDetector));

      await tester.tap(columnIconGesture);
    });

    tapColumn.test('고정 컬럼의 기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('Unfix'), findsOneWidget);
      expect(find.text('ToLeft'), findsNothing);
      expect(find.text('ToRight'), findsNothing);
      expect(find.text('AutoSize'), findsOneWidget);
    });

    tapColumn.test('Unfix 를 탭하면 toggleFixedColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Unfix'));

      verify(stateManager.toggleFixedColumn(
        column.key,
        PlutoColumnFixed.None,
      )).called(1);
    });

    tapColumn.test('AutoSize 를 탭하면 resizeColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([]);

      await tester.tap(find.text('AutoSize'));

      verify(stateManager.resizeColumn(
        column.key,
        argThat(isA<double>()),
      )).called(1);
    });
  });
}
