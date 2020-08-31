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

  /// If a column field name is specified,
  /// the value of the field is returned even if another cell is selected.
  ///
  /// If the column field name is not specified,
  /// the value of the selected cell is returned.
  String fieldOnSelected;

  double popupHeight;

  int offsetOfScrollRowIdx = 0;

  /// Callback function that returns Footer to be inserted at the bottom of the popup
  /// Implement a callback function that takes [PlutoStateManager] as a parameter.
  CreateFooterCallBack createFooter;

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
      mode: PlutoMode.Select,
      onLoaded: _onLoaded,
      onSelected: _onSelected,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns.fold(0, (previous, column) {
        return previous + column.width;
      }),
      height: popupHeight,
      createFooter: createFooter,
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
      if (fieldOnSelected == null) {
        for (var entry in popupRows[i].cells.entries) {
          if (popupRows[i].cells[entry.key].originalValue ==
              widget.cell.originalValue) {
            event.stateManager
                .setCurrentCell(event.stateManager.rows[i].cells[entry.key], i);

            event.stateManager.moveScrollByRow(
                MoveDirection.Up, i + 1 + offsetOfScrollRowIdx);
            return;
          }
        }
      } else {
        if (popupRows[i].cells[fieldOnSelected].originalValue ==
            widget.cell.originalValue) {
          event.stateManager.setCurrentCell(
              event.stateManager.rows[i].cells[fieldOnSelected], i);

          event.stateManager
              .moveScrollByRow(MoveDirection.Up, i + 1 + offsetOfScrollRowIdx);
          return;
        }
      }
    }
  }

  void _onSelected(PlutoOnSelectedEvent event) {
    _isOpenedPopup = false;

    if (event == null) {
      return;
    }

    dynamic selectedValue;

    if (event.row != null &&
        fieldOnSelected != null &&
        event.row.cells.containsKey(fieldOnSelected)) {
      selectedValue = event.row.cells[fieldOnSelected].originalValue;
    } else if (event.cell != null) {
      selectedValue = event.cell.originalValue;
    } else {
      return;
    }

    _handleSelected(selectedValue);
  }

  void _handleSelected(dynamic value) {
    widget.stateManager.handleAfterSelectingRow(widget.cell, value);

    try {
      _textController.text = value.toString();
    } catch (e) {
      /**
       * When the Popup is opened, the TextField is closed
       * _textController is dispose
       * When calling _handleSelected in Popup
       * _textController error.
       *
       * TODO : Change widget structure...
       */
      developer.log('TODO', name: 'popup_base_mixin', error: e.toString());
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
