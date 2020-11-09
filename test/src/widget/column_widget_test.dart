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
    when(stateManager.localeText).thenReturn(PlutoGridLocaleText());
    when(stateManager.hasCheckedRow).thenReturn(false);
    when(stateManager.hasUnCheckedRow).thenReturn(false);
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
      enableColumnDrag: false,
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
      enableColumnDrag: true,
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

  group('enableRowChecked', () {
    final buildColumn = (bool enable) {
      final column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
        enableRowChecked: enable,
      );

      return PlutoWidgetTestHelper('build column.', (tester) async {
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
      });
    };

    final columnHasNotCheckbox = buildColumn(false);

    columnHasNotCheckbox.test(
      'checkbox 위젯이 이 출력 되지 않아야 한다.',
      (tester) async {
        expect(find.byType(Checkbox), findsNothing);
      },
    );

    final columnHasCheckbox = buildColumn(true);

    columnHasCheckbox.test(
      'checkbox 위젯이 이 출력 되어야 한다.',
      (tester) async {
        expect(find.byType(Checkbox), findsOneWidget);
      },
    );

    columnHasCheckbox.test(
      'checkbox 를 탭하면 toggleAllRowChecked 가 호출 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(Checkbox));

        verify(stateManager.toggleAllRowChecked(true)).called(1);
      },
    );
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
      when(stateManager.rows).thenReturn([
        PlutoRow(cells: {
          'column_field_name': PlutoCell(value: 'cell value'),
        }),
      ]);

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

  group('Drag a column', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      fixed: PlutoColumnFixed.Right,
    );

    final aColumn = PlutoWidgetTestHelper('a column.', (tester) async {
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
    });

    aColumn.test('should be called moveColumn. ', (tester) async {
      await tester.drag(find.byType(Draggable), Offset(50.0, 0.0));

      verify(stateManager.moveColumn(column.key, 50.0 + (column.width / 2)));
    });
  });

  group('Drag a button', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final dragAColumn = (Offset offset) {
      return PlutoWidgetTestHelper('a column.', (tester) async {
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
            of: find.byType(IconButton),
            matching: find.byType(GestureDetector));

        await tester.drag(columnIconGesture, offset);
      });
    };

    /**
     * (기본 값이 4, Positioned 위젯 right -3)
     */
    dragAColumn(
      Offset(50.0, 0.0),
    ).test(
      'resizeColumn 이 54로 호출 되어야 한다.',
      (tester) async {
        verify(stateManager.resizeColumn(column.key, 54.0));
      },
    );

    dragAColumn(
      Offset(-50.0, 0.0),
    ).test(
      'resizeColumn 이 -46으로 호출 되어야 한다.',
      (tester) async {
        verify(stateManager.resizeColumn(column.key, -46.0));
      },
    );
  });

  group('configuration', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      fixed: PlutoColumnFixed.Right,
    );

    final aColumnWithConfiguration = (PlutoConfiguration configuration) {
      return PlutoWidgetTestHelper('a column.', (tester) async {
        when(stateManager.configuration).thenReturn(configuration);

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
      });
    };

    aColumnWithConfiguration(PlutoConfiguration(
      enableColumnBorder: true,
      borderColor: Colors.deepOrange,
    )).test(
      'if enableColumnBorder is true, should be set the border.',
      (tester) async {
        expect(stateManager.configuration.enableColumnBorder, true);

        final target = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        );

        final container = target.evaluate().single.widget as Container;

        final BoxDecoration decoration = container.decoration;

        final Border border = decoration.border;

        expect(border.right.width, 1.0);
        expect(border.right.color, Colors.deepOrange);
      },
    );

    aColumnWithConfiguration(PlutoConfiguration(
      enableColumnBorder: false,
      borderColor: Colors.deepOrange,
    )).test(
      'if enableColumnBorder is false, should not be set the border.',
      (tester) async {
        expect(stateManager.configuration.enableColumnBorder, false);

        final target = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        );

        final container = target.evaluate().single.widget as Container;

        final BoxDecoration decoration = container.decoration;

        final Border border = decoration.border;

        expect(border, null);
      },
    );
  });
}
