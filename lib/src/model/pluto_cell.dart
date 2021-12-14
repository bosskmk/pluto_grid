import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'context/cell_context.dart';

class PlutoCell extends CellContext {
  PlutoCell({
    dynamic value,
  })  : _key = UniqueKey(),
        _value = value;

  /// cell key
  final Key _key;

  Key get key => _key;

  /// cell value
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
    assert(_column != null);

    _valueForSorting ??= _column!.type.makeCompareValue(_value);

    return _valueForSorting;
  }

  /// cell column
  PlutoColumn? _column;

  void setColumn(PlutoColumn column) {
    _column = column;
    _valueForSorting = _getValueForSorting();
  }
}
