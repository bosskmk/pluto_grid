part of pluto_grid;

class PlutoCell {
  /// 셀의 값
  dynamic value;

  PlutoCell({
    this.value,
  }) : this._key = GlobalKey();

  GlobalKey _key;
}
