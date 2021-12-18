import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_text_cell.dart';

class PlutoTextCell extends StatefulWidget implements AbstractMixinTextCell {
  @override
  final PlutoGridStateManager? stateManager;

  @override
  final PlutoCell? cell;

  @override
  final PlutoColumn? column;

  @override
  final PlutoRow? row;

  const PlutoTextCell({
    this.stateManager,
    this.cell,
    this.column,
    this.row,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoTextCellState createState() => _PlutoTextCellState();
}

class _PlutoTextCellState extends State<PlutoTextCell>
    with MixinTextCell<PlutoTextCell> {
  @override
  Widget build(BuildContext context) {
    if (widget.stateManager!.keepFocus) {
      cellFocus!.requestFocus();
    }

    return buildTextField(
      keyboardType: TextInputType.text,
    );
  }
}
