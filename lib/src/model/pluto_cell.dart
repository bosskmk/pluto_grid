import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'pluto_column.dart';
import 'pluto_column_type.dart';

class PlutoCell {
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
    if (_valueForSorting != null) {
      return _valueForSorting;
    }

    assert(_column != null);

    if (_column.type.isText) {
      _valueForSorting = _value.toString();
    } else if (_column.type.isNumber) {
      _valueForSorting = _value.runtimeType != num
          ? num.tryParse(_value.toString()) ?? 0
          : _value;
    } else if (_column.type.isDate) {
      PlutoColumnTypeDate dateColumn = _column.type;

      final dateFormat = intl.DateFormat(dateColumn.format);

      DateTime dateFormatValue;

      try {
        dateFormatValue = dateFormat.parse(_value);
      } catch (e) {
        dateFormatValue = _column.type.defaultValue;
      }

      _valueForSorting = dateFormatValue;
    } else {
      _valueForSorting = _value;
    }

    return _valueForSorting;
  }

  /// cell column
  PlutoColumn _column;

  void setColumn(PlutoColumn column) {
    _column = column;
    _valueForSorting = _getValueForSorting();
  }
}
