import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/test_helper_util.dart';
import 'pluto_column_title_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
  MockSpec<PlutoGridScrollController>(returnNullOnMissingStub: true),
  MockSpec<LinkedScrollControllerGroup>(returnNullOnMissingStub: true),
])
void main() {
  late MockPlutoGridStateManager stateManager;
  late MockPlutoGridScrollController scroll;
  late MockLinkedScrollControllerGroup horizontalScroll;
  late PublishSubject<PlutoStreamNotifierEvent> subject;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    scroll = MockPlutoGridScrollController();
    horizontalScroll = MockLinkedScrollControllerGroup();
    subject = PublishSubject<PlutoStreamNotifierEvent>();

    when(stateManager.configuration).thenReturn(const PlutoGridConfiguration());
    when(stateManager.streamNotifier).thenAnswer((_) => subject);
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.hasCheckedRow).thenReturn(false);
    when(stateManager.hasUnCheckedRow).thenReturn(false);
    when(stateManager.hasFilter).thenReturn(false);
    when(stateManager.columnHeight).thenReturn(45);
    when(stateManager.isInvalidHorizontalScroll).thenReturn(false);
    when(stateManager.scroll).thenReturn(scroll);
    when(scroll.maxScrollHorizontal).thenReturn(0);
    when(scroll.horizontal).thenReturn(horizontalScroll);
    when(horizontalScroll.offset).thenReturn(0);
    when(stateManager.isFilteredColumn(any)).thenReturn(false);
  });

  tearDown(() {
    subject.close();
  });

  MaterialApp buildApp({
    required PlutoColumn column,
  }) {
    return MaterialApp(
      home: Material(
        child: ChangeNotifierProvider<PlutoGridStateManager>.value(
          value: stateManager,
          child: PlutoColumnTitle(
            stateManager: stateManager,
            column: column,
          ),
        ),
      ),
    );
  }

  testWidgets('컬럼 타이틀이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    // when
    await tester.pumpWidget(
      buildApp(column: column),
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
      buildApp(column: column),
    );

    // then
    expect(find.byType(PlutoGridColumnIcon), findsOneWidget);
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
      buildApp(column: column),
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
      buildApp(column: column),
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
      buildApp(column: column),
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
      buildApp(column: column),
    );

    // then
    final draggable = find.byType(
      TestHelperUtil.typeOf<Draggable<PlutoColumn>>(),
    );

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
      buildApp(column: column),
    );

    // then
    expect(find.byType(PlutoGridColumnIcon), findsNothing);
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
      buildApp(column: column),
    );

    // then
    final headerIcon = find.byType(PlutoGridColumnIcon);

    expect(headerIcon, findsOneWidget);
  });

  group('enableRowChecked', () {
    buildColumn(bool enable) {
      final column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
        enableRowChecked: enable,
      );

      return PlutoWidgetTestHelper('build column.', (tester) async {
        await tester.pumpWidget(
          buildApp(column: column),
        );
      });
    }

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
      when(stateManager.refColumns)
          .thenReturn(FilteredList(initialList: [column]));

      await tester.pumpWidget(
        buildApp(column: column),
      );

      final columnIcon = find.byType(PlutoGridColumnIcon);

      final gesture = await tester.startGesture(tester.getCenter(columnIcon));

      await gesture.up();
    });

    tapColumn.test('기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('Freeze to left'), findsOneWidget);
      expect(find.text('Freeze to right'), findsOneWidget);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    tapColumn.test('Freeze to left 를 탭하면 toggleFrozenColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Freeze to left'));

      verify(stateManager.toggleFrozenColumn(
        column.key,
        PlutoColumnFrozen.left,
      )).called(1);
    });

    tapColumn.test('Freeze to right 를 탭하면 toggleFrozenColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Freeze to right'));

      verify(stateManager.toggleFrozenColumn(
        column.key,
        PlutoColumnFrozen.right,
      )).called(1);
    });

    tapColumn.test('Auto fit 를 탭하면 autoFitColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([
        PlutoRow(cells: {
          'column_field_name': PlutoCell(value: 'cell value'),
        }),
      ]);

      await tester.tap(find.text('Auto fit'));

      verify(stateManager.autoFitColumn(
        argThat(isA<BuildContext>()),
        column,
      )).called(1);
    });
  });

  group('왼쪽 고정 컬럼인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      frozen: PlutoColumnFrozen.left,
    );

    final tapColumn = PlutoWidgetTestHelper('Tap column.', (tester) async {
      when(stateManager.refColumns)
          .thenReturn(FilteredList(initialList: [column]));

      await tester.pumpWidget(
        buildApp(column: column),
      );

      final columnIcon = find.byType(PlutoGridColumnIcon);

      final gesture = await tester.startGesture(tester.getCenter(columnIcon));

      await gesture.up();
    });

    tapColumn.test('고정 컬럼의 기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('Unfreeze'), findsOneWidget);
      expect(find.text('Freeze to left'), findsNothing);
      expect(find.text('Freeze to right'), findsNothing);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    tapColumn.test('Unfreeze 를 탭하면 toggleFrozenColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Unfreeze'));

      verify(stateManager.toggleFrozenColumn(
        column.key,
        PlutoColumnFrozen.none,
      )).called(1);
    });

    tapColumn.test('Auto fit 를 탭하면 autoFitColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([]);

      await tester.tap(find.text('Auto fit'));

      verify(stateManager.autoFitColumn(
        argThat(isA<BuildContext>()),
        column,
      )).called(1);
    });
  });

  group('우측 고정 컬럼인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      frozen: PlutoColumnFrozen.right,
    );

    final tapColumn = PlutoWidgetTestHelper('Tap column.', (tester) async {
      when(stateManager.refColumns)
          .thenReturn(FilteredList(initialList: [column]));

      await tester.pumpWidget(
        buildApp(column: column),
      );

      final columnIcon = find.byType(PlutoGridColumnIcon);

      final gesture = await tester.startGesture(tester.getCenter(columnIcon));

      await gesture.up();
    });

    tapColumn.test('고정 컬럼의 기본 메뉴가 출력 되어야 한다.', (tester) async {
      expect(find.text('Unfreeze'), findsOneWidget);
      expect(find.text('Freeze to left'), findsNothing);
      expect(find.text('Freeze to right'), findsNothing);
      expect(find.text('Auto fit'), findsOneWidget);
    });

    tapColumn.test('Unfreeze 를 탭하면 toggleFrozenColumn 이 호출 되어야 한다.',
        (tester) async {
      await tester.tap(find.text('Unfreeze'));

      verify(stateManager.toggleFrozenColumn(
        column.key,
        PlutoColumnFrozen.none,
      )).called(1);
    });

    tapColumn.test('Auto fit 를 탭하면 autoFitColumn 이 호출 되어야 한다.', (tester) async {
      when(stateManager.rows).thenReturn([]);

      await tester.tap(find.text('Auto fit'));

      verify(stateManager.autoFitColumn(
        argThat(isA<BuildContext>()),
        column,
      )).called(1);
    });
  });

  group('Drag a column', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      frozen: PlutoColumnFrozen.right,
    );

    final aColumn = PlutoWidgetTestHelper('a column.', (tester) async {
      await tester.pumpWidget(
        buildApp(column: column),
      );
    });

    aColumn.test(
      'When dragging and dropping to the same column, moveColumn should not be called.',
      (tester) async {
        await tester.drag(
          find.byType(TestHelperUtil.typeOf<Draggable<PlutoColumn>>()),
          const Offset(50.0, 0.0),
        );

        verifyNever(stateManager.moveColumn(
          column: column,
          targetColumn: column,
        ));
      },
    );
  });

  group('Drag a button', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    dragAColumn(Offset offset) {
      return PlutoWidgetTestHelper('a column.', (tester) async {
        await tester.pumpWidget(
          buildApp(column: column),
        );

        final columnIcon = find.byType(PlutoGridColumnIcon);

        await tester.drag(columnIcon, offset);
      });
    }

    /**
     * (기본 값이 4, Positioned 위젯 right -3)
     */
    dragAColumn(
      const Offset(50.0, 0.0),
    ).test(
      'resizeColumn 이 30 이상으로 호출 되어야 한다.',
      (tester) async {
        verify(stateManager.resizeColumn(
          column,
          argThat(greaterThanOrEqualTo(30)),
          notify: false,
          checkScroll: false,
        ));
      },
    );

    dragAColumn(
      const Offset(-50.0, 0.0),
    ).test(
      'resizeColumn 이 -30 이하로 호출 되어야 한다.',
      (tester) async {
        verify(stateManager.resizeColumn(
          column,
          argThat(lessThanOrEqualTo(-30)),
          notify: false,
          checkScroll: false,
        ));
      },
    );
  });

  group('configuration', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      frozen: PlutoColumnFrozen.right,
    );

    aColumnWithConfiguration(PlutoGridConfiguration configuration) {
      return PlutoWidgetTestHelper('a column.', (tester) async {
        when(stateManager.configuration).thenReturn(configuration);

        await tester.pumpWidget(
          buildApp(column: column),
        );
      });
    }

    aColumnWithConfiguration(const PlutoGridConfiguration(
      enableColumnBorder: true,
      borderColor: Colors.deepOrange,
    )).test(
      'if enableColumnBorder is true, should be set the border.',
      (tester) async {
        expect(stateManager.configuration!.enableColumnBorder, true);

        final target = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        );

        final container = target.evaluate().single.widget as Container;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final Border border = decoration.border as Border;

        expect(border.right.width, 1.0);
        expect(border.right.color, Colors.deepOrange);
      },
    );

    aColumnWithConfiguration(const PlutoGridConfiguration(
      enableColumnBorder: false,
      borderColor: Colors.deepOrange,
    )).test(
      'if enableColumnBorder is false, should not be set the border.',
      (tester) async {
        expect(stateManager.configuration!.enableColumnBorder, false);

        final target = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container),
        );

        final container = target.evaluate().single.widget as Container;

        final BoxDecoration decoration = container.decoration as BoxDecoration;

        final Border border = decoration.border as Border;

        expect(border.right, BorderSide.none);
      },
    );
  });
}
