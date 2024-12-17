import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoColumnTypeCustomized<T> implements PlutoColumnType {
  @override
  final T? defaultValue;

  PlutoColumnTypeCustomized({
    this.defaultValue,
  });

  ValueChanged<VoidCallback>? _onSetState;
  ValueChanged<T?>? _setNewValue;

  void initState(
    PlutoGridStateManager stateManager,
    PlutoCell cell,
    PlutoColumn column,
    PlutoRow row,
  ) {}

  void dispose() {}

  Widget build(BuildContext context);

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
    _setNewValue?.call(value);
  }
}
