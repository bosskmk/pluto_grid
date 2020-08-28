part of '../../../pluto_grid.dart';

abstract class _PopupBaseMixinImpl extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  _PopupBaseMixinImpl({
    this.stateManager,
    this.cell,
    this.column,
  });
}

abstract class _PopupImpl {
  List<PlutoColumn> popupColumns;

  List<PlutoRow> popupRows;

  Icon icon;
}

mixin _PopupBaseMixin<T extends _PopupBaseMixinImpl> on State<T>
    implements _PopupImpl {
  TextEditingController _textController;

  FocusNode _keyboardFocus;

  FocusNode _textFocus;

  bool _isOpenedPopup = false;

  @override
  void initState() {
    _textController = TextEditingController()
      ..text = widget.cell.value.toString();

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
      onLoaded: _onLoaded,
      onSelectedRow: _onSelectedRow,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns.fold(0, (previous, column) {
        return previous + column.width;
      }),
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

  void _onLoaded(PlutoOnLoadedEvent event) {
    for (var i = 0; i < popupRows.length; i += 1) {
      if (popupRows[i].cells.entries.first.value.value == widget.cell.value) {
        event.stateManager.setCurrentCell(
            event.stateManager.rows[i].cells.entries.first.value, i);

        event.stateManager.moveScrollByRow(MoveDirection.Up, i + 1);
        return;
      }
    }
  }

  void _onSelectedRow(PlutoRow row) {
    if (row != null) {
      _handleSelected(row.cells.entries.first.value.value);
    }
    _isOpenedPopup = false;
  }

  void _handleSelected(dynamic value) {
    widget.stateManager.handleAfterSelectingRow(widget.cell, value);

    try {
      _textController.text = value.toString();
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
        overflow: Overflow.visible,
        children: [
          TextField(
            controller: _textController,
            focusNode: _textFocus,
            readOnly: true,
            onTap: openPopup,
            style: PlutoDefaultSettings.cellTextStyle,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(0),
              isDense: true,
            ),
            maxLines: 1,
          ),
          Positioned(
            top: -14,
            right: -12,
            child: IconButton(
              icon: icon,
              onPressed: openPopup,
            ),
          ),
        ],
      ),
    );
  }
}
