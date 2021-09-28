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
    return ListView.separated(
      controller: scroll,
      scrollDirection: Axis.horizontal,
      itemCount: columnGroups!.length,
      itemBuilder: (context, index) {
        final columnGroup = columnGroups![index];

        if (columnGroup.hide) {
          return const SizedBox();
        }
        return Align(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(
              Size(columnGroup.width - 0.4, widget.stateManager.columnGroupHeaderHeight),
            ),
            child: columnGroup.title,
          ),
        );
      },
      separatorBuilder: (context, _) {
        if (widget.stateManager.configuration?.enableColumnGroupBorder ?? false) {
          return VerticalDivider(
            width: 0,
            indent: 0,
            endIndent: 0,
            color: widget.stateManager.configuration!.gridBorderColor,
            thickness: 1,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
