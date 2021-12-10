import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnGroup {
  final String title;

  final List<String>? fields;

  final List<PlutoColumnGroup>? children;

  double? titlePadding;

  /// Text alignment in Cell. (Left, Right, Center)
  PlutoColumnTextAlign titleTextAlign;

  /// Customize the column with TextSpan or WidgetSpan instead of the column's title string.
  ///
  /// ```
  /// titleSpan: const TextSpan(
  ///   children: [
  ///     WidgetSpan(
  ///       child: Text(
  ///         '* ',
  ///         style: TextStyle(color: Colors.red),
  ///       ),
  ///     ),
  ///     TextSpan(text: 'column title'),
  ///   ],
  /// ),
  /// ```
  InlineSpan? titleSpan;

  PlutoColumnGroup({
    required this.title,
    this.fields,
    this.children,
    this.titlePadding,
    this.titleSpan,
    this.titleTextAlign = PlutoColumnTextAlign.center,
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
