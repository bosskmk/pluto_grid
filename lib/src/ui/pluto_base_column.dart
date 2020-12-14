import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseColumn extends PlutoStatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoColumn column;

  PlutoBaseColumn({
    this.stateManager,
    this.column,
  }) : super(key: column.key);

  @override
  _PlutoBaseColumnState createState() => _PlutoBaseColumnState();
}

abstract class _PlutoBaseColumnStateWithChange
    extends PlutoStateWithChange<PlutoBaseColumn> {
  bool showColumnFilter;

  @override
  void onChange() {
    resetState((update) {
      showColumnFilter = update<bool>(
        showColumnFilter,
        widget.stateManager.showColumnFilter,
      );
    });
  }
}

class _PlutoBaseColumnState extends _PlutoBaseColumnStateWithChange {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlutoColumnTitle(
          stateManager: widget.stateManager,
          column: widget.column,
        ),
        if (showColumnFilter)
          PlutoColumnFilter(
            stateManager: widget.stateManager,
            column: widget.column,
          ),
      ],
    );
  }
}
