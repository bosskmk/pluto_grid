part of '../../pluto_grid.dart';

class PlutoCell {
  /// Value of cell
  dynamic value;

  dynamic originalValue;

  PlutoCell({
    this.value,
    this.originalValue,
  }) : this._key = UniqueKey();

  Key _key;

  Key get key => _key;
}
