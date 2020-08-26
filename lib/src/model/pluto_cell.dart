part of '../../pluto_grid.dart';

class PlutoCell {
  /// 셀의 값
  dynamic value;

  PlutoCell({
    this.value,
  }) : this._key = UniqueKey();

  Key _key;

  Key get key => _key;
}
