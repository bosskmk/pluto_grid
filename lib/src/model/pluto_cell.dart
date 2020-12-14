import 'package:flutter/material.dart';

class PlutoCell {
  /// Value of cell
  dynamic value;

  dynamic _originalValue;

  PlutoCell({
    this.value,
    dynamic originalValue,
  })  : _key = UniqueKey(),
        _originalValue = originalValue;

  final Key _key;

  Key get key => _key;

  dynamic get originalValue => _originalValue ?? value;

  set originalValue(dynamic value) {
    _originalValue = value;
  }
}
