import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

class _MockScrollController extends Mock implements ScrollController {}

void main() {
  group('selectingModes', () {
    test('Square, Row, None 이 리턴 되야 한다.', () {
      final selectingModes = PlutoGridStateManager.selectingModes;

      expect(selectingModes.contains(PlutoGridSelectingMode.cell), isTrue);
      expect(selectingModes.contains(PlutoGridSelectingMode.row), isTrue);
      expect(selectingModes.contains(PlutoGridSelectingMode.none), isTrue);
    });
  });

  group('PlutoScrollController', () {
    test('bodyRowsVertical', () {
      final PlutoGridScrollController scrollController =
          PlutoGridScrollController();

      ScrollController scroll = _MockScrollController();
      ScrollController anotherScroll = _MockScrollController();

      scrollController.setBodyRowsVertical(scroll);

      expect(scrollController.bodyRowsVertical == scroll, isTrue);
      expect(scrollController.bodyRowsVertical == anotherScroll, isFalse);
      expect(scroll == anotherScroll, isFalse);
    });
  });

  group('PlutoCellPosition', () {
    testWidgets('null 과의 비교는 false 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      final cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      final cellPositionB = null;

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('값이 다른 비교는 false 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      final cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      final cellPositionB = PlutoGridCellPosition(
        columnIdx: 2,
        rowIdx: 1,
      );

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, false);
    });

    testWidgets('값이 동일한 비교는 true 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      final cellPositionA = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      final cellPositionB = PlutoGridCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, true);
    });
  });

  group('PlutoSelectingMode', () {
    test('toShortString', () {
      expect(PlutoGridSelectingMode.cell.toShortString(), 'cell');

      expect(PlutoGridSelectingMode.row.toShortString(), 'row');

      expect(PlutoGridSelectingMode.none.toShortString(), 'none');
    });
  });
}
