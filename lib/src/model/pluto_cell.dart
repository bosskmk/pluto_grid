import 'package:flutter/material.dart';

class PlutoCell {
  /// Value of cell
  dynamic value;

  PlutoCell({
    this.value,
  }) : _key = UniqueKey();

  final Key _key;

  Key get key => _key;
}
