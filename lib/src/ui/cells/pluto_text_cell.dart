part of '../../../pluto_grid.dart';

class PlutoTextCell extends StatefulWidget implements _AbstractMixinTextCell {
  final PlutoStateManager stateManager;
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
    with _MixinTextCell<PlutoTextCell> {
  @override
  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      _cellFocus.requestFocus();
    }

    return _buildTextField(
      keyboardType: TextInputType.text,
    );
  }
}
