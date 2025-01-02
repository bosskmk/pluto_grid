// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:pluto_grid/pluto_grid.dart';

class PlutoCustomizedCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumnTypeCustomized customizedType;
  final PlutoCell cell;
  final PlutoColumn column;
  final PlutoRow row;

  const PlutoCustomizedCell({
    Key? key,
    required this.stateManager,
    required this.customizedType,
    required this.cell,
    required this.column,
    required this.row,
  }) : super(key: key);

  @override
  State<PlutoCustomizedCell> createState() => _PlutoCustomizedCellState();
}

class _PlutoCustomizedCellState extends State<PlutoCustomizedCell> {
  PlutoGridStateManager get stateManager => widget.stateManager;
  PlutoColumnTypeCustomized get customizedType => widget.customizedType;
  PlutoCell get cell => widget.cell;
  PlutoColumn get column => widget.column;
  PlutoRow get row => widget.row;

  @override
  void initState() {
    super.initState();

    customizedType.setOnSetState(setState);
    customizedType.setOnNewValue(_setNewValue);

    customizedType.initStateManage(stateManager, cell, column, row);
    customizedType.initState();
  }

  void _setNewValue(dynamic newValue) {
    stateManager.changeCellValue(cell, newValue);
  }

  @override
  void dispose() {
    super.dispose();
    customizedType.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return customizedType.build(context, stateManager);
  }
}
