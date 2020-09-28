import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'originalValue',
    (WidgetTester tester) async {
      final PlutoCell cell = PlutoCell(value: 'value');
      expect(cell.originalValue, 'value');
    },
  );

  testWidgets(
    'originalValue 가 있는 경우 originalValue 을 리턴 해야 한다.',
    (WidgetTester tester) async {
      final PlutoCell cell = PlutoCell(
        value: 'value',
        originalValue: 'original value',
      );

      expect(cell.value, 'value');
      expect(cell.originalValue, 'original value');
    },
  );

  testWidgets(
    'originalValue 가 없는 경우 value 를 리턴 해야 한다.',
    (WidgetTester tester) async {
      final PlutoCell cell = PlutoCell(
        value: 'value',
      );

      expect(cell.value, 'value');
      expect(cell.originalValue, 'value');
    },
  );

  testWidgets(
    '셀 값 변경 시 originalValue 는 변경 되지 않는다.',
    (WidgetTester tester) async {
      final PlutoCell cell = PlutoCell(
        value: 'value',
        originalValue: 'original value',
      );

      cell.value = 'changed value';

      expect(cell.value, 'changed value');
      expect(cell.originalValue, 'original value');
    },
  );
}
