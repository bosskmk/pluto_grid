part of '../../pluto_grid.dart';

class PlutoCell {
  /// Value of cell
  dynamic value;

  dynamic _originalValue;

  PlutoCell({
    this.value,
    dynamic originalValue,
  })  : this._key = UniqueKey(),
        this._originalValue = originalValue;

  Key _key;

  Key get key => _key;

  dynamic get originalValue => _originalValue ?? value;

  set originalValue(dynamic value) {
    _originalValue = value;
  }
}
