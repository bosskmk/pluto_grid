import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_text_cell.dart';

class PlutoTextCell extends StatefulWidget implements AbstractMixinTextCell {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  PlutoTextCell({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _PlutoTextCellState createState() => _PlutoTextCellState();
}

class _PlutoTextCellState extends State<PlutoTextCell>
    with MixinTextCell<PlutoTextCell> {
  @override
  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return buildTextField(
      keyboardType: TextInputType.text,
    );
  }
}
