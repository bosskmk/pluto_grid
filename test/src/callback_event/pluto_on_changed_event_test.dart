import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    '생성자를 호출 할 수 있어야 한다.',
    (WidgetTester tester) async {
      final PlutoOnChangedEvent onChangedEvent = PlutoOnChangedEvent(
        columnIdx: null,
        rowIdx: 1,
      );

      expect(onChangedEvent.columnIdx, null);
      expect(onChangedEvent.rowIdx, 1);
    },
  );
}
