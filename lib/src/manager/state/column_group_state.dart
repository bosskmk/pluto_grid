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

    if (notify) {
      notifyListeners();
    }
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
}
