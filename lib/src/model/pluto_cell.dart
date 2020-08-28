part of '../../pluto_grid.dart';

class PlutoCell {
  /// Value of cell
  dynamic value;

  PlutoCell({
    this.value,
  }) : this._key = UniqueKey();

  Key _key;

  Key get key => _key;
}
