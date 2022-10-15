import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

const selectItems = ['a', 'b', 'c'];

void main() {
  late MockPlutoGridStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();

    when(stateManager.configuration).thenReturn(
      const PlutoGridConfiguration(
        enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,
        enableMoveDownAfterSelecting: false,
      ),
    );
    when(stateManager.keyPressed).thenReturn(PlutoGridKeyPressed());
    when(stateManager.columnHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowHeight).thenReturn(
      stateManager.configuration.style.rowHeight,
    );
    when(stateManager.headerHeight).thenReturn(
      stateManager.configuration.style.columnHeight,
    );
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(
        stateManager.configuration.style.rowHeight,
      ),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  group(
    'enterKeyAction 이 PlutoGridEnterKeyAction.toggleEditing 이고, '
    'enableMoveDownAfterSelecting 가 false 인 상태에서, ',
    () {
      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.select(selectItems),
      );

      final PlutoCell cell = PlutoCell(value: selectItems.first);

      final PlutoRow row = PlutoRow(
        cells: {
          'column_field_name': cell,
        },
      );

      final cellWidget =
          PlutoWidgetTestHelper('Build and tap cell.', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoSelectCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
                row: row,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
      });

      cellWidget.test('F2를 입력하면 팝업이 호출 되어야 한다.', (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(PlutoGrid), findsOneWidget);
      });

      cellWidget.test('팝업 호출 후 ESC 를 입력하면 팝업이 사라져야 한다.', (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(PlutoGrid), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.pumpAndSettle();

        expect(find.byType(PlutoGrid), findsNothing);
      });

      cellWidget.test('팝업 호출 후 ESC 를 입력하고 다시 F2 키로 팝업을 호출하면 팝업이 호출 되어야 한다.',
          (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(PlutoGrid), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);

        await tester.pumpAndSettle();

        expect(find.byType(PlutoGrid), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        await tester.pumpAndSettle();

        expect(find.byType(PlutoGrid), findsOneWidget);
      });

      cellWidget.test(
          '팝업 호출 후 방향키와 엔터키로 아래 아이템을 선택한 후 다시 팝업을 호출하면, '
          '팝업이 호출 되어야 한다.', (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        expect(find.byType(PlutoGrid), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        await tester.pumpAndSettle();

        expect(find.byType(PlutoGrid), findsNothing);
        expect(find.text(selectItems[1]), findsNothing);

        await tester.sendKeyEvent(LogicalKeyboardKey.f2);

        await tester.pumpAndSettle();

        expect(find.byType(PlutoGrid), findsOneWidget);
      });
    },
  );
}
