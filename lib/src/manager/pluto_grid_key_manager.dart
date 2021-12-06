import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

/// 2021-11-19
/// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
/// 이슈 해결 후 : 삭제
///
/// desktop 에서만 발생
/// skipRemainingHandlers 을 리턴하면 pluto_grid.dart 의 FocusScope 의
/// 콜백이 호출 되지 않고 TextField 에 키 입력이 되어야 하는데
/// 방향키, 백스페이스 등이 입력되지 않음.(문자등은 입력 됨)
/// https://github.com/flutter/flutter/issues/93873
class PlutoGridKeyEventResult {
  bool _skip = false;

  bool get isSkip => _skip;

  KeyEventResult skip(KeyEventResult result) {
    _skip = true;

    return result;
  }

  KeyEventResult consume(KeyEventResult result) {
    if (_skip) {
      _skip = false;

      return KeyEventResult.ignored;
    }

    return result;
  }
}

class PlutoGridKeyManager {
  PlutoGridStateManager stateManager;

  /// 2021-11-19
  /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
  /// 이슈 해결 후 : 삭제
  PlutoGridKeyEventResult eventResult = PlutoGridKeyEventResult();

  PlutoGridKeyManager({
    required this.stateManager,
  });

  PublishSubject<PlutoKeyManagerEvent> subject =
      PublishSubject<PlutoKeyManagerEvent>();

  void dispose() {
    subject.close();
  }

  void init() {
    subject.stream.listen(_handler);
  }

  void _handler(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (plutoKeyManagerEvent.isKeyDownEvent ||
        plutoKeyManagerEvent.isKeyUpEvent) {
      stateManager.setKeyPressed(PlutoGridKeyPressed(
        shift: plutoKeyManagerEvent.isShiftPressed,
        ctrl: plutoKeyManagerEvent.isCtrlPressed,
      ));
    }

    if (plutoKeyManagerEvent.isKeyDownEvent) {
      if (plutoKeyManagerEvent.isMoving) {
        _handleMoving(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isEnter) {
        _handleEnter(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isTab) {
        _handleTab(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isHome || plutoKeyManagerEvent.isEnd) {
        _handleHomeEnd(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isPageUp ||
          plutoKeyManagerEvent.isPageDown) {
        _handlePageUpDown(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isEsc) {
        _handleEsc(plutoKeyManagerEvent);
      } else if (plutoKeyManagerEvent.isF2) {
        if (!stateManager.isEditing) {
          stateManager.setEditing(true);
        }
      } else if (plutoKeyManagerEvent.isCharacter) {
        if (plutoKeyManagerEvent.isCtrlC) {
          _handleCtrlC(plutoKeyManagerEvent);
        } else if (plutoKeyManagerEvent.isCtrlV) {
          _handleCtrlV(plutoKeyManagerEvent);
        } else if (plutoKeyManagerEvent.isCtrlA) {
          _handleCtrlA(plutoKeyManagerEvent);
        } else {
          _handleCharacter(plutoKeyManagerEvent);
        }
      }
    }
  }

  void _handleMoving(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    PlutoMoveDirection moveDirection;

    bool force = plutoKeyManagerEvent.isHorizontal &&
        stateManager.configuration?.enableMoveHorizontalInEditing == true;

    if (plutoKeyManagerEvent.isLeft) {
      moveDirection = PlutoMoveDirection.left;
    } else if (plutoKeyManagerEvent.isRight) {
      moveDirection = PlutoMoveDirection.right;
    } else if (plutoKeyManagerEvent.isUp) {
      moveDirection = PlutoMoveDirection.up;
    } else if (plutoKeyManagerEvent.isDown) {
      moveDirection = PlutoMoveDirection.down;
    } else {
      return;
    }

    if (plutoKeyManagerEvent.event.isShiftPressed) {
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

    stateManager.moveCurrentCell(moveDirection, force: force);
  }

  void _handleHomeEnd(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (plutoKeyManagerEvent.isHome) {
      if (plutoKeyManagerEvent.isCtrlPressed) {
        if (plutoKeyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.up);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.up);
        }
      } else {
        if (plutoKeyManagerEvent.isShiftPressed) {
          stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.left);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.left);
        }
      }
    } else if (plutoKeyManagerEvent.isEnd) {
      if (plutoKeyManagerEvent.isCtrlPressed) {
        if (plutoKeyManagerEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.down);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.down);
        }
      } else {
        if (plutoKeyManagerEvent.isShiftPressed) {
          stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.right);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.right);
        }
      }
    }
  }

  void _handlePageUpDown(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    final int moveCount =
        (stateManager.offsetHeight / stateManager.rowTotalHeight).floor();

    final direction = plutoKeyManagerEvent.isPageUp
        ? PlutoMoveDirection.up
        : PlutoMoveDirection.down;

    if (plutoKeyManagerEvent.isShiftPressed) {
      int rowIdx = stateManager.currentSelectingPosition?.rowIdx ??
          stateManager.currentCellPosition?.rowIdx ??
          0;

      rowIdx += plutoKeyManagerEvent.isPageUp ? -moveCount : moveCount;

      stateManager.moveSelectingCellByRowIdx(rowIdx, direction);

      return;
    }

    if (plutoKeyManagerEvent.isAltPressed && stateManager.isPaginated) {
      int toPage = plutoKeyManagerEvent.isPageUp
          ? stateManager.page - 1
          : stateManager.page + 1;

      if (toPage < 1) {
        toPage = 1;
      } else if (toPage > stateManager.totalPage) {
        toPage = stateManager.totalPage;
      }

      stateManager.setPage(toPage);

      return;
    }

    int rowIdx = stateManager.currentRowIdx!;

    rowIdx += plutoKeyManagerEvent.isPageUp ? -moveCount : moveCount;

    stateManager.moveCurrentCellByRowIdx(rowIdx, direction);
  }

  void _handleEnter(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelect) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: stateManager.currentRow,
        cell: stateManager.currentCell,
      ));
      return;
    }

    if (stateManager.configuration!.enterKeyAction.isNone) {
      return;
    }

    // Moves to the lower or upper cell when pressing the Enter key while editing the cell.
    if (stateManager.isEditing) {
      // Occurs twice when a key event occurs without change of focus in the state of last inputting Korean
      // Only problem on the web. Looks like a bug. If fixed, delete the code below.
      final lastChildContext =
          plutoKeyManagerEvent.focusNode.children.last.context;

      if (kIsWeb &&
          lastChildContext is StatefulElement &&
          lastChildContext.state.widget is Focus &&
          (lastChildContext.state.widget as Focus).focusNode?.hasPrimaryFocus ==
              false &&
          stateManager.currentColumn?.type is PlutoColumnTypeText) {
        PlutoLog(
          'Enter twice when entering Korean on the web.',
          type: PlutoLogType.todo,
        );

        return;
      }

      if (stateManager.configuration!.enterKeyAction.isToggleEditing) {
      } else if (stateManager
          .configuration!.enterKeyAction.isEditingAndMoveDown) {
        if (plutoKeyManagerEvent.event.isShiftPressed) {
          stateManager.moveCurrentCell(
            PlutoMoveDirection.up,
            notify: false,
          );
        } else {
          stateManager.moveCurrentCell(
            PlutoMoveDirection.down,
            notify: false,
          );
        }
      } else if (stateManager
          .configuration!.enterKeyAction.isEditingAndMoveRight) {
        if (plutoKeyManagerEvent.event.isShiftPressed) {
          stateManager.moveCurrentCell(
            PlutoMoveDirection.left,
            force: true,
            notify: false,
          );
        } else {
          stateManager.moveCurrentCell(
            PlutoMoveDirection.right,
            force: true,
            notify: false,
          );
        }
      }
    }

    if (stateManager.autoEditing && stateManager.isEditing) {
      stateManager.notifyListeners();

      return;
    }

    stateManager.toggleEditing();
  }

  void _handleTab(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    final saveIsEditing = stateManager.isEditing;

    if (plutoKeyManagerEvent.event.isShiftPressed) {
      stateManager.moveCurrentCell(PlutoMoveDirection.left, force: true);
    } else {
      stateManager.moveCurrentCell(PlutoMoveDirection.right, force: true);
    }

    stateManager.setEditing(stateManager.autoEditing || saveIsEditing);
  }

  void _handleEsc(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.mode.isSelect ||
        (stateManager.mode.isPopup && !stateManager.isEditing)) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: null,
        cell: null,
      ));
      return;
    }

    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }
  }

  void _handleCtrlC(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.setData(ClipboardData(text: stateManager.currentSelectingText));
  }

  void _handleCtrlV(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.currentCell == null) {
      return;
    }

    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.getData('text/plain').then((value) {
      List<List<String>> textList =
          PlutoClipboardTransformation.stringToList(value!.text!);

      stateManager.pasteCellValue(textList);
    });
  }

  void _handleCtrlA(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.isEditing == true) {
      return;
    }

    stateManager.setAllCurrentSelecting();
  }

  void _handleCharacter(PlutoKeyManagerEvent plutoKeyManagerEvent) {
    if (stateManager.isEditing != true && stateManager.currentCell != null) {
      stateManager.setEditing(true);

      if (plutoKeyManagerEvent.event.character == null) {
        return;
      }

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (stateManager.textEditingController != null) {
          stateManager.textEditingController!.text =
              plutoKeyManagerEvent.event.character!;
        }
      });
    }
  }
}
