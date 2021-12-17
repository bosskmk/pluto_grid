import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class AbstractMixinTextCell extends StatefulWidget {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;
  final PlutoRow? row;

  AbstractMixinTextCell({
    this.stateManager,
    this.cell,
    this.column,
    this.row,
  });
}

mixin MixinTextCell<T extends AbstractMixinTextCell> on State<T> {
  final _textController = TextEditingController();

  CellEditingStatus? _cellEditingStatus;

  dynamic _initialCellValue;

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
        _changeValue(notify: false);

        widget.stateManager!.notifyListenersOnPostFrame();
      });
    }

    widget.stateManager!.textEditingController = null;

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKey: _handleOnKey);

    widget.stateManager!.textEditingController = _textController;

    _textController.text = widget.column!.formattedValueForDisplayInEditing(
      widget.cell!.value,
    );

    _initialCellValue = widget.cell!.value;

    _cellEditingStatus = CellEditingStatus.init;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  void _changeValue({bool notify = true}) {
    if (widget.cell!.value.toString() == _textController.text) {
      return;
    }

    widget.stateManager!.changeCellValue(
      widget.cell!,
      _textController.text,
      notify: notify,
    );
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = widget.cell!.value.toString() != value.toString()
        ? CellEditingStatus.changed
        : _initialCellValue.toString() == value.toString()
            ? CellEditingStatus.init
            : CellEditingStatus.updated;
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    if (_cellEditingStatus.isUpdated) {
      _initialCellValue = widget.cell!.value;
      _cellEditingStatus = CellEditingStatus.updated;
    }
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager!.changeCellValue(
      widget.stateManager!.currentCell!,
      _initialCellValue,
      notify: false,
    );
  }

  bool _moveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (widget.column!.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      return true;
    }

    return false;
  }

  KeyEventResult _handleOnKey(FocusNode node, RawKeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final skip = !(keyManager.isVertical ||
        _moveHorizontal(keyManager) ||
        keyManager.isEsc ||
        keyManager.isTab ||
        (keyManager.isEnter &&
            !widget.stateManager!.configuration!.enterKeyAction.isNone));

    // 이동 및 엔터키, 수정불가 셀의 좌우 이동을 제외한 문자열 입력 등의 키 입력은 텍스트 필드로 전파 한다.
    if (skip) {
      /// 2021-11-19
      /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
      /// 이슈 해결 후 :
      /// ```dart
      /// return KeyEventResult.skipRemainingHandlers;
      /// ```
      return widget.stateManager!.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    // 엔터키는 그리드 포커스 핸들러로 전파 한다.
    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    // ESC 는 편집된 문자열을 원래 문자열로 돌이킨다.
    if (keyManager.isEsc) {
      _restoreText();
    }

    // KeyManager 로 이벤트 처리를 위임 한다.
    widget.stateManager!.keyManager!.subject.add(keyManager);

    // 모든 이벤트를 처리 하고 이벤트 전파를 중단한다.
    return KeyEventResult.handled;
  }

  void _handleOnTap() {
    widget.stateManager!.setKeepFocus(true);
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
      readOnly: widget.column!.checkReadOnly(widget.row!, widget.cell!),
      onChanged: _handleOnChanged,
      onEditingComplete: _handleOnComplete,
      onTap: _handleOnTap,
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
