import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets('PlutoCannotMoveCurrentCellEvent', (WidgetTester tester) async {
    // given
    final cellPosition = PlutoGridCellPosition(columnIdx: 0, rowIdx: 0);

    final direction = PlutoMoveDirection.right;

    // when
    final event = PlutoGridCannotMoveCurrentCellEvent(
      cellPosition: cellPosition,
      direction: direction,
    );

    // then
    expect(event is PlutoGridEvent, true);
  });
}
