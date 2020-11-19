import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'child 가 렌더링 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final child = const Text('child widget');

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ShadowContainer(width: 100, height: 50, child: child),
          ),
        ),
      );

      // then
      expect(find.text('child widget'), findsOneWidget);
    },
  );
}
