import 'package:flutter/gestures.dart';
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
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  testWidgets(
      'WHEN If it is not CurrentCell or not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and not in Editing state'
      'THEN Text widget should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TextCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'cell value');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('cell value'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsOneWidget);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [TimeCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: '00:00');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.time(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsOneWidget);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [DateCellWidget] should be rendered', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: '2020-01-01');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.date(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('2020-01-01'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsOneWidget);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [NumberCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 1234);

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.number(),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('1234'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsNothing);
    expect(find.byType(NumberCellWidget), findsOneWidget);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If it is CurrentCell and in Editing state'
      'THEN [SelectCellWidget] should be rendered',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.select(['one', 'two', 'three']),
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(find.text('one'), findsOneWidget);
    expect(find.byType(SelectCellWidget), findsOneWidget);
    expect(find.byType(NumberCellWidget), findsNothing);
    expect(find.byType(DateCellWidget), findsNothing);
    expect(find.byType(TimeCellWidget), findsNothing);
    expect(find.byType(TextCellWidget), findsNothing);
  });

  testWidgets(
      'WHEN If there is no type'
      'THEN An exception should be thrown.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: null,
    );

    final rowIdx = 0;

    // when
    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    expect(tester.takeException(), isInstanceOf<Error>());
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'shift, ctrl 키가 눌리지 않은 상태에서 셀을 탭하면 '
      'THEN '
      'setCurrentSelectingPosition, toggleSelectingRow 이 호출 되지 않는다.',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.isSelectingInteraction()).thenReturn(true);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setCurrentSelectingPosition(
      columnIdx: anyNamed('columnIdx'),
      rowIdx: anyNamed('rowIdx'),
    ));

    verifyNever(stateManager.toggleSelectingRow(any));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'shift 키가 눌린 상태면 '
      'THEN '
      'setCurrentSelectingPosition 이 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final columnIdx = 1;
    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed(
      shift: true,
    ));

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.columnIndex(any)).thenReturn(columnIdx);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verify(stateManager.setCurrentSelectingPosition(
      columnIdx: columnIdx,
      rowIdx: rowIdx,
    ));

    verifyNever(stateManager.toggleSelectingRow(any));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'ctrl 키가 눌린 상태면 '
      'THEN '
      'toggleSelectingRow 이 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final columnIdx = 1;
    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed(
      ctrl: true,
    ));

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.columnIndex(any)).thenReturn(columnIdx);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setCurrentSelectingPosition(
      columnIdx: anyNamed('columnIdx'),
      rowIdx: anyNamed('rowIdx'),
    ));

    verify(stateManager.toggleSelectingRow(any));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'grid mode 가 Select 모드, isCurrentCell 이 true 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'handleOnSelected 은 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Select);

    when(stateManager.isCurrentCell(any)).thenReturn(true);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.handleOnSelected());
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 false 고 '
      'grid mode 가 Select 모드, isCurrentCell 이 true 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'handleOnSelected 은 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Select);

    when(stateManager.isCurrentCell(any)).thenReturn(true);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verify(stateManager.handleOnSelected());
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'grid mode 가 Select 모드, isCurrentCell 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setCurrentCell 은 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Select);

    when(stateManager.isCurrentCell(any)).thenReturn(false);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setCurrentCell(any, any));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 false 고 '
      'grid mode 가 Select 모드, isCurrentCell 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setCurrentCell 은 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 3;

    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Select);

    when(stateManager.isCurrentCell(any)).thenReturn(false);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verify(stateManager.setCurrentCell(cell, rowIdx));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'grid mode 가 Select 모드가 아니고, isCurrentCell 이 true '
      'isEditing 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setEditing 은 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Normal);

    when(stateManager.isCurrentCell(any)).thenReturn(true);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setEditing(true));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 false 고 '
      'grid mode 가 Select 모드가 아니고, isCurrentCell 이 true '
      'isEditing 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setEditing 은 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Normal);

    when(stateManager.isCurrentCell(any)).thenReturn(true);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verify(stateManager.setEditing(true));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'grid mode 가 Select 모드가 아니고, isCurrentCell 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setCurrentCell 은 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Normal);

    when(stateManager.isCurrentCell(any)).thenReturn(false);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setCurrentCell(any, any));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 false 고 '
      'grid mode 가 Select 모드가 아니고, isCurrentCell 이 false 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setCurrentCell 은 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Normal);

    when(stateManager.isCurrentCell(any)).thenReturn(false);

    when(stateManager.isEditing).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verify(stateManager.setCurrentCell(cell, rowIdx));
  });

  testWidgets(
      'WHEN '
      'isSelectingInteraction 이 true 고 '
      'grid mode 가 Select 모드가 아니고, isCurrentCell 이 true, '
      '_isEditing 이 true 인 상태에서 '
      '셀을 탭하면 '
      'THEN '
      'setCurrentCell 은 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isSelectingInteraction()).thenReturn(true);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.keyPressed).thenReturn(PlutoKeyPressed());

    when(stateManager.mode).thenReturn(PlutoMode.Normal);

    when(stateManager.isCurrentCell(any)).thenReturn(true);

    when(stateManager.isEditing).thenReturn(true);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.tap(gesture);

    verifyNever(stateManager.setCurrentCell(any, any));
  });

  testWidgets(
      '셀이 현재 셀이 아니고, 셀을 길게 탭을 하고 '
      'Selecting Row 모드에서 '
      '현재 셀로 설정 되고, '
      'setSelecting, toggleSelectingRow 이 호출 된다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.Row);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.longPress(gesture);

    verify(stateManager.setCurrentCell(cell, rowIdx, notify: false));

    verify(stateManager.setSelecting(true));

    verify(stateManager.toggleSelectingRow(rowIdx));
  });

  testWidgets(
      '셀이 현재 셀이 아니고, 셀을 길게 탭을 하고 '
      'Selecting Row 모드가 아닌 상태면 '
      '현재 셀로 설정 되고, '
      'setSelecting 이 호출 되고 '
      'toggleSelectingRow 이 호출 되지 않는다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(false);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.isSelectedCell(any, any, any)).thenReturn(false);
    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.Square);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.longPress(gesture);

    verify(stateManager.setCurrentCell(cell, rowIdx, notify: false));

    verify(stateManager.setSelecting(true));

    verifyNever(stateManager.toggleSelectingRow(rowIdx));
  });

  testWidgets(
      'WHEN 셀이 현재 셀이고, 셀을 길게 탭을 하면 '
      'THEN setSelecting 이 true 로 호출 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);

    when(stateManager.isSelectingInteraction()).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.longPress(gesture);

    verify(stateManager.setSelecting(true));
  });

  testWidgets(
      'WHEN Row 선택 모드에서, 셀이 현재 셀이고, 셀을 길게 탭을 하면 '
      'THEN setSelecting 이 true, toggleSelectingRow 이 rowIdx 로 호출 되어야 한다.',
      (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.Row);

    when(stateManager.isSelectingInteraction()).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    Finder gesture = find.byType(GestureDetector);

    expect(gesture, findsOneWidget);

    await tester.longPress(gesture);

    verify(stateManager.setSelecting(true));

    verify(stateManager.toggleSelectingRow(rowIdx));
  });

  testWidgets('longPress', (WidgetTester tester) async {
    // given
    final PlutoCell cell = PlutoCell(value: 'one');

    final PlutoColumn column = PlutoColumn(
      title: 'header',
      field: 'header',
      type: PlutoColumnType.text(),
    );

    final rowIdx = 0;

    when(stateManager.isCurrentCell(any)).thenReturn(true);
    when(stateManager.isEditing).thenReturn(false);
    when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.Row);

    when(stateManager.isSelectingInteraction()).thenReturn(false);
    when(stateManager.needMovingScroll(any, any)).thenReturn(false);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: CellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
            rowIdx: rowIdx,
          ),
        ),
      ),
    );

    // then
    final TestGesture gesture = await tester.startGesture(Offset(100, 18));

    await tester.pump(const Duration(milliseconds: 500));

    await gesture.moveBy(const Offset(50, 0));

    await gesture.up();

    await tester.pump();

    await tester.pumpAndSettle(Duration(milliseconds: 800));

    verify(stateManager.setCurrentSelectingPositionWithOffset(any));

    verify(stateManager.needMovingScroll(
      Offset(150.0, 18.0),
      MoveDirection.Left,
    ));

    verify(stateManager.needMovingScroll(
      Offset(150.0, 18.0),
      MoveDirection.Right,
    ));

    verify(stateManager.needMovingScroll(
      Offset(150.0, 18.0),
      MoveDirection.Up,
    ));

    verify(stateManager.needMovingScroll(
      Offset(150.0, 18.0),
      MoveDirection.Down,
    ));
  });

  group('configuration', () {
    PlutoCell cell;

    PlutoColumn column;

    int rowIdx;

    final aCellWithConfiguration = (
      PlutoConfiguration configuration, {
      bool isCurrentCell = true,
      bool isSelectedCell = false,
      bool readOnly = false,
    }) {
      return PlutoWidgetTestHelper('a cell.', (tester) async {
        when(stateManager.isCurrentCell(any)).thenReturn(isCurrentCell);
        when(stateManager.isSelectedCell(any, any, any))
            .thenReturn(isSelectedCell);
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isEditing).thenReturn(true);

        cell = PlutoCell(value: 'one');

        column = PlutoColumn(
          title: 'header',
          field: 'header',
          type: PlutoColumnType.text(
            readOnly: readOnly,
          ),
        );

        rowIdx = 0;

        when(stateManager.configuration).thenReturn(configuration);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: CellWidget(
                stateManager: stateManager,
                cell: cell,
                column: column,
                rowIdx: rowIdx,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(Duration(seconds: 1));
      });
    };

    aCellWithConfiguration(
      PlutoConfiguration(
        enableColumnBorder: false,
        borderColor: Colors.deepOrange,
      ),
      readOnly: true,
    ).test(
      'if readOnly is true, should be set the color to cellColorInReadOnlyState.',
      (tester) async {
        expect(column.type.readOnly, true);

        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        );

        final container = target.evaluate().first.widget as Container;

        final BoxDecoration decoration = container.decoration;

        final Color color = decoration.color;

        expect(color, stateManager.configuration.cellColorInReadOnlyState);
      },
    );

    aCellWithConfiguration(
      PlutoConfiguration(
        enableColumnBorder: true,
        borderColor: Colors.deepOrange,
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'if isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is true, '
      'should be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        );

        final container = target.evaluate().first.widget as Container;

        final BoxDecoration decoration = container.decoration;

        final Border border = decoration.border;

        expect(border.right.color, stateManager.configuration.borderColor);
      },
    );

    aCellWithConfiguration(
      PlutoConfiguration(
        enableColumnBorder: false,
        borderColor: Colors.deepOrange,
      ),
      isCurrentCell: false,
      isSelectedCell: false,
    ).test(
      'if isCurrentCell, isSelectedCell are false '
      'and enableColumnBorder is false, '
      'should not be set the border.',
      (tester) async {
        final target = find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        );

        final container = target.evaluate().first.widget as Container;

        final BoxDecoration decoration = container.decoration;

        final Border border = decoration.border;

        expect(border, isNull);
      },
    );
  });
}
