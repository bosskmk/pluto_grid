import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('PlutoCellPosition', () {
    testWidgets('null 과의 비교는 false 를 리턴 해야 한다.', (WidgetTester tester) async {
      // given
      final cellPositionA = PlutoCellPosition(
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
      final cellPositionA = PlutoCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      final cellPositionB = PlutoCellPosition(
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
      final cellPositionA = PlutoCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      final cellPositionB = PlutoCellPosition(
        columnIdx: 1,
        rowIdx: 1,
      );

      // when
      final bool compare = cellPositionA == cellPositionB;
      // then

      expect(compare, true);
    });
  });
}
