import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets('PlutoCannotMoveCurrentCellEvent', (WidgetTester tester) async {
    // given
    final cellPosition = PlutoCellPosition(columnIdx: 0, rowIdx: 0);

    final direction = MoveDirection.Right;

    // when
    final event = PlutoCannotMoveCurrentCellEvent(
      cellPosition: cellPosition,
      direction: direction,
    );

    // then
    expect(event is PlutoEvent, true);
  });
}
