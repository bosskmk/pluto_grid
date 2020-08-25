part of '../../../pluto_grid.dart';

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

  FocusNode _keyboardFocus;

  FocusNode _textFocus;

  bool _isOpenedPopup = false;

  @override
  void initState() {
    _textController.text = widget.cell.value;

    _keyboardFocus = FocusNode(onKey: _handleKeyboardFocusOnKey);

    _textFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();

    _keyboardFocus.dispose();

    _textFocus.dispose();

    super.dispose();
  }

  void openPopup() {
    if (widget.column.type.readOnly) {
      return;
    }

    _isOpenedPopup = true;

    PlutoGridPopup(
      context: context,
      mode: PlutoMode.SelectRow,
      onLoaded: (PlutoOnLoadedEvent event) {
        final i = widget.column.type.selectItems.indexOf(widget.cell.value);

        if (i < 0) {
          return;
        }

        event.stateManager.setCurrentCell(
            event.stateManager.rows[i].cells.entries.first.value, i);
      },
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

  bool _handleKeyboardFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.logicalKey.keyId == LogicalKeyboardKey.f2.keyId ||
          event.logicalKey.keyLabel != null) {
        if (_isOpenedPopup != true) {
          openPopup();
        }
      }
    }
    return false;
  }

  void _handleSelected(String value) {
    widget.stateManager.handleAfterSelectingRow(widget.cell, value);

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
    _textFocus.requestFocus();

    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      child: Stack(
        children: [
          TextField(
            controller: _textController,
            focusNode: _textFocus,
            readOnly: true,
            onTap: openPopup,
            style: TextStyle(
              fontSize: PlutoDefaultSettings.cellFontSize,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(0),
              isDense: true,
            ),
            maxLines: 1,
          ),
          Positioned(
            top: -12,
            right: -12,
            child: IconButton(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black54,
              ),
              onPressed: openPopup,
            ),
          ),
        ],
      ),
    );
  }
}
