import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoRowGroup {
  final PlutoColumn groupColumn;

  final String title;

  final List<PlutoRowGroup> subGroups;

  final List<PlutoRow> rows;

  PlutoRowGroup({
    required this.groupColumn,
    required this.title,
    this.subGroups = const [],
    this.rows = const [],
  })  : assert(subGroups.isEmpty != rows.isEmpty),
        _key = UniqueKey();

  Key get key => _key;

  final Key _key;

  bool get hasSubGroups => subGroups.isNotEmpty;
}
