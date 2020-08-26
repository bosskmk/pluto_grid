part of '../../../pluto_grid.dart';

abstract class _TextBaseMixinImpl extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  _TextBaseMixinImpl({
    this.stateManager,
    this.cell,
    this.column,
  });
}

mixin _TextBaseMixin<T extends _TextBaseMixinImpl> on State<T> {
  final _textController = TextEditingController();
  final FocusNode _cellFocus = FocusNode();

  _CellEditingStatus _cellEditingStatus;

  @override
  void dispose() {
    _textController.dispose();
    _cellFocus.dispose();

    /**
     * 텍스트 입력 상태에서 셀 이동을 하는 경우 변경 된 값을 저장.
     * 엔터를 입력하지 않으면 onEditingComplete 가 호출 되지 않아 값이 저장 되지 않음.
     */
    if (_cellEditingStatus.isChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _changeValue();
      });
    }

    super.dispose();
  }

  @override
  void initState() {
    _textController.text = widget.cell.value.toString();
    _cellEditingStatus = _CellEditingStatus.INIT;

    super.initState();
  }

  void _changeValue() {
    widget.stateManager
        .changeCellValue(widget.cell._key, _textController.text);
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = _CellEditingStatus.CHANGED;
  }

  void _handleOnComplete() {
    _cellEditingStatus = _CellEditingStatus.UPDATED;
    _cellFocus.unfocus();
    widget.stateManager.gridFocusNode.requestFocus();
    _changeValue();
  }

  TextField _buildTextField({
    TextInputType keyboardType,
    List<TextInputFormatter> inputFormatters,
    style = PlutoDefaultSettings.cellTextStyle,
    decoration = const InputDecoration(
      border: InputBorder.none,
      contentPadding: const EdgeInsets.all(0),
      isDense: true,
    ),
    maxLines = 1,
  }) {
    return TextField(
      focusNode: _cellFocus,
      controller: _textController,
      readOnly: widget.column.type.readOnly,
      onChanged: _handleOnChanged,
      onEditingComplete: _handleOnComplete,
      style: style,
      decoration: decoration,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    _cellFocus.requestFocus();

    return _buildTextField();
  }
}
