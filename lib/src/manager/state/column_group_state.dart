import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnGroupState {
  List<PlutoColumnGroup> get columnGroups;

  FilteredList<PlutoColumnGroup>? refColumnGroups;

  bool get hasColumnGroups;

  bool get showColumnGroups;

  void setShowColumnGroups(bool flag, {bool notify = true});

  List<PlutoColumnGroupPair> separateLinkedGroup({
    required List<PlutoColumnGroup> columnGroupList,
    required List<PlutoColumn> columns,
  });

  int columnGroupDepth(List<PlutoColumnGroup> groups);

  void removeColumnsInColumnGroup(
    List<PlutoColumn> columns, {
    bool notify = true,
  });
}

mixin ColumnGroupState implements IPlutoGridState {
  @override
  List<PlutoColumnGroup> get columnGroups => [...refColumnGroups!];

  @override
  FilteredList<PlutoColumnGroup>? get refColumnGroups => _refColumnGroups;

  @override
  set refColumnGroups(FilteredList<PlutoColumnGroup>? setColumnGroups) {
    if (setColumnGroups != null && setColumnGroups.isNotEmpty) {
      _showColumnGroups = true;
    }

    _refColumnGroups = setColumnGroups;

    _setGroupToColumn();
  }

  FilteredList<PlutoColumnGroup>? _refColumnGroups;

  @override
  bool get hasColumnGroups =>
      refColumnGroups != null && refColumnGroups!.isNotEmpty;

  @override
  bool get showColumnGroups => _showColumnGroups == true && hasColumnGroups;

  bool? _showColumnGroups;

  @override
  void setShowColumnGroups(bool flag, {bool notify = true}) {
    if (_showColumnGroups == flag) {
      return;
    }

    _showColumnGroups = flag;

    notifyListeners(notify, setShowColumnGroups.hashCode);
  }

  @override
  List<PlutoColumnGroupPair> separateLinkedGroup({
    required List<PlutoColumnGroup> columnGroupList,
    required List<PlutoColumn> columns,
  }) {
    return PlutoColumnGroupHelper.separateLinkedGroup(
      columnGroupList: columnGroupList,
      columns: columns,
    );
  }

  @override
  int columnGroupDepth(List<PlutoColumnGroup> columnGroupList) {
    return PlutoColumnGroupHelper.maxDepth(
      columnGroupList: columnGroupList,
    );
  }

  @override
  void removeColumnsInColumnGroup(
    List<PlutoColumn> columns, {
    bool notify = true,
  }) {
    if (refColumnGroups?.originalList.isEmpty == true) {
      return;
    }

    final Set<String> columnFields = Set.from(columns.map((e) => e.field));

    refColumnGroups!.removeWhereFromOriginal((group) {
      return _emptyGroupAfterRemoveColumns(
        columnGroup: group,
        columnFields: columnFields,
      );
    });

    notifyListeners(notify, removeColumnsInColumnGroup.hashCode);
  }

  bool _emptyGroupAfterRemoveColumns({
    required PlutoColumnGroup columnGroup,
    required Set<String> columnFields,
  }) {
    if (columnGroup.hasFields) {
      columnGroup.fields!.removeWhere((field) => columnFields.contains(field));
    } else if (columnGroup.hasChildren) {
      columnGroup.children!.removeWhere((child) {
        return _emptyGroupAfterRemoveColumns(
          columnGroup: child,
          columnFields: columnFields,
        );
      });
    }

    return (columnGroup.hasFields && columnGroup.fields!.isEmpty) ||
        (columnGroup.hasChildren && columnGroup.children!.isEmpty);
  }

  void _setGroupToColumn() {
    if (hasColumnGroups == false) {
      return;
    }

    for (final column in refColumns) {
      column.group = PlutoColumnGroupHelper.getParentGroupIfExistsFromList(
        field: column.field,
        columnGroupList: refColumnGroups!,
      );
    }
  }
}
