import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/model/pluto_column_group.dart';

class PlutoBodyColumnGroups extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  PlutoBodyColumnGroups(this.stateManager);

  @override
  _PlutoBodyColumnGroupsState createState() => _PlutoBodyColumnGroupsState();
}

abstract class _PlutoBodyColumnGroupsStateWithChange
    extends PlutoStateWithChange<PlutoBodyColumnGroups> {
  List<PlutoColumnGroup>? columnGroups;

  @override
  void onChange() {
    resetState((update) {
      columnGroups = update<List<PlutoColumnGroup>?>(
        columnGroups,
        _getColumnGroups(),
        compare: const DeepCollectionEquality().equals,
      );
    });
  }

  List<PlutoColumnGroup> _getColumnGroups() => widget.stateManager.columnGroups;
}

class _PlutoBodyColumnGroupsState extends _PlutoBodyColumnGroupsStateWithChange {
  ScrollController? scroll;

  @override
  void initState() {
    super.initState();
    scroll = widget.stateManager.scroll!.horizontal!.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scroll,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: columnGroups!
            .map(
              (e) => e.hide
                  ? const SizedBox()
                  : ConstrainedBox(
                      constraints: BoxConstraints.tight(
                        Size(e.width, widget.stateManager.columnGroupHeaderHeight),
                      ),
                      child: e.title,
                    ),
            )
            .toList(),
      ),
    );
  }
}
