import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class AbstractMixinTextCell extends StatefulWidget {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;

  AbstractMixinTextCell({
    this.stateManager,
    this.cell,
    this.column,
  });
}

mixin MixinTextCell<T extends AbstractMixinTextCell> on State<T> {
  final _textController = TextEditingController();

  CellEditingStatus? _cellEditingStatus;

  FocusNode? cellFocus;

  @override
  void dispose() {
    _textController.dispose();

    cellFocus!.dispose();

    /**
     * Saves the changed value when moving a cell while text is being input.
     * if user do not press enter key, onEditingComplete is not called and the value is not saved.
     */
    if (_cellEditingStatus.isChanged) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _changeValue();
      });
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKey: _handleOnKey);

    _textController.text = widget.column!.formattedValueForDisplayInEditing(
      widget.cell!.value,
    );

    _cellEditingStatus = CellEditingStatus.init;
  }

  void _changeValue() {
    widget.stateManager!
        .changeCellValue(widget.cell!.key, _textController.text);
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = CellEditingStatus.changed;
  }

  void _handleOnComplete() {
    _cellEditingStatus = CellEditingStatus.updated;

    cellFocus!.unfocus();

    widget.stateManager!.gridFocusNode!.requestFocus();

    _changeValue();
  }

  KeyEventResult _handleOnKey(FocusNode node, RawKeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isEsc) {
      _textController.text =
          widget.stateManager!.cellValueBeforeEditing.toString();

      widget.stateManager!.changeCellValue(
        widget.stateManager!.currentCell!.key,
        widget.stateManager!.cellValueBeforeEditing,
        notify: false,
      );
    }

    return KeyEventResult.ignored;
  }

  TextField buildTextField({
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextStyle? style,
    InputDecoration decoration = const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(0),
      isDense: true,
    ),
    int maxLines = 1,
  }) {
    return TextField(
      focusNode: cellFocus,
      controller: _textController,
      readOnly: widget.column!.type!.readOnly!,
      onChanged: _handleOnChanged,
      onEditingComplete: _handleOnComplete,
      style: style ?? widget.stateManager!.configuration!.cellTextStyle,
      decoration: decoration,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters ?? [],
      textAlign: widget.column!.textAlign.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager!.keepFocus) {
      cellFocus!.requestFocus();
    }

    return buildTextField();
  }
}
