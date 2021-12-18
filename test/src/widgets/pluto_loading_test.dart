import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';

void main() {
  buildWidget({
    Color? backgroundColor,
    Color? indicatorColor,
    String? indicatorText,
    double? indicatorSize,
  }) {
    return PlutoWidgetTestHelper('build widget.', (tester) async {
      final widget = PlutoLoading(
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
        indicatorText: indicatorText,
        indicatorSize: indicatorSize,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: widget,
          ),
        ),
      );
    });
  }

  buildWidget().test(
    'Parameter 를 전달 하지 않는 경우 기본 값으로 위젯이 생성 되어야 한다.',
    (tester) async {
      final text = find.byType(Text).evaluate().first.widget as Text;
      final coloredBox =
          find.byType(ColoredBox).evaluate().first.widget as ColoredBox;
      final container =
          find.byType(Container).evaluate().first.widget as Container;
      final decoration = container.decoration as BoxDecoration;

      expect(text.data, 'Loading...');
      expect(coloredBox.color, Colors.white);
      expect(decoration.color, Colors.white);
      expect(decoration.border!.top.color, Colors.black);
      expect(decoration.border!.bottom.color, Colors.black);
    },
  );

  buildWidget(backgroundColor: Colors.green).test(
    'backgroundColor 를 전달 하면 배경 색이 변경 되어야 한다.',
    (tester) async {
      final coloredBox =
          find.byType(ColoredBox).evaluate().first.widget as ColoredBox;
      final container =
          find.byType(Container).evaluate().first.widget as Container;
      final decoration = container.decoration as BoxDecoration;

      expect(coloredBox.color, Colors.green);
      expect(decoration.color, Colors.green);
    },
  );

  buildWidget(indicatorColor: Colors.red).test(
    'indicatorColor 를 전달 하면 텍스트와 border color 가 변경 되어야 한다.',
    (tester) async {
      final text = find.byType(Text).evaluate().first.widget as Text;
      final container =
          find.byType(Container).evaluate().first.widget as Container;
      final decoration = container.decoration as BoxDecoration;

      expect(text.style!.color, Colors.red);
      expect(decoration.border!.top.color, Colors.red);
    },
  );

  buildWidget(indicatorText: '로딩중...').test(
    'indicatorText 를 전달 하면 텍스트가 변경 되어야 한다.',
    (tester) async {
      final text = find.byType(Text).evaluate().first.widget as Text;

      expect(text.data, '로딩중...');
    },
  );

  buildWidget(indicatorSize: 20.0).test(
    'indicatorSize 를 전달 하면 텍스트 크기가 변경 되어야 한다.',
    (tester) async {
      final text = find.byType(Text).evaluate().first.widget as Text;

      expect(text.style!.fontSize, 20.0);
    },
  );
}
