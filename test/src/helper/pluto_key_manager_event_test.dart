import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

void main() {
  late FocusNode focusNode;

  late PlutoKeyManagerEvent? keyManagerEvent;

  KeyEventResult callback(FocusNode node, KeyEvent event) {
    keyManagerEvent = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
      isLogicalKeyPressed: HardwareKeyboard.instance.isLogicalKeyPressed,
    );

    return KeyEventResult.handled;
  }

  setUp(() {
    focusNode = FocusNode();
  });

  tearDown(() {
    keyManagerEvent = null;
  });

  Future<void> buildWidget({
    required WidgetTester tester,
    required FocusOnKeyEventCallback callback,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: FocusScope(
        autofocus: true,
        onKeyEvent: callback,
        child: Focus(
          focusNode: focusNode,
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    ));

    focusNode.requestFocus();
  }

  testWidgets(
    'When any key is pressed, isKeyDownEvent must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.keyE;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isKeyDownEvent, true);
      await tester.sendKeyUpEvent(key);
      expect(keyManagerEvent!.isKeyDownEvent, false);
    },
  );

  testWidgets(
    'When the Home key is pressed, isHome must be `true`.',
    (tester) async {
      late PlutoKeyManagerEvent keyManagerEvent;

      KeyEventResult callback(FocusNode node, KeyEvent event) {
        keyManagerEvent = PlutoKeyManagerEvent(
          focusNode: node,
          event: event,
        );

        return KeyEventResult.handled;
      }

      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.home;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent.isHome, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the End key is pressed, isEnd must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.end;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isEnd, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the F4 key is pressed, isF4 must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.f4;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isF4, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the Backspace key is pressed, isBackspace must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.backspace;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isBackspace, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the Shift key is pressed, isShift must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.shift;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isShift, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the LeftShift key is pressed, isLeftShift must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.shiftLeft;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isLeftShift, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the RightShift key is pressed, isRightShift must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.shiftRight;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isRightShift, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the Control key is pressed, isControl must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.control;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the LeftControl key is pressed, isLeftControl must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isLeftControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When the RightControl key is pressed, isRightControl must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.controlRight;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isRightControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'When Control + C keys are pressed, isCtrlC must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.control;
      const key2 = LogicalKeyboardKey.keyC;

      await tester.sendKeyDownEvent(key);
      await tester.sendKeyDownEvent(key2);

      expect(keyManagerEvent?.isCtrlC, true);

      await tester.sendKeyUpEvent(key);
      await tester.sendKeyUpEvent(key2);
    },
  );

  testWidgets(
    'When Control + V keys are pressed, isCtrlV must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.control;
      const key2 = LogicalKeyboardKey.keyV;

      await tester.sendKeyDownEvent(key);
      await tester.sendKeyDownEvent(key2);

      expect(keyManagerEvent!.isCtrlV, true);
      await tester.sendKeyUpEvent(key);
      await tester.sendKeyUpEvent(key2);
    },
  );

  testWidgets(
    'When Control + A keys are pressed, isCtrlA must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.control;
      const key2 = LogicalKeyboardKey.keyA;

      await tester.sendKeyDownEvent(key);
      await tester.sendKeyDownEvent(key2);

      expect(keyManagerEvent!.isCtrlA, true);

      await tester.sendKeyUpEvent(key);
      await tester.sendKeyUpEvent(key2);
    },
  );
}
