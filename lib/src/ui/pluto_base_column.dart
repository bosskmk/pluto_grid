import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseColumn extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final double? columnTitleHeight;

  PlutoBaseColumn({
    required this.stateManager,
    required this.column,
    this.columnTitleHeight,
  }) : super(key: column.key);

  @override
  _PlutoBaseColumnState createState() => _PlutoBaseColumnState();
}

abstract class _PlutoBaseColumnStateWithChange
    extends PlutoStateWithChange<PlutoBaseColumn> {
  bool? _showColumnFilter;

  @override
  void onChange() {
    resetState((update) {
      _showColumnFilter = update<bool?>(
        _showColumnFilter,
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
          height: widget.columnTitleHeight ?? widget.stateManager.columnHeight,
        ),
        if (_showColumnFilter!)
          PlutoColumnFilter(
            stateManager: widget.stateManager,
            column: widget.column,
          ),
      ],
    );
  }
}
