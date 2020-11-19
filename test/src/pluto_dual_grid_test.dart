import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/pluto_widget_test_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets(
    '두개의 그리드가 생성 되고 셀이 출력 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final gridAColumns = ColumnHelper.textColumn('headerA');
      final gridARows = RowHelper.count(3, gridAColumns);

      final gridBColumns = ColumnHelper.textColumn('headerB');
      final gridBRows = RowHelper.count(3, gridBColumns);

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Container(
              child: PlutoDualGrid(
                gridPropsA: PlutoDualGridProps(
                  columns: gridAColumns,
                  rows: gridARows,
                ),
                gridPropsB: PlutoDualGridProps(
                  columns: gridBColumns,
                  rows: gridBRows,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // then
      final gridACell1 = find.text('headerA0 value 0');
      expect(gridACell1, findsOneWidget);

      final gridACell2 = find.text('headerA0 value 1');
      expect(gridACell2, findsOneWidget);

      final gridACell3 = find.text('headerA0 value 2');
      expect(gridACell3, findsOneWidget);

      final gridBCell1 = find.text('headerB0 value 0');
      expect(gridBCell1, findsOneWidget);

      final gridBCell2 = find.text('headerB0 value 1');
      expect(gridBCell2, findsOneWidget);

      final gridBCell3 = find.text('headerB0 value 2');
      expect(gridBCell3, findsOneWidget);
    },
  );

  group(
    '그리드간 셀 이동 테스트',
    () {
      PlutoStateManager stateManagerA;
      PlutoStateManager stateManagerB;

      group('왼쪽 그리드의', () {
        final leftGridCellSelected =
            PlutoWidgetTestHelper('첫번째 셀이 선택 된 상태에서', (tester) async {
          final gridAColumns = ColumnHelper.textColumn('headerA', count: 3);
          final gridARows = RowHelper.count(3, gridAColumns);

          final gridBColumns = ColumnHelper.textColumn('headerB', count: 3);
          final gridBRows = RowHelper.count(3, gridBColumns);

          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: Container(
                  child: PlutoDualGrid(
                    gridPropsA: PlutoDualGridProps(
                      columns: gridAColumns,
                      rows: gridARows,
                      onLoaded: (PlutoOnLoadedEvent event) =>
                          stateManagerA = event.stateManager,
                    ),
                    gridPropsB: PlutoDualGridProps(
                      columns: gridBColumns,
                      rows: gridBRows,
                      onLoaded: (PlutoOnLoadedEvent event) =>
                          stateManagerB = event.stateManager,
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('headerA0 value 0'));
        });

        leftGridCellSelected.test(
          '우측 끝으로 이동 후 한번 더 우측 방향키를 입력하면,'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 한번 더 우측 방향키를 입력하면,'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

            expect(stateManagerA.gridFocusNode.hasFocus, isTrue);
            expect(stateManagerB.gridFocusNode.hasFocus, isFalse);

            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);

            expect(stateManagerA.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            expect(stateManagerB.currentCell.value, 'headerB0 value 0');
          },
        );

        leftGridCellSelected.test(
          '우측 끝으로 이동 후 탭 키를 입력하면'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 탭 키를 입력하면'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);

            expect(stateManagerA.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            expect(stateManagerB.currentCell.value, 'headerB0 value 0');
          },
        );

        leftGridCellSelected.test(
          '우측 끝으로 이동 후 탭 키를 입력하면'
          '포커스가 우측 그리드로 바뀌어야 한다.'
          '그리고 쉬프트 + 탭 키를 입력하면'
          '우측 그리드의 첫번째 셀이 선택 되어야 한다.'
          '이어스 쉬프트 + 탭 키를 입력 하면'
          '다시 왼쪽 그리드로 포커스가 바뀌어야 한다.',
          (tester) async {
            // 0 > 1
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            // 1 > 2
            await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            // 2 > right grid
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);

            expect(stateManagerA.gridFocusNode.hasFocus, isFalse);
            expect(stateManagerB.gridFocusNode.hasFocus, isTrue);

            // right grid > 0
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
            expect(stateManagerB.currentCell.value, 'headerB0 value 0');

            // right grid > left grid
            await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
            await tester.sendKeyEvent(LogicalKeyboardKey.tab);
            await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);

            expect(stateManagerA.gridFocusNode.hasFocus, isTrue);
            expect(stateManagerB.gridFocusNode.hasFocus, isFalse);
          },
        );
      });
    },
  );

  group('PlutoDualGridDisplayRatio', () {
    test('ratio 가 0 인 경우 assert 에러', () {
      expect(() {
        PlutoDualGridDisplayRatio(ratio: 0);
      }, throwsA(isA<AssertionError>()));
    });

    test('ratio 가 1 인 경우 assert 에러', () {
      expect(() {
        PlutoDualGridDisplayRatio(ratio: 1);
      }, throwsA(isA<AssertionError>()));
    });

    test('ratio 가 0.5 인 경우 width 가 5:5', () {
      final display = const PlutoDualGridDisplayRatio(ratio: 0.5);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('ratio 가 0.1 인 경우 width 가 1:9', () {
      final display = const PlutoDualGridDisplayRatio(ratio: 0.1);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 20);
      expect(display.gridBWidth(size), 180);
    });
  });

  group('PlutoDualGridDisplayFixedAndExpanded', () {
    test('width 가 100', () {
      final display = const PlutoDualGridDisplayFixedAndExpanded(width: 100);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('width 가 50', () {
      final display = const PlutoDualGridDisplayFixedAndExpanded(width: 50);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 50);
      expect(display.gridBWidth(size), 150);
    });
  });

  group('PlutoDualGridDisplayExpandedAndFixed', () {
    test('width 가 100', () {
      final display = const PlutoDualGridDisplayExpandedAndFixed(width: 100);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 100);
      expect(display.gridBWidth(size), 100);
    });

    test('width 가 50', () {
      final display = const PlutoDualGridDisplayExpandedAndFixed(width: 50);

      final size = const BoxConstraints(maxWidth: 200);

      expect(display.gridAWidth(size), 150);
      expect(display.gridBWidth(size), 50);
    });
  });
}
