import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnGroup {
  final String title;

  final List<String>? fields;

  final List<PlutoColumnGroup>? children;

  final double? titlePadding;

  /// Text alignment in Cell. (Left, Right, Center)
  final PlutoColumnTextAlign titleTextAlign;

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
  final InlineSpan? titleSpan;

  /// It shows only one column.
  /// he height is set to the maximum depth of the group.
  /// The group title is not shown.
  final bool? expandedColumn;

  /// a unique name to represent the group
  String groupId;

  PlutoColumnGroup({
    required this.title,
    required this.groupId,
    this.fields,
    this.children,
    this.titlePadding,
    this.titleSpan,
    this.titleTextAlign = PlutoColumnTextAlign.center,
    this.expandedColumn = false,
  })  : assert(fields == null
            ? (children != null && children.isNotEmpty)
            : fields.isNotEmpty && children == null),
        assert(expandedColumn == true
            ? fields?.length == 1 && children == null
            : true),
        _key = ValueKey(groupId) {
    hasFields = fields != null;

    hasChildren = !hasFields;
  }

  ValueKey get key => _key;

  final ValueKey _key;

  late final bool hasFields;

  late final bool hasChildren;
}

class PlutoColumnGroupPair {
  PlutoColumnGroup group;
  List<PlutoColumn> columns;

  PlutoColumnGroupPair({
    required this.group,
    required this.columns,
  }) :
        // a unique reproducable key
        _key = ValueKey(group.key.value.toString() +
            columns.fold(
                "",
                (previousValue, element) =>
                    previousValue + "-" + element.field));

  Key get key => _key;

  final Key _key;
}
