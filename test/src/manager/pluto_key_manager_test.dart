import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  FocusNode keyboardFocusNode;

  setUp(() {
    stateManager = MockPlutoStateManager();
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
    when(stateManager.gridFocusNode).thenReturn(FocusNode());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);

    keyboardFocusNode = FocusNode();
  });

  testWidgets(
    'Ctrl + C',
    (WidgetTester tester) async {
      // given
      final PlutoKeyManager keyManager = PlutoKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(KeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentSelectingText).thenReturn('copied');

      String copied;

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = await methodCall.arguments['text'];
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, 'copied');
    },
  );

  testWidgets(
    'Ctrl + C - editing 상태에서는 selectingText 값이 클립보드에 복사 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoKeyManager keyManager = PlutoKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(KeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentSelectingText).thenReturn('copied');

      when(stateManager.isEditing).thenReturn(true);
      expect(stateManager.isEditing, true);

      String copied;

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copied = await methodCall.arguments['text'];
        }
        return null;
      });

      // when
      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(copied, isNull);
    },
  );

  testWidgets(
    'Ctrl + V - pasteCellValue 가 호출 되어야 한다.',
    (WidgetTester tester) async {
      // given
      final PlutoKeyManager keyManager = PlutoKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(KeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(PlutoCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(false);

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, false);
      verify(stateManager.pasteCellValue([
        ['pasted']
      ])).called(1);
    },
  );

  testWidgets(
    'Ctrl + V - currentCell 이 null 이면 pasteCellValue 가 호출 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoKeyManager keyManager = PlutoKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(KeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(null);
      when(stateManager.isEditing).thenReturn(false);

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, null);
      expect(stateManager.isEditing, false);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );

  testWidgets(
    'Ctrl + V - isEditing 이 true 이면 pasteCellValue 가 호출 되지 않는다.',
    (WidgetTester tester) async {
      // given
      final PlutoKeyManager keyManager = PlutoKeyManager(
        stateManager: stateManager,
      );

      keyManager.init();

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RawKeyboardListener(
              onKey: (event) {
                keyManager.subject.add(KeyManagerEvent(
                  focusNode: FocusNode(),
                  event: event,
                ));
              },
              focusNode: keyboardFocusNode,
              child: TextField(),
            ),
          ),
        ),
      );

      when(stateManager.currentCell).thenReturn(PlutoCell(value: 'test'));
      when(stateManager.isEditing).thenReturn(true);

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.getData') {
          return const <String, dynamic>{'text': 'pasted'};
        }
        return null;
      });

      // when
      keyboardFocusNode.requestFocus();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

      // then
      expect(stateManager.currentCell, isNotNull);
      expect(stateManager.isEditing, true);
      verifyNever(stateManager.pasteCellValue([
        ['pasted']
      ]));
    },
  );
}
