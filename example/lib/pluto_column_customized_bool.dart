import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnCustomizedBool extends PlutoColumnTypeCustomized<bool> {
  PlutoColumnCustomizedBool({
    super.defaultValue,
  });

  bool? _value;
  FocusNode _focusNode = FocusNode();

  @override
  void initState(
    PlutoGridStateManager stateManager,
    PlutoCell cell,
    PlutoColumn column,
    PlutoRow row,
  ) {
    _value = cell.value ?? defaultValue ?? false;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _value,
      focusNode: _focusNode,
      onChanged: (value) {
        setState(() {
          _value = value ?? false;
          setNewValue(_value);
        });
      },
    );
  }
}
