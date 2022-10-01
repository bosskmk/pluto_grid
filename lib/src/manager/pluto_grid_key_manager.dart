import 'dart:async';

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

  PlutoGridKeyEventResult eventResult = PlutoGridKeyEventResult();

  PlutoGridKeyManager({
    required this.stateManager,
  });

  final PublishSubject<PlutoKeyManagerEvent> _subject =
      PublishSubject<PlutoKeyManagerEvent>();

  PublishSubject<PlutoKeyManagerEvent> get subject => _subject;

  late final StreamSubscription _subscription;

  StreamSubscription get subscription => _subscription;

  void dispose() {
    _subscription.cancel();

    _subject.close();
  }

  void init() {
    final normalStream = _subject.stream.where((event) => !event.needsThrottle);

    final movingStream =
        _subject.stream.where((event) => event.needsThrottle).transform(
              ThrottleStreamTransformer(
                (_) => TimerStream(_, const Duration(milliseconds: 1)),
              ),
            );

    _subscription = MergeStream([normalStream, movingStream]).listen(_handler);
  }

  void _handler(PlutoKeyManagerEvent keyEvent) {
    stateManager.keyPressed.shift = keyEvent.isShiftPressed;
    stateManager.keyPressed.ctrl = keyEvent.isCtrlPressed;

    if (keyEvent.isKeyUpEvent) {
      return;
    }

    if (keyEvent.isMoving) {
      _handleMoving(keyEvent);
      return;
    }

    if (keyEvent.isEnter) {
      _handleEnter(keyEvent);
      return;
    }

    if (keyEvent.isTab) {
      _handleTab(keyEvent);
      return;
    }

    if (keyEvent.isHome || keyEvent.isEnd) {
      _handleHomeEnd(keyEvent);
      return;
    }

    if (keyEvent.isPageUp || keyEvent.isPageDown) {
      _handlePageUpDown(keyEvent);
      return;
    }

    if (keyEvent.isEsc) {
      _handleEsc(keyEvent);
      return;
    }

    if (keyEvent.isF2) {
      _handleF2(keyEvent);
      return;
    }

    if (keyEvent.isF3) {
      _handleF3(keyEvent);
      return;
    }

    if (keyEvent.isF4) {
      _handleF4(keyEvent);
      return;
    }

    if (keyEvent.isCharacter) {
      if (keyEvent.isCtrlC) {
        _handleCtrlC(keyEvent);
        return;
      }

      if (keyEvent.isCtrlV) {
        _handleCtrlV(keyEvent);
        return;
      }

      if (keyEvent.isCtrlA) {
        _handleCtrlA(keyEvent);
        return;
      }

      _handleCharacter(keyEvent);
    }
  }

  void _handleMoving(PlutoKeyManagerEvent keyEvent) {
    PlutoMoveDirection moveDirection;

    bool force = keyEvent.isHorizontal &&
        stateManager.configuration.enableMoveHorizontalInEditing == true;

    if (keyEvent.isLeft) {
      moveDirection = PlutoMoveDirection.left;
    } else if (keyEvent.isRight) {
      moveDirection = PlutoMoveDirection.right;
    } else if (keyEvent.isUp) {
      moveDirection = PlutoMoveDirection.up;
    } else if (keyEvent.isDown) {
      moveDirection = PlutoMoveDirection.down;
    } else {
      return;
    }

    if (keyEvent.event.isShiftPressed) {
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

  void _handleHomeEnd(PlutoKeyManagerEvent keyEvent) {
    if (keyEvent.isHome) {
      if (keyEvent.isCtrlPressed) {
        if (keyEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.up);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.up);
        }
      } else {
        if (keyEvent.isShiftPressed) {
          stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.left);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.left);
        }
      }
    } else if (keyEvent.isEnd) {
      if (keyEvent.isCtrlPressed) {
        if (keyEvent.isShiftPressed) {
          stateManager.moveSelectingCellToEdgeOfRows(PlutoMoveDirection.down);
        } else {
          stateManager.moveCurrentCellToEdgeOfRows(PlutoMoveDirection.down);
        }
      } else {
        if (keyEvent.isShiftPressed) {
          stateManager
              .moveSelectingCellToEdgeOfColumns(PlutoMoveDirection.right);
        } else {
          stateManager.moveCurrentCellToEdgeOfColumns(PlutoMoveDirection.right);
        }
      }
    }
  }

  void _handlePageUpDown(PlutoKeyManagerEvent keyEvent) {
    final int moveCount =
        (stateManager.rowContainerHeight / stateManager.rowTotalHeight).floor();

    final direction =
        keyEvent.isPageUp ? PlutoMoveDirection.up : PlutoMoveDirection.down;

    if (keyEvent.isShiftPressed) {
      int rowIdx = stateManager.currentSelectingPosition?.rowIdx ??
          stateManager.currentCellPosition?.rowIdx ??
          0;

      rowIdx += keyEvent.isPageUp ? -moveCount : moveCount;

      stateManager.moveSelectingCellByRowIdx(rowIdx, direction);

      return;
    }

    if (keyEvent.isAltPressed && stateManager.isPaginated) {
      final currentColumn = stateManager.currentColumn;

      final previousPosition = stateManager.currentCellPosition;

      int toPage =
          keyEvent.isPageUp ? stateManager.page - 1 : stateManager.page + 1;

      if (toPage < 1) {
        toPage = 1;
      } else if (toPage > stateManager.totalPage) {
        toPage = stateManager.totalPage;
      }

      stateManager.setPage(toPage);

      _restoreCurrentCellPosition(
        currentColumn: currentColumn,
        previousPosition: previousPosition,
      );

      return;
    }

    int rowIdx = stateManager.currentRowIdx!;

    rowIdx += keyEvent.isPageUp ? -moveCount : moveCount;

    stateManager.moveCurrentCellByRowIdx(rowIdx, direction);
  }

  void _handleEnter(PlutoKeyManagerEvent keyEvent) {
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelect) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: stateManager.currentRow,
        rowIdx: stateManager.currentRowIdx,
        cell: stateManager.currentCell,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    if (!stateManager.isEditing && _isExpandableCell()) {
      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.currentRow!);
      return;
    }

    if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      stateManager.toggleEditing(notify: false);
    } else {
      if (stateManager.isEditing == true ||
          stateManager.currentColumn?.enableEditingMode == false) {
        final saveIsEditing = stateManager.isEditing;

        _moveCell(keyEvent);

        stateManager.setEditing(saveIsEditing, notify: false);
      } else {
        stateManager.toggleEditing(notify: false);
      }
    }

    if (stateManager.autoEditing) {
      stateManager.setEditing(true, notify: false);
    }

    stateManager.notifyListeners();
  }

  void _handleTab(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.currentCell == null) {
      stateManager.setCurrentCell(stateManager.firstCell, 0);
      return;
    }

    final saveIsEditing = stateManager.isEditing;

    if (keyEvent.event.isShiftPressed) {
      stateManager.moveCurrentCell(PlutoMoveDirection.left, force: true);
    } else {
      stateManager.moveCurrentCell(PlutoMoveDirection.right, force: true);
    }

    stateManager.setEditing(stateManager.autoEditing || saveIsEditing);
  }

  void _handleEsc(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.mode.isSelect ||
        (stateManager.mode.isPopup && !stateManager.isEditing)) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: null,
        rowIdx: null,
        cell: null,
      ));
      return;
    }

    if (stateManager.isEditing) {
      stateManager.setEditing(false);
    }
  }

  void _handleF2(PlutoKeyManagerEvent keyEvent) {
    if (!stateManager.isEditing) {
      stateManager.setEditing(true);
    }
  }

  void _handleF3(PlutoKeyManagerEvent keyEvent) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null) {
      return;
    }

    if (!stateManager.showColumnFilter) {
      return;
    }

    if (currentColumn.filterFocusNode?.canRequestFocus == true) {
      currentColumn.filterFocusNode?.requestFocus();
      stateManager.setKeepFocus(false);

      return;
    }

    stateManager.showFilterPopup(
      keyEvent.focusNode.context!,
      calledColumn: stateManager.currentColumn,
    );
  }

  void _handleF4(PlutoKeyManagerEvent keyEvent) {
    final currentColumn = stateManager.currentColumn;

    if (currentColumn == null) {
      return;
    }

    final previousPosition = stateManager.currentCellPosition;

    stateManager.toggleSortColumn(currentColumn);

    _restoreCurrentCellPosition(
      currentColumn: currentColumn,
      previousPosition: previousPosition,
    );
  }

  void _handleCtrlC(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.isEditing == true) {
      return;
    }

    Clipboard.setData(ClipboardData(text: stateManager.currentSelectingText));
  }

  void _handleCtrlV(PlutoKeyManagerEvent keyEvent) {
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

  void _handleCtrlA(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.isEditing == true) {
      return;
    }

    stateManager.setAllCurrentSelecting();
  }

  void _handleCharacter(PlutoKeyManagerEvent keyEvent) {
    if (stateManager.isEditing != true && stateManager.currentCell != null) {
      stateManager.setEditing(true);

      if (keyEvent.event.character == null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (stateManager.textEditingController != null) {
          stateManager.textEditingController!.text = keyEvent.event.character!;
        }
      });
    }
  }

  void _moveCell(PlutoKeyManagerEvent keyEvent) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return;
    }

    if (enterKeyAction.isEditingAndMoveDown) {
      if (keyEvent.event.isShiftPressed) {
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
    } else if (enterKeyAction.isEditingAndMoveRight) {
      if (keyEvent.event.isShiftPressed) {
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

  void _restoreCurrentCellPosition({
    PlutoColumn? currentColumn,
    PlutoGridCellPosition? previousPosition,
  }) {
    if (currentColumn == null || previousPosition?.hasPosition != true) {
      return;
    }

    int rowIdx = previousPosition!.rowIdx!;

    if (rowIdx > stateManager.refRows.length - 1) {
      rowIdx = stateManager.refRows.length - 1;
    }

    stateManager.setCurrentCell(
      stateManager.refRows.elementAt(rowIdx).cells[currentColumn.field],
      rowIdx,
    );
  }

  bool _isExpandableCell() {
    return stateManager.currentCell != null &&
        stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate
                ?.isExpandableCell(stateManager.currentCell!) ==
            true;
  }
}
