import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRow {
  /// List of row
  Map<String, PlutoCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int? sortIdx;

  PlutoRow({
    required this.cells,
    this.sortIdx,
    bool checked = false,
    Key? key,
  })  : _checked = checked,
        _state = PlutoRowState.none,
        _key = key ?? UniqueKey();

  factory PlutoRow.stubGroup({
    required List<PlutoRow> children,
    required Map<String, PlutoCell> cells,
    bool expanded = false,
  }) {
    final row = PlutoRow(
      cells: cells,
    )
      .._stub = true
      .._expanded = expanded
      .._children = children;

    for (var e in row._children) {
      e._parent = row;
    }

    return row;
  }

  bool get stub => _stub;

  bool _stub = false;

  bool get expanded => _expanded;

  setExpanded(bool flag) {
    _expanded = flag;
  }

  bool _expanded = false;

  PlutoRow? get parent => _parent;

  PlutoRow? _parent;

  List<PlutoRow> get children => _children;

  List<PlutoRow> _children = [];

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [PlutoColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the PlutoStateManager.setRowChecked
  /// or PlutoStateManager.toggleAllRowChecked methods.
  bool? get checked => _checked;

  bool? _checked;

  void setChecked(bool? flag) {
    _checked = flag;
  }

  PlutoRowState get state => _state;

  PlutoRowState _state;

  void setState(PlutoRowState state) {
    _state = state;
  }

  /// Row key
  Key get key => _key;

  final Key _key;
}

enum PlutoRowState {
  none,
  added,
  updated,
}

extension PlutoRowStateExtension on PlutoRowState {
  bool get isNone => this == PlutoRowState.none;

  bool get isAdded => this == PlutoRowState.added;

  bool get isUpdated => this == PlutoRowState.updated;
}
