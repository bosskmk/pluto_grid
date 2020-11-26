import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
    when(stateManager.rowTotalHeight).thenReturn(
      RowHelper.resolveRowTotalHeight(stateManager.configuration.rowHeight),
    );
    when(stateManager.localeText).thenReturn(const PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  group('기본 date 컬럼', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.date(),
    );

    final PlutoCell cell = PlutoCell(value: '2020-01-01');

    final tapCell = PlutoWidgetTestHelper('Tap cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoDateCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
            ),
          ),
        ),
      );
    });

    tapCell.test('2020-01-01 이 출력 되어야 한다.', (tester) async {
      expect(find.text('2020-01-01'), findsOneWidget);
    });

    tapCell.test('탭하면 팝업이 호출 되어 년월일이 출력 되어야 한다.', (tester) async {
      await tester.tap(find.byType(TextField));

      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      expect(find.text('2020-01-01'), findsNWidgets(2));
    });

    tapCell.test('탭하면 팝업이 호출 되어 요일이 출력 되어야 한다.', (tester) async {
      await tester.tap(find.byType(TextField));

      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      expect(find.text('Su'), findsOneWidget);
      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('Tu'), findsOneWidget);
      expect(find.text('We'), findsOneWidget);
      expect(find.text('Th'), findsOneWidget);
      expect(find.text('Fr'), findsOneWidget);
      expect(find.text('Sa'), findsOneWidget);
    });
  });

  group('format MM/dd/yyyy', () {
    final makeDateCell = (String date) {
      PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.date(format: 'MM/dd/yyyy'),
      );

      PlutoCell cell = PlutoCell(value: date);

      return PlutoWidgetTestHelper('DateCell 생성', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoDateCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
              ),
            ),
          ),
        );
      });
    };

    makeDateCell('01/30/2020').test(
      '01/30/2020 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('01/30/2020'), findsOneWidget);
      },
    );

    makeDateCell('06/15/2020').test(
      '06/15/2020 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('06/15/2020'), findsOneWidget);
      },
    );

    makeDateCell('01/30/2020').test(
      '탭하면 팝업이 호출 되어 년월일이 출력 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        expect(find.text('01/30/2020'), findsNWidgets(2));
      },
    );

    makeDateCell('09/12/2020').test(
      '탭하면 팝업이 호출 되어 년월일이 출력 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        expect(find.text('09/12/2020'), findsNWidgets(2));
      },
    );

    makeDateCell('01/30/2020').test(
      '탭하면 팝업이 호출 되어 요일이 출력 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        expect(find.text('Su'), findsOneWidget);
        expect(find.text('Mo'), findsOneWidget);
        expect(find.text('Tu'), findsOneWidget);
        expect(find.text('We'), findsOneWidget);
        expect(find.text('Th'), findsOneWidget);
        expect(find.text('Fr'), findsOneWidget);
        expect(find.text('Sa'), findsOneWidget);
      },
    );

    makeDateCell('01/30/2020').test(
      '위쪽 방향키를 입력하고 엔터를 입력하면 1월 23이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '01/23/2020'))
            .called(1);
      },
    );

    makeDateCell('01/30/2020').test(
      '아래쪽 방향키를 입력하고 엔터를 입력하면 2월 06이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '02/06/2020'))
            .called(1);
      },
    );

    makeDateCell('01/30/2020').test(
      '왼쪽 방향키를 입력하고 엔터를 입력하면 1월 29이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '01/29/2020'))
            .called(1);
      },
    );

    makeDateCell('01/30/2020').test(
      '오른쪽 방향키를 입력하고 엔터를 입력하면 1월 31이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '01/31/2020'))
            .called(1);
      },
    );

    makeDateCell('01/31/2020').test(
      '오른쪽 방향키를 입력하고 엔터를 입력하면 2월 01이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '02/01/2020'))
            .called(1);
      },
    );
  });

  group('format yyyy년 MM월 dd일', () {
    final makeDateCell = (String date) {
      PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.date(format: 'yyyy년 MM월 dd일'),
      );

      PlutoCell cell = PlutoCell(value: date);

      return PlutoWidgetTestHelper('DateCell 생성', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoDateCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
              ),
            ),
          ),
        );
      });
    };

    makeDateCell('2020년 12월 01일').test(
      '2020년 12월 01일 이 출력 되어야 한다.',
      (tester) async {
        expect(find.text('2020년 12월 01일'), findsOneWidget);
      },
    );

    makeDateCell('2020년 12월 01일').test(
      '왼쪽 방향키를 입력하고 엔터를 입력하면 11월 30이 선택 되어야 한다.',
      (tester) async {
        await tester.tap(find.byType(TextField));

        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);

        verify(stateManager.handleAfterSelectingRow(any, '2020년 11월 30일'))
            .called(1);
      },
    );
  });
}
