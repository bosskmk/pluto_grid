import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('PlutoLayout', () {
    testWidgets('offsetHeight', (WidgetTester tester) async {
      // given
      const double maxHeight = 100;

      const double headerHeight = 10;

      const double footerHeight = 10;

      final PlutoLayout layout = PlutoLayout(
        maxHeight: maxHeight,
        headerHeight: headerHeight,
        footerHeight: footerHeight,
      );

      // when
      double offsetHeight = layout.offsetHeight;

      // then
      expect(offsetHeight, maxHeight - headerHeight - footerHeight);
    });
  });
}
