part of pluto_grid;

class TextCellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;

  TextCellWidget({
    this.stateManager,
    this.cell,
  });

  @override
  _TextCellWidgetState createState() => _TextCellWidgetState();
}

class _TextCellWidgetState extends State<TextCellWidget> {
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
    _textController.text = widget.cell.value;
    _cellEditingStatus = _CellEditingStatus.INIT;

    super.initState();
  }

  void _selection() {
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.value.text.length,
    );
  }

  void _changeValue() {
    widget.stateManager.changedCellValue(widget.cell._key, _textController.text);
  }

  @override
  Widget build(BuildContext context) {
    _cellFocus.requestFocus();

    return TextField(
      focusNode: _cellFocus,
      controller: _textController,
      style: TextStyle(
        fontSize: 18,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(0),
        isDense: true,
      ),
      maxLines: 1,
      onChanged: (String value) {
        _cellEditingStatus = _CellEditingStatus.CHANGED;
      },
      onEditingComplete: () {
        _cellEditingStatus = _CellEditingStatus.UPDATED;
        _cellFocus.unfocus();
        widget.stateManager.gridFocusNode.requestFocus();
        _changeValue();
      },
      onTap: () => _selection(),
    );
  }
}

enum _CellEditingStatus {
  INIT,
  CHANGED,
  UPDATED,
}

extension _CellEditingStatusExtension on _CellEditingStatus {
  bool get isChanged {
    return _CellEditingStatus.CHANGED == this;
  }
}
