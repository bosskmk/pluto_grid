import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../matcher/pluto_object_matcher.dart';
import '../../../mock/mock_pluto_event_manager.dart';
import '../../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;
  PlutoEventManager eventManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
    eventManager = MockPlutoEventManager();
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
    when(stateManager.localeText).thenReturn(PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  group('기본 셀 테스트', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: 'default cell value');

    final cellWidget = PlutoWidgetTestHelper('cell widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: DefaultCellWidget(
              stateManager: stateManager,
              cell: cell,
              column: column,
            ),
          ),
        ),
      );
    });

    cellWidget.test(
      'Text 위젯이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(Text), findsOneWidget);
        expect(find.text('default cell value'), findsOneWidget);
      },
    );

    cellWidget.test(
      'enableRowDrag 이 기본 값(false) 인 경우 Draggable 위젯이 렌더링 되지 않아야 한다.',
      (tester) async {
        expect(find.byType(Draggable), findsNothing);
      },
    );

    cellWidget.test(
      'enableRowChecked 이 기본 값(false) 인 경우 Checkbox 위젯이 렌더링 되지 않아야 한다.',
      (tester) async {
        expect(find.byType(Checkbox), findsNothing);
      },
    );
  });

  group('renderer', () {
    final buildCellWidgetWithRenderer =
        (Widget Function(PlutoColumnRendererContext) renderer) {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
        renderer: renderer,
      );

      final PlutoCell cell = PlutoCell(value: 'default cell value');

      return PlutoWidgetTestHelper('cell widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: DefaultCellWidget(
                stateManager: stateManager,
                cell: cell,
                column: column,
              ),
            ),
          ),
        );
      });
    };

    final renderText = buildCellWidgetWithRenderer(
        (PlutoColumnRendererContext rendererContext) {
      return Text('renderer value');
    });

    renderText.test(
      'renderer 에서 리턴한 위젯이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('renderer value'), findsOneWidget);
      },
    );

    final renderTextWithCellValue = buildCellWidgetWithRenderer(
        (PlutoColumnRendererContext rendererContext) {
      return Text(rendererContext.cell.value);
    });

    renderTextWithCellValue.test(
      'renderer 에서 리턴한 위젯이 cell value 와 함께 출력 되어야 한다.',
      (tester) async {
        expect(find.text('default cell value'), findsOneWidget);
      },
    );
  });

  group('enableRowDrag', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
      enableRowDrag: true,
    );

    final PlutoCell cell = PlutoCell(value: 'default cell value');

    final cellWidget = ({
      bool hasSortedColumn,
    }) {
      return PlutoWidgetTestHelper('cell widget', (tester) async {
        when(stateManager.hasSortedColumn).thenReturn(hasSortedColumn);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: DefaultCellWidget(
                stateManager: stateManager,
                cell: cell,
                column: column,
              ),
            ),
          ),
        );
      });
    };

    cellWidget(hasSortedColumn: false).test(
      '정렬 된 컬럼이 없는 경우 Draggable 위젯이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(Draggable), findsOneWidget);
      },
    );

    cellWidget(hasSortedColumn: true).test(
      '정렬 된 컬럼이 있는 경우 Draggable 위젯이 렌더링 되지 않아야 한다.',
      (tester) async {
        expect(find.byType(Draggable), findsNothing);
      },
    );

    cellWidget(hasSortedColumn: false).test(
      'Draggable 아이콘을 드래그 하지 않으면 PlutoDragEvent 가 호출 되지 않아야 한다.',
      (tester) async {
        final row = PlutoRow(cells: {});

        when(stateManager.getRowByIdx(any)).thenReturn(row);
        when(stateManager.isSelectedRow(any)).thenReturn(false);

        await tester.tap(find.byType(Icon));
        await tester.longPress(find.byType(Icon));

        // tester.tap triggers onDragStarted, onDragEnd.
        // It only needs to be called Update, so it is ignored.

        verifyNever(eventManager.addEvent(
          argThat(PlutoObjectMatcher<PlutoDragEvent>(rule: (object) {
            return object.dragType.isUpdate;
          })),
        ));
      },
    );

    cellWidget(hasSortedColumn: false).test(
      'Draggable 아이콘을 드래그 하면 PlutoDragEvent 가 호출 되어야 한다.',
      (tester) async {
        final offset = Offset(0.0, 100);

        final row = PlutoRow(cells: {});

        when(stateManager.getRowByIdx(any)).thenReturn(row);
        when(stateManager.isSelectedRow(any)).thenReturn(false);

        await tester.drag(find.byType(Icon), offset);

        verify(eventManager.addEvent(
          argThat(PlutoObjectMatcher<PlutoDragEvent>(rule: (object) {
            return object.dragType.isStart &&
                object.itemType.isRows &&
                object.dragData.length == 1 &&
                object.dragData.first.key == row.key;
          })),
        )).called(1);

        verify(eventManager.addEvent(
          argThat(PlutoObjectMatcher<PlutoDragEvent>(rule: (object) {
            return object.dragType.isUpdate &&
                object.itemType.isRows &&
                object.offset.dy > 100 &&
                object.dragData.length == 1 &&
                object.dragData.first.key == row.key;
          })),
        )).called(greaterThan(1));

        verify(eventManager.addEvent(
          argThat(PlutoObjectMatcher<PlutoDragEvent>(rule: (object) {
            return object.offset.dy > 100 &&
                object.dragType.isEnd &&
                object.itemType.isRows &&
                object.dragData.length == 1 &&
                object.dragData.first.key == row.key;
          })),
        )).called(1);
      },
    );

    cellWidget(hasSortedColumn: false).test(
      'Draggable 아이콘을 드래그 하면 isCurrentRowSelected 이 true 인 경우'
      'currentSelectingRows 로 PlutoDragEvent 가 호출 되어야 한다.',
      (tester) async {
        final offset = Offset(0.0, 100);

        final rows = [
          PlutoRow(cells: {}),
          PlutoRow(cells: {}),
          PlutoRow(cells: {}),
        ];

        when(stateManager.getRowByIdx(any)).thenReturn(rows.first);
        when(stateManager.isSelectedRow(any)).thenReturn(true);
        when(stateManager.currentSelectingRows).thenReturn(rows);

        await tester.drag(find.byType(Icon), offset);

        verify(eventManager.addEvent(
          argThat(PlutoObjectMatcher<PlutoDragEvent>(rule: (object) {
            return object.dragType.isUpdate &&
                object.itemType.isRows &&
                object.offset.dy > 100 &&
                object.dragData.length == 3 &&
                object.dragData[0].key == rows[0].key &&
                object.dragData[1].key == rows[1].key &&
                object.dragData[1].key == rows[1].key;
          })),
        )).called(greaterThan(1));
      },
    );
  });

  group('enableRowChecked', () {
    PlutoRow row;

    final buildCellWidget = (bool checked) {
      return PlutoWidgetTestHelper('cell widget', (tester) async {
        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.text(),
          enableRowChecked: true,
        );

        final PlutoCell cell = PlutoCell(value: 'default cell value');

        row = PlutoRow(
          cells: {},
          checked: checked,
        );

        when(stateManager.getRowByIdx(any)).thenReturn(row);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: DefaultCellWidget(
                stateManager: stateManager,
                cell: cell,
                column: column,
              ),
            ),
          ),
        );
      });
    };

    final checkedCellWidget = buildCellWidget(true);

    checkedCellWidget.test(
      'Checkbox 위젯이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.byType(Checkbox), findsOneWidget);
      },
    );

    checkedCellWidget.test(
      'Checkbox 를 탭하면 true 에서 false 로 변경 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(Checkbox));

        expect(row.checked, isTrue);

        verify(stateManager.setRowChecked(row, false)).called(1);
      },
    );

    final uncheckedCellWidget = buildCellWidget(false);

    uncheckedCellWidget.test(
      'Checkbox 를 탭하면 false 에서 true 로 변경 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(Checkbox));

        expect(row.checked, isFalse);

        verify(stateManager.setRowChecked(row, true)).called(1);
      },
    );
  });
}
