import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRowGroup extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final PlutoRowGroup rowGroup;

  final List<PlutoColumn> columns;

  const PlutoBaseRowGroup({
    required this.stateManager,
    required this.rowGroup,
    required this.columns,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(rowGroup.title);
  }
}
