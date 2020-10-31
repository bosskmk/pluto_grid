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
    if (keyManagerEvent.isKeyDownEvent || keyManagerEvent.isKeyUpEvent) {
      stateManager.setKeyPressed(PlutoKeyPressed(
        shift: keyManagerEvent.isShiftPressed,
        ctrl: keyManagerEvent.isCtrlPressed,
      ));
    }

    if (keyManagerEvent.isKeyDownEvent) {
      if (keyManagerEvent.isMoving) {
        _handleMoving(keyManagerEvent);
      } else if (keyManagerEvent.isEnter) {
        _handleEnter(keyManagerEvent);
      } else if (keyManagerEvent.isTab) {
        _handleTab(keyManagerEvent);
      } else if (keyManagerEvent.isHome || keyManagerEvent.isEnd) {
        _handleHomeEnd(keyManagerEvent);
      } else if (keyManagerEvent.isPageUp || keyManagerEvent.isPageDown) {
        _handlePageUpDown(keyManagerEvent);
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
        } else if (keyManagerEvent.isCtrlA) {
          _handleCtrlA(keyManagerEvent);
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
      if (stateManager.isEditing == true) {
        return;
      }

      stateManager.moveSelectingCell(moveDirection);
      return;
    }

    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    stateManager.moveCurrentCell(moveDirection);
  }

  void _handleHomeEnd(KeyManagerEvent keyManagerEvent) {
    if (keyManagerEvent.isHome) {
      if (keyManagerEvent.isCtrlPressed) {
        if (keyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(MoveDirection.Up);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(MoveDirection.Up);
        }
      } else {
        if (keyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfColumns(MoveDirection.Left);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Left);
        }
      }
    } else if (keyManagerEvent.isEnd) {
      if (keyManagerEvent.isCtrlPressed) {
        if (keyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(MoveDirection.Down);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(MoveDirection.Down);
        }
      } else {
        if (keyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfColumns(MoveDirection.Right);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(MoveDirection.Right);
        }
      }
    }
  }

  void _handlePageUpDown(KeyManagerEvent keyManagerEvent) {
    final int moveCount =
        (stateManager.offsetHeight / PlutoDefaultSettings.rowTotalHeight)
            .floor();

    final direction =
        keyManagerEvent.isPageUp ? MoveDirection.Up : MoveDirection.Down;

    if (keyManagerEvent.isShiftPressed) {
      int rowIdx = stateManager.currentSelectingPosition?.rowIdx ??
          stateManager.currentCellPosition?.rowIdx ??
          0;

      rowIdx += keyManagerEvent.isPageUp ? -moveCount : moveCount;

      stateManager.moveSelectingCellByRowIdx(rowIdx, direction);
    } else {
      int rowIdx = stateManager.currentRowIdx;

      rowIdx += keyManagerEvent.isPageUp ? -moveCount : moveCount;

      stateManager.moveCurrentCellByRowIdx(rowIdx, direction);
    }
  }

  void _handleEnter(KeyManagerEvent keyManagerEvent) {
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelect) {
      stateManager.onSelected(PlutoOnSelectedEvent(
        row: stateManager.currentRow,
        cell: stateManager.currentCell,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    // Moves to the lower or upper cell when pressing the Enter key while editing the cell.
    if (stateManager.isEditing) {
      // Occurs twice when a key event occurs without change of focus in the state of last inputting Korean
      // Only problem on the web. Looks like a bug. If fixed, delete the code below.
      final lastChildContext = keyManagerEvent.focusNode.children.last.context;

      if (kIsWeb &&
          lastChildContext is StatefulElement &&
          lastChildContext?.dirty != true &&
          lastChildContext.widget is EditableText) {
        stateManager.gridFocusNode.unfocus();
        developer.log('TODO',
            name: 'data_grid',
            error: 'Enter twice when entering Korean on the web.');
      }

      if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      } else if (stateManager
          .configuration.enterKeyAction.isEditingAndMoveDown) {
        if (keyManagerEvent.event.isShiftPressed) {
          stateManager.moveCurrentCell(
            MoveDirection.Up,
            notify: false,
          );
        } else {
          stateManager.moveCurrentCell(
            MoveDirection.Down,
            notify: false,
          );
        }
      } else if (stateManager
          .configuration.enterKeyAction.isEditingAndMoveRight) {
        if (keyManagerEvent.event.isShiftPressed) {
          stateManager.moveCurrentCell(
            MoveDirection.Left,
            force: true,
            notify: false,
          );
        } else {
          stateManager.moveCurrentCell(
            MoveDirection.Right,
            force: true,
            notify: false,
          );
        }
      }
    }

    stateManager.toggleEditing();
  }

  void _handleTab(KeyManagerEvent keyManagerEvent) {
    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    final saveIsEditing = stateManager.isEditing;

    if (keyManagerEvent.event.isShiftPressed) {
      stateManager.moveCurrentCell(MoveDirection.Left, force: true);
    } else {
      stateManager.moveCurrentCell(MoveDirection.Right, force: true);
    }

    stateManager.setEditing(saveIsEditing);
  }

  void _handleEsc(KeyManagerEvent keyManagerEvent) {
    if (stateManager.mode.isSelect) {
      stateManager.onSelected(PlutoOnSelectedEvent(
        row: null,
        cell: null,
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
    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.setData(
        new ClipboardData(text: stateManager.currentSelectingText));
  }

  void _handleCtrlV(KeyManagerEvent keyManagerEvent) {
    if (stateManager.currentCell == null) {
      return;
    }

    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.getData('text/plain').then((value) {
      List<List<String>> textList =
          ClipboardTransformation.stringToList(value.text);

      stateManager.pasteCellValue(textList);
    });
  }

  void _handleCtrlA(KeyManagerEvent keyManagerEvent) {
    if (stateManager.isEditing == true) {
      return;
    }

    stateManager.setAllCurrentSelecting();
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
  bool get isKeyDownEvent => this.event.runtimeType == RawKeyDownEvent;

  bool get isKeyUpEvent => this.event.runtimeType == RawKeyUpEvent;

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

  bool get isHome =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.home.keyId;

  bool get isEnd => this.event.logicalKey.keyId == LogicalKeyboardKey.end.keyId;

  bool get isPageUp {
    // windows 에서 pageUp keyId 가 0x10700000021.
    return this.event.logicalKey.keyId == LogicalKeyboardKey.pageUp.keyId ||
        this.event.logicalKey.keyId == 0x10700000021;
  }

  bool get isPageDown {
    // windows 에서 pageDown keyId 가 0x10700000022.
    return this.event.logicalKey.keyId == LogicalKeyboardKey.pageDown.keyId ||
        this.event.logicalKey.keyId == 0x10700000022;
  }

  bool get isEsc =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.escape.keyId;

  bool get isEnter =>
      this.event.logicalKey.keyId == LogicalKeyboardKey.enter.keyId;

  bool get isTab => this.event.logicalKey.keyId == LogicalKeyboardKey.tab.keyId;

  bool get isF2 => this.event.logicalKey.keyId == LogicalKeyboardKey.f2.keyId;

  bool get isCharacter =>
      this.event.logicalKey.keyLabel != null &&
      this.event.logicalKey.keyLabel.isNotEmpty;

  bool get isCtrlC {
    return this.isCtrlPressed &&
        this.event.logicalKey.keyId == LogicalKeyboardKey.keyC.keyId;
  }

  bool get isCtrlV {
    return this.isCtrlPressed &&
        this.event.logicalKey.keyId == LogicalKeyboardKey.keyV.keyId;
  }

  bool get isCtrlA {
    return this.isCtrlPressed &&
        this.event.logicalKey.keyId == LogicalKeyboardKey.keyA.keyId;
  }

  bool get isShiftPressed {
    return this.event.isShiftPressed;
  }

  bool get isCtrlPressed {
    return this.event.isMetaPressed || this.event.isControlPressed;
  }
}
