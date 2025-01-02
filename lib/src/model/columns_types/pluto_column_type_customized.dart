import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoColumnTypeCustomized<T> implements PlutoColumnType {
  @override
  final T? defaultValue;

  PlutoColumnTypeCustomized({
    this.defaultValue,
  });

  PlutoGridStateManager? stateManager;
  PlutoCell? cell;
  PlutoColumn? column;
  PlutoRow? row;

  T? _cellValue;
  final TextEditingController _textController = TextEditingController();
  ValueChanged<VoidCallback>? _onSetState;
  ValueChanged<T?>? _setNewValue;
  FocusNode? _focusCellNode;
  _CellEditingStatus _cellEditingStatus = _CellEditingStatus.init;

  String get formattedValue =>
      column?.formattedValueForDisplayInEditing(cell?.value) ?? '';

  void initState() {}

  void initStateManage(
    PlutoGridStateManager stateManager,
    PlutoCell cell,
    PlutoColumn column,
    PlutoRow row,
  ) {
    this.stateManager = stateManager;
    this.cell = cell;
    this.column = column;
    this.row = row;
    _focusCellNode = FocusNode(onKeyEvent: _handleOnKey);

    stateManager.setTextEditingController(_textController);

    _textController.text =
        defaultValue is String ? defaultValue.toString() : '';

    _cellValue = defaultValue;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  void dispose() {}

  Widget build(BuildContext context, PlutoGridStateManager stateManager);

  @override
  bool isValid(value) {
    return value is T;
  }

  @override
  int compare(dynamic a, dynamic b) {
    if (a != T || b != T) {
      return -1;
    }

    if (a == null || b == null) {
      return a == b
          ? 0
          : a == null
              ? -1
              : 1;
    }

    return a.compareTo(b);
  }

  @override
  T makeCompareValue(v) {
    assert(v is T, 'Value is not of type ${T.runtimeType}');

    return v;
  }

  void setOnSetState(ValueChanged<VoidCallback> onSetState) {
    _onSetState = onSetState;
  }

  void setState(VoidCallback fn) {
    _onSetState?.call(fn);
  }

  void setOnNewValue(ValueChanged<T?> handleOnChanged) {
    _setNewValue = handleOnChanged;
  }

  void setNewValue(T? value) {
    _cellValue = value;
    _setNewValue?.call(value);
  }

  FocusNode? get focusCellNode => _focusCellNode;

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text =
        defaultValue is String ? defaultValue.toString() : '';

    stateManager?.changeCellValue(
      stateManager?.currentCell ?? PlutoCell(),
      _cellValue,
      notify: false,
    );
  }

  bool _moveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (column?.readOnly == true) {
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

  void _changeValue() {
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = formattedValue != value.toString()
        ? _CellEditingStatus.changed
        : _cellValue.toString() == value.toString()
            ? _CellEditingStatus.init
            : _CellEditingStatus.updated;
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
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
        keyManager.isF3 ||
        keyManager.isEnter);

    // Propagate key inputs such as string input to the text field, except for movement, Enter key, and left/right movement of read-only cells.
    if (skip && stateManager != null) {
      return stateManager?.keyManager?.eventResult.skip(
            KeyEventResult.ignored,
          ) ??
          KeyEventResult.ignored;
    }

    // The Enter key is propagated to the grid focus handler.
    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    // ESC restores the edited string to the original string.
    if (keyManager.isEsc) {
      _restoreText();
    }

    // Delegate event handling to KeyManager.
    stateManager?.keyManager?.subject.add(keyManager);

    // Handle all events and stop event propagation.
    return KeyEventResult.handled;
  }

  void handleOnTap() {
    stateManager?.setKeepFocus(true);
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
