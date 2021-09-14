import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:pluto_grid/src/model/pluto_column.dart';

class PlutoColumnGroup with IterableMixin<PlutoColumn> {
  PlutoColumnGroup({
    required this.title,
    required this.columns,
  })  : _hide = false,
        _key = UniqueKey();

  final String title;
  final List<PlutoColumn> columns;

  /// Column key
  final Key _key;
  Key get key => _key;

  /// Hide the column.
  bool _hide;
  bool get hide => _hide;
  set hide(bool hide) {
    _hide = hide;
    for (final col in this) {
      col.hide = hide;
    }
  }

  double get minWidth => columns.fold(0, (sum, col) => sum + col.minWidth);
  double get width => columns.fold(0, (sum, col) => sum + col.width);

  @override
  Iterator<PlutoColumn> get iterator => columns.iterator;
}

extension PlutoColumnGroupsX on List<PlutoColumnGroup> {
  List<PlutoColumn> get expandedColumns => [...expand((group) => group)];
  int get expandedLength => fold(0, (n, group) => n + group.length);
}
