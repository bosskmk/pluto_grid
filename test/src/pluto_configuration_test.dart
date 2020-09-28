import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'dark 생성자를 호출 할 수 있어야 한다.',
    (WidgetTester tester) async {
      final PlutoConfiguration configuration = PlutoConfiguration.dark(
        enableColumnBorder: true,
      );

      expect(configuration.enableColumnBorder, true);
    },
  );
}