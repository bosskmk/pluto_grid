import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/model/pluto_column_group.dart';

import '../pluto_grid_state_manager.dart';

abstract class IColumnGroupState {
  /// ColumnGroups provided at grid start.
  List<PlutoColumnGroup> get columnGroups;

  FilteredList<PlutoColumnGroup>? refColumnGroups;

  /// Width of the entire column group.
  double get columnGroupsWidth;

  void hideColumnGroup(
    Key columnKey,
    bool flag, {
    bool notify = true,
  });

  // TODO: Add more methods that can be applied on a group level.
}

mixin ColumnGroupState implements IPlutoGridState {
  List<PlutoColumnGroup> get columnGroups => [...?refColumnGroups];

  FilteredList<PlutoColumnGroup>? _refColumnGroups;
  FilteredList<PlutoColumnGroup>? get refColumnGroups => _refColumnGroups;
  set refColumnGroups(FilteredList<PlutoColumnGroup>? columnGroups) {
    _refColumnGroups = columnGroups;
    _refColumnGroups!.setFilter((element) => element.hide == false);
  }

  double get columnGroupsWidth => columnGroups.fold(0, (sum, group) => sum + group.width);

  void hideColumnGroup(
    Key columnKey,
    bool flag, {
    bool notify = true,
  }) {
    var found = refColumnGroups!.originalList.firstWhereOrNull(
      (element) => element.key == columnKey,
    );

    if (found == null || found.hide == flag) {
      return;
    }

    found.hide = flag;

    refColumns!.update();
    refColumnGroups!.update();

    resetCurrentState(notify: false);

    if (notify) {
      notifyListeners();
    }
  }
}
