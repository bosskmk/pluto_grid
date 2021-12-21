import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

class TestHelperUtil {
  static Type typeOf<T>() => T;

  static Future<void> changeWidth({
    required WidgetTester tester,
    required double width,
    required double height,
  }) async {
    addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

    tester.binding.window.physicalSizeTestValue = Size(width, height);

    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpAndSettle();
  }
}
