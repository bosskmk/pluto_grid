import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnGroupHelper {
  static bool exists({
    required String field,
    required PlutoColumnGroup columnGroup,
  }) {
    if (columnGroup.hasFields) {
      return columnGroup.fields!.contains(field);
    }

    for (int i = 0; i < columnGroup.children!.length; i += 1) {
      if (exists(
        field: field,
        columnGroup: columnGroup.children![i],
      )) {
        return true;
      }
    }

    return false;
  }

  static bool existsFromList({
    required String field,
    required List<PlutoColumnGroup> columnGroupList,
  }) {
    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (exists(field: field, columnGroup: columnGroupList[i])) {
        return true;
      }
    }
    return false;
  }

  static PlutoColumnGroup? getGroupIfExistsFromList({
    required String field,
    required List<PlutoColumnGroup> columnGroupList,
  }) {
    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (exists(field: field, columnGroup: columnGroupList[i])) {
        return columnGroupList[i];
      }
    }
    return null;
  }

  static int countLinkedGroup({
    required List<PlutoColumnGroup> columnGroupList,
    required List<PlutoColumn> columns,
  }) {
    int count = 0;

    PlutoColumnGroup? previousGroup;

    for (int i = 0; i < columns.length; i += 1) {
      final field = columns[i].field;

      final foundGroup = getGroupIfExistsFromList(
        field: field,
        columnGroupList: columnGroupList,
      );

      if (foundGroup == null) {
        continue;
      }

      if (previousGroup?.key == foundGroup.key) {
        continue;
      }

      count += 1;

      previousGroup = foundGroup;
    }

    return count;
  }

  static List<PlutoColumnGroupPair> separateLinkedGroup({
    required List<PlutoColumnGroup> columnGroupList,
    required List<PlutoColumn> columns,
  }) {
    if (columnGroupList.isEmpty || columns.isEmpty) {
      return [];
    }

    List<PlutoColumnGroupPair> separatedColumns = [];

    PlutoColumnGroup? previousGroup;

    List<PlutoColumn> linkedColumns = <PlutoColumn>[];

    for (int i = 0; i < columns.length; i += 1) {
      final column = columns[i];

      final field = column.field;

      final foundGroup = getGroupIfExistsFromList(
        field: field,
        columnGroupList: columnGroupList,
      );

      if (foundGroup == null) {
        continue;
      }

      previousGroup ??= foundGroup;

      if (previousGroup.key != foundGroup.key) {
        separatedColumns.add(PlutoColumnGroupPair(
          group: previousGroup,
          columns: linkedColumns,
        ));

        linkedColumns = [];

        previousGroup = foundGroup;
      }

      linkedColumns.add(column);

      if (i == columns.length - 1) {
        separatedColumns.add(PlutoColumnGroupPair(
          group: foundGroup,
          columns: linkedColumns,
        ));
      }
    }

    return separatedColumns;
  }

  static int maxDepth({
    required List<PlutoColumnGroup> columnGroupList,
    int level = 0,
  }) {
    int currentDepth = level + 1;

    for (int i = 0; i < columnGroupList.length; i += 1) {
      if (columnGroupList[i].hasChildren) {
        final int depth = maxDepth(
          columnGroupList: columnGroupList[i].children!,
          level: level + 1,
        );

        if (depth > currentDepth) {
          currentDepth = depth;
        }
      }
    }

    return currentDepth;
  }
}
