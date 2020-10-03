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

  /// Callback function that returns Header to be inserted at the top of the popup
  /// Implement a callback function that takes [PlutoStateManager] as a parameter.
  CreateHeaderCallBack createHeader;

  /// Callback function that returns Footer to be inserted at the bottom of the popup
  /// Implement a callback function that takes [PlutoStateManager] as a parameter.
  CreateFooterCallBack createFooter;

  @override
  void dispose() {
    widget.stateManager.resetKeyPressed();

    _textController.dispose();

    _keyboardFocus.dispose();

    _textFocus.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController()
      ..text = widget.cell.value.toString();

    _keyboardFocus = FocusNode(onKey: _handleKeyboardFocusOnKey);

    _textFocus = FocusNode();
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
          }) +
          1,
      height: popupHeight,
      createHeader: createHeader,
      createFooter: createFooter,
      configuration: widget.stateManager.configuration,
    );
  }

  bool _handleKeyboardFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    KeyManagerEvent keyManagerEvent = KeyManagerEvent(
      focusNode: focusNode,
      event: event,
    );

    if (keyManagerEvent.isKeyDownEvent) {
      if (keyManagerEvent.isF2 || keyManagerEvent.isCharacter) {
        if (_isOpenedPopup != true) {
          openPopup();
          return true;
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
                .setCurrentCell(event.stateManager._rows[i].cells[entry.key], i);
            break;
          }
        }
      } else {
        if (popupRows[i].cells[fieldOnSelected].originalValue ==
            widget.cell.originalValue) {
          event.stateManager.setCurrentCell(
              event.stateManager._rows[i].cells[fieldOnSelected], i);
          break;
        }
      }
    }

    if (event.stateManager.currentRowIdx != null) {
      final rowIdxToMove =
          event.stateManager.currentRowIdx + 1 + offsetOfScrollRowIdx;

      if (rowIdxToMove < event.stateManager._rows.length) {
        event.stateManager.moveScrollByRow(MoveDirection.Up, rowIdxToMove);
      } else {
        event.stateManager
            .moveScrollByRow(MoveDirection.Up, event.stateManager._rows.length);
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
      _textController.text = widget.stateManager.currentCell.value.toString();
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
    if (widget.stateManager.keepFocus) {
      _textFocus.requestFocus();
    }

    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextField(
            controller: _textController,
            focusNode: _textFocus,
            readOnly: true,
            textInputAction: TextInputAction.none,
            onTap: openPopup,
            style: widget.stateManager.configuration.cellTextStyle,
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
              color: widget.stateManager.configuration.iconColor,
              onPressed: openPopup,
            ),
          ),
        ],
      ),
    );
  }
}
