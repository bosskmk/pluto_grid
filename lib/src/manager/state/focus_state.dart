import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IFocusState {
  /// FocusNode to control keyboard input.
  FocusNode get gridFocusNode;

  bool get keepFocus;

  bool get hasFocus;

  void setKeepFocus(bool flag, {bool notify = true});

  void nextFocusOfColumnFilter(
    PlutoColumn column, {
    bool reversed = false,
  });
}

mixin FocusState implements IPlutoGridState {
  @override
  bool get keepFocus => _keepFocus;

  bool _keepFocus = false;

  @override
  bool get hasFocus => _keepFocus && gridFocusNode.hasFocus;

  @override
  void setKeepFocus(bool flag, {bool notify = true}) {
    if (_keepFocus == flag) {
      return;
    }

    _keepFocus = flag;

    if (_keepFocus) {
      gridFocusNode.requestFocus();
    }

    if (_keepFocus) {
      // RequestFocus is fired and notifies listeners with hasFocus true.
      // requestFocus delays up to one frame.
      notifyListenersOnPostFrame(notify, setKeepFocus.hashCode);
    } else {
      notifyListeners(notify, setKeepFocus.hashCode);
    }
  }

  @override
  void nextFocusOfColumnFilter(
    PlutoColumn column, {
    bool reversed = false,
  }) {
    if (!column.enableFilterMenuItem) {
      return;
    }

    final columnIndexes = reversed
        ? columnIndexesByShowFrozen.reversed.toList(growable: false)
        : columnIndexesByShowFrozen.toList(growable: false);

    final length = columnIndexes.length;

    bool found = false;

    for (int i = 0; i < length - 1; i += 1) {
      var current = refColumns[columnIndexes[i]];

      if (!found && current.key == column.key) {
        found = true;
      }

      if (!found) {
        continue;
      }

      var toMoveIndex = columnIndexes[i + 1];

      var toMove = refColumns[toMoveIndex];

      if (toMove.enableFilterMenuItem) {
        toMove.filterFocusNode?.requestFocus();

        moveScrollByColumn(
          reversed ? PlutoMoveDirection.left : PlutoMoveDirection.right,
          reversed ? length - 1 - i : i,
        );

        return;
      }
    }
  }
}
