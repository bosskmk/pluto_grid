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
}
