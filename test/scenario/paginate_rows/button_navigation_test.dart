import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/column_helper.dart';
import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/row_helper.dart';

void fillNumbers(List<PlutoRow> rows, String columnName) {
  int num = -1;

  for (var element in rows) {
    element.cells[columnName]?.value = ++num;
  }
}

List<TextButton> buttonsToWidgets(Finder pageButtons) {
  return pageButtons
      .evaluate()
      .map((e) => e.widget)
      .cast<TextButton>()
      .toList();
}

String? textFromTextButton(TextButton button) {
  return (button.child as Text).data;
}

TextStyle textStyleFromTextButton(TextButton button) {
  return (button.child as Text).style as TextStyle;
}

void main() {
  group('숫자 버튼으로 페이지 이동 테스트', () {
    List<PlutoColumn> columns;

    List<PlutoRow> rows;

    PlutoGridStateManager? stateManager;

    late Finder pageButtons;

    late Color defaultButtonColor;

    late Color activateButtonColor;

    const headerName = 'header0';

    final grid = PlutoWidgetTestHelper(
      '100개 행과 기본 페이지 크기 40',
      (tester) async {
        columns = [
          ...ColumnHelper.textColumn('header', count: 1),
        ];

        rows = RowHelper.count(100, columns);

        fillNumbers(rows, headerName);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager!;
                },
                createFooter: (_stateManager) => PlutoPagination(_stateManager),
              ),
            ),
          ),
        );

        pageButtons = find.byType(TextButton);

        defaultButtonColor = stateManager!.configuration!.iconColor;

        activateButtonColor = stateManager!.configuration!.activatedBorderColor;
      },
    );

    grid.test('PlutoPagination 위젯이 렌더링 되어야 한다.', (tester) async {
      expect(find.byType(PlutoPagination), findsOneWidget);
    });

    grid.test('페이징 버튼이 3개 렌더링 되어야 한다.', (tester) async {
      expect(pageButtons, findsNWidgets(3));
    });

    grid.test('페이징 버튼이 1,2,3 이 렌더링 되어야 한다.', (tester) async {
      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      expect(textFromTextButton(pageButtonsAsTextButton[0]), '1');
      expect(textFromTextButton(pageButtonsAsTextButton[1]), '2');
      expect(textFromTextButton(pageButtonsAsTextButton[2]), '3');
    });

    grid.test('1번 페이징 버튼이 활성화 되어야 한다.', (tester) async {
      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

      expect(style1.color, activateButtonColor);
    });

    grid.test('2, 3번 페이징 버튼은 비 활성화 되어야 한다.', (tester) async {
      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

      final style3 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

      expect(style2.color, defaultButtonColor);

      expect(style3.color, defaultButtonColor);
    });

    grid.test('100 개의 행의 셀 값이 0~99 까지 설정 되어야 한다.', (tester) async {
      // 테스트를 위해 셀 값을 순서대로 0~99 까지 설정.
      final _rows = stateManager!.refRows!.originalList;

      expect(_rows[0]!.cells[headerName]!.value, 0);

      expect(_rows[50]!.cells[headerName]!.value, 50);

      expect(_rows[99]!.cells[headerName]!.value, 99);
    });

    grid.test('첫페이지의 행이 40개 렌더링 되어야 한다.', (tester) async {
      final _rows = stateManager!.rows;

      expect(_rows.first!.cells[headerName]!.value, 0);

      expect(_rows.last!.cells[headerName]!.value, 39);

      expect(_rows.length, 40);
    });

    grid.test('2 페이지로 이동 하면 2번 페이징 버튼이 활성화 되어야 한다.', (tester) async {
      await tester.tap(pageButtons.at(1));

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

      expect(style1.color, defaultButtonColor);

      final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

      expect(style2.color, activateButtonColor);
    });

    grid.test('2 페이지로 이동 하면 현재 행의 셀 값이 40~79 까지 렌더링 되어야 한다.', (tester) async {
      await tester.tap(pageButtons.at(1));

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      final _rows = stateManager!.rows;

      expect(_rows.length, 40);

      expect(_rows.first!.cells[headerName]!.value, 40);

      expect(_rows.last!.cells[headerName]!.value, 79);
    });

    grid.test('3 페이지로 이동 하면 3번 페이징 버튼이 활성화 되어야 한다.', (tester) async {
      await tester.tap(pageButtons.at(2));

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      List<TextButton> pageButtonsAsTextButton = buttonsToWidgets(pageButtons);

      final style1 = textStyleFromTextButton(pageButtonsAsTextButton[0]);

      expect(style1.color, defaultButtonColor);

      final style2 = textStyleFromTextButton(pageButtonsAsTextButton[1]);

      expect(style2.color, defaultButtonColor);

      final style3 = textStyleFromTextButton(pageButtonsAsTextButton[2]);

      expect(style3.color, activateButtonColor);
    });

    grid.test('3 페이지로 이동 하면 현재 행의 셀 값이 80~99 까지 렌더링 되어야 한다.', (tester) async {
      await tester.tap(pageButtons.at(2));

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      final _rows = stateManager!.rows;

      expect(_rows.length, 20);

      expect(_rows.first!.cells[headerName]!.value, 80);

      expect(_rows.last!.cells[headerName]!.value, 99);
    });
  });
}
