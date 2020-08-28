part of '../../pluto_grid.dart';

class PlutoKeyManager {
  PlutoStateManager stateManager;

  PlutoKeyManager({
    this.stateManager,
  });

  PublishSubject<KeyManagerEvent> subject = PublishSubject<KeyManagerEvent>();

  void dispose() {
    subject.close();
  }

  void init() {
    subject.stream.listen(_handler);
  }

  void _handler(KeyManagerEvent keyManagerEvent) {
    if (keyManagerEvent.event.runtimeType == RawKeyDownEvent ||
        keyManagerEvent.event.runtimeType == RawKeyUpEvent) {
      stateManager.setKeyPressed(PlutoKeyPressed(
        shift: keyManagerEvent.event.isShiftPressed,
      ));
    }

    if (keyManagerEvent.event.runtimeType == RawKeyDownEvent) {
      if (keyManagerEvent.isMoving) {
        _handleMoving(keyManagerEvent);
      } else if (keyManagerEvent.isEnter) {
        _handleEnter(keyManagerEvent);
      } else if (keyManagerEvent.isTab) {
        _handleTab(keyManagerEvent);
      } else if (keyManagerEvent.isEsc) {
        _handleEsc(keyManagerEvent);
      } else if (keyManagerEvent.isF2) {
        if (!stateManager.isEditing) {
          stateManager.setEditing(true);
        }
      } else if (keyManagerEvent.isCharacter) {
        if (keyManagerEvent.isCtrlC) {
          _handleCtrlC(keyManagerEvent);
        } else if (keyManagerEvent.isCtrlV) {
          _handleCtrlV(keyManagerEvent);
        } else {
          _handleCharacter(keyManagerEvent);
        }
      }
    }
  }

  void _handleMoving(KeyManagerEvent keyManagerEvent) {
    MoveDirection moveDirection;

    if (keyManagerEvent.isLeft) {
      moveDirection = MoveDirection.Left;
    } else if (keyManagerEvent.isRight) {
      moveDirection = MoveDirection.Right;
    } else if (keyManagerEvent.isUp) {
      moveDirection = MoveDirection.Up;
    } else if (keyManagerEvent.isDown) {
      moveDirection = MoveDirection.Down;
    } else {
      return;
    }

    if (keyManagerEvent.event.isShiftPressed) {
      stateManager.moveSelectingCell(moveDirection);
    } else {
      stateManager.moveCurrentCell(moveDirection);
    }
  }

  void _handleEnter(KeyManagerEvent keyManagerEvent) {
    // SelectRow 모드인 경우 현재 Row 를 onSelected 콜백에 전달.
    if (stateManager.mode.isSelectRow) {
      stateManager._onSelected(PlutoOnSelectedEvent(
        row: stateManager.currentRow,
      ));
      return;
    }

    // 셀 수정 상태에서 엔터키 입력 시 아래 또는 위 셀로 이동.
    if (stateManager.isEditing) {
      // 한글을 마지막으로 입력한 상태에서 포커스 변경 없이 키 이벤트 발생하면 두번 발생
      // web 에서만 문제. 버그인거 같음. 고쳐지면 아래 코드 삭제.
      final lastChildContext = keyManagerEvent.focusNode.children.last.context;

      if (kIsWeb &&
          lastChildContext is StatefulElement &&
          lastChildContext?.dirty != true &&
          lastChildContext.widget is EditableText) {
        stateManager.gridFocusNode.unfocus();
        developer.log('TODO',
            name: 'data_grid', error: 'Web 에서 한글 입력 시 엔터 두번 오류.');
      }

      if (keyManagerEvent.event.isShiftPressed) {
        stateManager.moveCurrentCell(MoveDirection.Up);
      } else {
        stateManager.moveCurrentCell(MoveDirection.Down);
      }
    }

    stateManager.toggleEditing();
  }

  void _handleTab(KeyManagerEvent keyManagerEvent) {
    final saveIsEditing = stateManager._isEditing;

    if (keyManagerEvent.event.isShiftPressed) {
      stateManager.moveCurrentCell(MoveDirection.Left, force: true);
    } else {
      stateManager.moveCurrentCell(MoveDirection.Right, force: true);
    }

    stateManager.setEditing(saveIsEditing);
  }

  void _handleEsc(KeyManagerEvent keyManagerEvent) {
    if (stateManager.mode.isSelectRow) {
      stateManager._onSelected(PlutoOnSelectedEvent(
        row: null,
      ));
      return;
    }

    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }

    if (keyManagerEvent.focusNode.children.last.context.widget
        is EditableText) {
      (keyManagerEvent.focusNode.children.last.context.widget as EditableText)
          .controller
          .text = stateManager.cellValueBeforeEditing.toString();

      stateManager.changeCellValue(
          stateManager.currentCell._key, stateManager.cellValueBeforeEditing);
    }
  }

  void _handleCtrlC(KeyManagerEvent keyManagerEvent) {
    if (stateManager.currentSelectingPosition != null) {
      Clipboard.setData(
          new ClipboardData(text: stateManager.currentSelectingText));
    } else if (stateManager.currentCell != null) {
      Clipboard.setData(
          new ClipboardData(text: stateManager.currentCell.value.toString()));
    }
  }

  void _handleCtrlV(KeyManagerEvent keyManagerEvent) {
    if (stateManager.currentCell == null) {
      return;
    }

    Clipboard.getData('text/plain').then((value) {
      List<List<String>> textList =
          ClipboardTransformation.stringToList(value.text);

      stateManager.pasteCellValue(textList);
    });
  }

  void _handleCharacter(KeyManagerEvent keyManagerEvent) {
    if (stateManager.isEditing != true && stateManager.currentCell != null) {
      stateManager.setEditing(true);

      stateManager.changeCellValue(stateManager.currentCell._key,
          keyManagerEvent.event.logicalKey.keyLabel);
    }
  }
}

class KeyManagerEvent {
  FocusNode focusNode;
  RawKeyEvent event;

  KeyManagerEvent({
    this.focusNode,
    this.event,
  });
}

extension KeyManagerEventExtention on KeyManagerEvent {
  bool get isMoving => this.isHorizontal || this.isVertical;

  bool get isHorizontal => this.isLeft || this.isRight;

  bool get isVertical => this.isUp || this.isDown;

  bool get isLeft =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.arrowLeft.keyId;

  bool get isRight =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.arrowRight.keyId;

  bool get isUp =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.arrowUp.keyId;

  bool get isDown =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.arrowDown.keyId;

  bool get isEsc =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.escape.keyId;

  bool get isEnter =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.enter.keyId;

  bool get isTab => this.event.logicalKey.keyId == LogicalKeyboardKey.tab.keyId;

  bool get isF2 => this.event.logicalKey.keyId == LogicalKeyboardKey.f2.keyId;

  bool get isCharacter => this.event.logicalKey.keyLabel != null;

  bool get isCtrlC {
    return (this.event.isMetaPressed || this.event.isControlPressed) &&
        this.event.logicalKey.keyId == LogicalKeyboardKey.keyC.keyId;
  }

  bool get isCtrlV {
    return (this.event.isMetaPressed || this.event.isControlPressed) &&
        this.event.logicalKey.keyId == LogicalKeyboardKey.keyV.keyId;
  }
}
