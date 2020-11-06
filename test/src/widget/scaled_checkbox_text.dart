import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  testWidgets(
    'checkbox 가 렌더링 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final bool value = false;

      final handleOnChanged = (bool changed) {};

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScaledCheckbox(
              value: value,
              handleOnChanged: handleOnChanged,
            ),
          ),
        ),
      );

      // then
      expect(find.byType(Checkbox), findsOneWidget);
    },
  );

  testWidgets(
    'checkbox 를 탭하면 handleOnChanged 가 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      bool value = false;

      final handleOnChanged = (bool changed) {
        value = changed;
      };

      // when
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScaledCheckbox(
              value: value,
              handleOnChanged: handleOnChanged,
            ),
          ),
        ),
      );

      expect(value, isFalse);

      // then
      await tester.tap(find.byType(Checkbox));

      expect(value, isTrue);
    },
  );
}