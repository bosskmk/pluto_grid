import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRow {
  PlutoRow({
    required this.cells,
    PlutoRowType? type,
    this.sortIdx = 0,
    bool checked = false,
    Key? key,
  })  : type = type ?? PlutoRowTypeNormal.instance,
        _checked = checked,
        _state = PlutoRowState.none,
        _key = key ?? UniqueKey();

  final PlutoRowType type;

  final Key _key;

  Map<String, PlutoCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int sortIdx;

  bool? _checked;

  PlutoRow? _parent;

  PlutoRowState _state;

  Key get key => _key;

  bool get initialized {
    if (cells.isEmpty) {
      return true;
    }

    return cells.values.first.initialized;
  }

  PlutoRow? get parent => _parent;

  int get depth {
    int depth = 0;
    var current = parent;
    while (current != null) {
      depth += 1;
      current = current.parent;
    }
    return depth;
  }

  bool get isMain => parent == null;

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [PlutoColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the PlutoStateManager.setRowChecked
  /// or PlutoStateManager.toggleAllRowChecked methods.
  bool? get checked {
    return type.isGroup ? _tristateCheckedRow : _checked;
  }

  bool? get _tristateCheckedRow {
    if (!type.isGroup) return false;

    final children = type.group.children;

    final length = children.length;

    if (length == 0) return _checked;

    int countTrue = 0;

    int countFalse = 0;

    int countTristate = 0;

    for (var i = 0; i < length; i += 1) {
      if (children[i].type.isGroup) {
        switch (children[i]._tristateCheckedRow) {
          case true:
            ++countTrue;
            break;
          case false:
            ++countFalse;
            break;
          case null:
            ++countTristate;
            break;
        }
      } else {
        children[i].checked == true ? ++countTrue : ++countFalse;
      }

      if ((countTrue > 0 && countFalse > 0) || countTristate > 0) return null;
    }

    return countTrue == length;
  }

  /// State when a new row is added or the cell value in the row is changed.
  ///
  /// Keeps the row from disappearing when changing the cell value
  /// to a value other than the filtering condition while column filtering is applied.
  /// When the value of a cell is changed,
  /// the [state] value of the changed row is changed to [PlutoRowState.updated],
  /// and in this case, even if the filtering condition is not
  /// Make sure it stays in the list unless you change the filtering again.
  PlutoRowState get state => _state;

  void setParent(PlutoRow? row) {
    _parent = row;
  }

  void setChecked(bool? flag) {
    _checked = flag;
    if (type.isGroup) {
      for (final child in type.group.children) {
        child.setChecked(flag);
      }
    }
  }

  void setState(PlutoRowState state) {
    _state = state;
  }
}

enum PlutoRowState {
  none,
  added,
  updated;

  bool get isNone => this == PlutoRowState.none;

  bool get isAdded => this == PlutoRowState.added;

  bool get isUpdated => this == PlutoRowState.updated;
}
