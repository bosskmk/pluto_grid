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
    '아무 키나 입력하면 isKeyDownEvent 가 true 여야 한다.',
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
    'Home 키를 입력하면 isHome 이 true 여야 한다.',
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
    'End 키를 입력하면 isEnd 가 true 여야 한다.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.end;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isEnd, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'F4 키를 입력하면 isF4 가 true 여야 한다.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.f4;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isF4, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'Backspace 키를 입력하면 isBackspace 가 true 여야 한다.',
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
    'When the RightShift key is pressed, RightShift must be `true`.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.shiftRight;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isRightShift, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'If the Control key is pressed, isControl should be true.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.control;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'If the controlLeft key is pressed, isLeftControl should be true.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.controlLeft;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isLeftControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'If the controlRight key is pressed, isRightControl should be true.',
    (tester) async {
      await buildWidget(tester: tester, callback: callback);

      const key = LogicalKeyboardKey.controlRight;
      await tester.sendKeyDownEvent(key);
      expect(keyManagerEvent!.isRightControl, true);
      await tester.sendKeyUpEvent(key);
    },
  );

  testWidgets(
    'If the Control + C keys are pressed, isCtrlC should be true.',
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
    'If the Control + V keys are pressed, isCtrlV should be true.',
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
    'If the Control + A keys are pressed, isCtrlA should be true.',
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
