part of pluto_grid;

class SelectCellWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  SelectCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _SelectCellWidgetState createState() => _SelectCellWidgetState();
}

class _SelectCellWidgetState extends State<SelectCellWidget> {
  final _textController = TextEditingController();
  final FocusNode _keyboardFocus = FocusNode();
  bool _isOpenedPopup = false;

  @override
  void initState() {
    _textController.text = widget.cell.value;
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void openPopup() {
    _isOpenedPopup = true;
    _keyboardFocus.unfocus();
    widget.stateManager.gridFocusNode.unfocus();
    PlutoGridPopup(
      context: context,
      mode: PlutoMode.SelectRow,
      onSelectedRow: (row) {
        if (row != null) {
          _handleSelected(row.cells.entries.first.value.value);
        }
        _isOpenedPopup = false;
      },
      columns: [
        PlutoColumn(
          title: widget.column.title,
          field: widget.column.title,
          type: PlutoColumnType.text(readOnly: true),
        )
      ],
      rows: widget.column.type.selectItems.map((dynamic item) {
        return PlutoRow(
          cells: {
            widget.column.title: PlutoCell(value: item),
          },
        );
      }).toList(),
    );
  }

  void _handleSelected(String value) {
    widget.stateManager.changedCellValue(widget.cell._key, value);

    try {
      _textController.text = value;
    } catch (e) {
      /**
       * Popup 이 열릴 때 TextField 가 닫히면서
       * _textController 가 dispose 되어
       * Popup 에서 _handleSelected 를 호출 할 때
       * _textController 에러.
       *
       * Popup 이 닫힐 때 TextField 가 닫히지 않고 유지되고 있으면 오류 없음.
       *
       * TODO : 위젯 구조를 변경...
       */
      developer.log('TODO', name: 'dropdown_cell', error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpenedPopup != true) {
      FocusScope.of(context).requestFocus(_keyboardFocus);
    }

    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      onKey: (RawKeyEvent event) {
        if (event.runtimeType == RawKeyDownEvent) {
          if (event.logicalKey.keyId == LogicalKeyboardKey.enter.keyId) {
            if (_isOpenedPopup != true) {
              openPopup();
            }
          }
        }
      },
      child: TextField(
        controller: _textController,
        readOnly: true,
        onTap: () {
          openPopup();
        },
        style: TextStyle(
          fontSize: 18,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(0),
          isDense: true,
        ),
        maxLines: 1,
      ),
    );
  }
}
