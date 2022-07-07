import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'dark 생성자를 호출 할 수 있어야 한다.',
    (WidgetTester tester) async {
      const PlutoGridConfiguration configuration = PlutoGridConfiguration.dark(
        style: PlutoGridStyleConfig(
          enableColumnBorderVertical: false,
        ),
      );

      expect(configuration.style.enableColumnBorderVertical, false);
    },
  );
}
