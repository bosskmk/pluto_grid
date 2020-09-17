part of '../../../pluto_grid.dart';

class TextCellWidget extends StatefulWidget implements _TextBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  TextCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _TextCellWidgetState createState() => _TextCellWidgetState();
}

class _TextCellWidgetState extends State<TextCellWidget>
    with _TextBaseMixin<TextCellWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    _cellFocus.requestFocus();

    return _buildTextField(
      keyboardType: TextInputType.text,
    );
  }
}
