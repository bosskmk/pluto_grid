import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnGroupState {
  List<PlutoColumnGroup> get columnGroups;

  FilteredList<PlutoColumnGroup>? refColumnGroups;

  bool get hasColumnGroups;
}

mixin ColumnGroupState implements IPlutoGridState {
  List<PlutoColumnGroup> get columnGroups => [...refColumnGroups!];

  FilteredList<PlutoColumnGroup>? get refColumnGroups => _refColumnGroups;

  set refColumnGroups(FilteredList<PlutoColumnGroup>? setColumnGroups) {
    _refColumnGroups = setColumnGroups;
  }

  FilteredList<PlutoColumnGroup>? _refColumnGroups;

  bool get hasColumnGroups =>
      refColumnGroups != null && refColumnGroups!.isNotEmpty;
}
