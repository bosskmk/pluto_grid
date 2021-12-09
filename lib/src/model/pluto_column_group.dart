import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnGroup {
  final String title;

  final List<String>? fields;

  final List<PlutoColumnGroup>? children;

  PlutoColumnGroup({
    required this.title,
    this.fields,
    this.children,
  })  : assert(fields == null
            ? (children != null && children.isNotEmpty)
            : fields.isNotEmpty),
        _key = UniqueKey() {
    hasFields = fields != null;

    hasChildren = !hasFields;
  }

  Key get key => _key;

  late final Key _key;

  late final bool hasFields;

  late final bool hasChildren;
}

class PlutoColumnGroupPair {
  PlutoColumnGroup group;
  List<PlutoColumn> columns;

  PlutoColumnGroupPair({
    required this.group,
    required this.columns,
  });
}
