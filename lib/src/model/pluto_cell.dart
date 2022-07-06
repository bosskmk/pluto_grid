import 'package:flutter/material.dart';

import 'pluto_column.dart';
import 'pluto_row.dart';

class PlutoCell {
  PlutoCell({
    dynamic value,
  })  : _key = UniqueKey(),
        _value = value;

  final Key _key;

  Key get key => _key;

  dynamic _value;

  dynamic get value => _value;

  set value(dynamic changed) {
    if (_value == changed) {
      return;
    }

    _value = changed;

    _valueForSorting = null;
  }

  dynamic _valueForSorting;

  dynamic get valueForSorting {
    _valueForSorting ??= _getValueForSorting();

    return _valueForSorting;
  }

  dynamic _getValueForSorting() {
    _valueForSorting ??= _column.type.makeCompareValue(_value);

    return _valueForSorting;
  }

  PlutoColumn get column => _column;

  late PlutoColumn _column;

  void setColumn(PlutoColumn column) {
    _column = column;
    _valueForSorting = _getValueForSorting();
  }

  PlutoRow get row => _row;

  late PlutoRow _row;

  void setRow(PlutoRow row) {
    _row = row;
  }
}
