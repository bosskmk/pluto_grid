import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../helper/test_helper_util.dart';
import '../../../matcher/pluto_object_matcher.dart';
import 'pluto_default_cell_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
  MockSpec<PlutoGridEventManager>(returnNullOnMissingStub: true),
])
void main() {
  late MockPlutoGridStateManager stateManager;
  MockPlutoGridEventManager? eventManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    eventManager = MockPlutoGridEventManager();
    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.configuration).thenReturn(const PlutoGridConfiguration());
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(stateManager.configuration!.rowHeight),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
    when(stateManager.canRowDrag).thenReturn(true);
    when(stateManager.rowHeight).thenReturn(0);
    when(stateManager.currentSelectingRows).thenReturn([]);
    when(stateManager.isCurrentCell(any)).thenReturn(false);
  });

  group('기본 셀 테스트', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: 'default cell value');

    final PlutoRow row = PlutoRow(
      cells: {
        'column_field_name': cell,
      },
    );

    final cellWidget = PlutoWidgetTestHelper('cell widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChangeNotifierProvider<PlutoGridStateManager>.value(
              value: stateManager,
              child: PlutoDefaultCell(
                cell: cell,
                column: column,
                row: row,
                rowIdx: 0,
              ),
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
    buildCellWidgetWithRenderer(
      Widget Function(PlutoColumnRendererContext) renderer,
    ) {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.text(),
        renderer: renderer,
      );

      final PlutoCell cell = PlutoCell(value: 'default cell value');

      final PlutoRow row = PlutoRow(
        cells: {
          'column_field_name': cell,
        },
      );

      return PlutoWidgetTestHelper('cell widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: ChangeNotifierProvider<PlutoGridStateManager>.value(
                value: stateManager,
                child: PlutoDefaultCell(
                  cell: cell,
                  column: column,
                  row: row,
                  rowIdx: 0,
                ),
              ),
            ),
          ),
        );
      });
    }

    final renderText = buildCellWidgetWithRenderer(
        (PlutoColumnRendererContext rendererContext) {
      return const Text('renderer value');
    });

    renderText.test(
      'renderer 에서 리턴한 위젯이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('renderer value'), findsOneWidget);
      },
    );

    final renderTextWithCellValue = buildCellWidgetWithRenderer(
        (PlutoColumnRendererContext rendererContext) {
      return Text(rendererContext.cell.value.toString());
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

    final PlutoRow row = PlutoRow(
      cells: {
        'column_field_name': cell,
      },
    );

    cellWidget({
      bool? canRowDrag,
    }) {
      return PlutoWidgetTestHelper('cell widget', (tester) async {
        when(stateManager.canRowDrag).thenReturn(canRowDrag!);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: ChangeNotifierProvider<PlutoGridStateManager>.value(
                value: stateManager,
                child: PlutoDefaultCell(
                  cell: cell,
                  column: column,
                  row: row,
                  rowIdx: 0,
                ),
              ),
            ),
          ),
        );
      });
    }

    cellWidget(canRowDrag: true).test(
      'canRowDrag 가 true 인 경우 Draggable 위젯이 렌더링 되어야 한다.',
      (tester) async {
        expect(
          find.byType(TestHelperUtil.typeOf<Draggable<PlutoRow>>()),
          findsOneWidget,
        );
      },
    );

    cellWidget(canRowDrag: false).test(
      'canRowDrag 가 false 인 경우 Draggable 위젯이 렌더링 되지 않아야 한다.',
      (tester) async {
        expect(
          find.byType(TestHelperUtil.typeOf<Draggable<PlutoRow>>()),
          findsNothing,
        );
      },
    );

    cellWidget(canRowDrag: true).test(
      'Draggable 아이콘을 드래그 하지 않으면 PlutoGridScrollUpdateEvent 가 호출 되지 않아야 한다.',
      (tester) async {
        when(stateManager.getRowByIdx(any)).thenReturn(row);
        when(stateManager.isSelectedRow(any)).thenReturn(false);

        await tester.tap(find.byType(Icon));
        await tester.longPress(find.byType(Icon));

        // tester.tap triggers onDragStarted, onDragEnd.
        // It only needs to be called Update, so it is ignored.

        verifyNever(eventManager!.addEvent(
          argThat(
              PlutoObjectMatcher<PlutoGridScrollUpdateEvent>(rule: (object) {
            return true;
          })),
        ));
      },
    );

    cellWidget(canRowDrag: true).test(
      'Draggable 아이콘을 드래그 하면 PlutoGridScrollUpdateEvent 가 호출 되어야 한다.',
      (tester) async {
        const offset = Offset(0.0, 100);

        when(stateManager.getRowByIdx(any)).thenReturn(row);
        when(stateManager.isSelectedRow(any)).thenReturn(false);
        when(stateManager.isSelecting).thenReturn(false);

        await tester.drag(find.byType(Icon), offset);

        verify(stateManager.setIsDraggingRow(true, notify: false)).called(1);

        verify(stateManager.setDragRows(
          [row],
        )).called(1);

        verify(eventManager!.addEvent(
          argThat(
              PlutoObjectMatcher<PlutoGridScrollUpdateEvent>(rule: (object) {
            return true;
          })),
        )).called(greaterThan(1));

        verify(stateManager.getRowIdxByOffset(any)).called(greaterThan(1));

        verify(stateManager.setDragTargetRowIdx(any)).called(greaterThan(1));
      },
    );
  });

  group('enableRowChecked', () {
    PlutoRow? row;

    buildCellWidget(bool checked) {
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
              child: ChangeNotifierProvider<PlutoGridStateManager>.value(
                value: stateManager,
                child: PlutoDefaultCell(
                  cell: cell,
                  column: column,
                  row: row!,
                  rowIdx: 0,
                ),
              ),
            ),
          ),
        );
      });
    }

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

        expect(row!.checked, isTrue);

        verify(stateManager.setRowChecked(row, false)).called(1);
      },
    );

    final uncheckedCellWidget = buildCellWidget(false);

    uncheckedCellWidget.test(
      'Checkbox 를 탭하면 false 에서 true 로 변경 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(Checkbox));

        expect(row!.checked, isFalse);

        verify(stateManager.setRowChecked(row, true)).called(1);
      },
    );
  });
}
