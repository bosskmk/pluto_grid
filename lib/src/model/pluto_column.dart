part of pluto_grid;

class PlutoColumn {
  /// 화면에 표시 할 제목 입니다.
  String title;

  /// 컬럼에 연결 될 row 의 Field 이름을 지정 합니다.
  String field;

  /// 컬럼의 넓이를 고정 합니다.
  double width;

  /// 컬럼을 좌,우측으로 고정 입니다.
  PlutoColumnFixed fixed;

  /// 컬럼 정렬을 설정 합니다.
  PlutoColumnSort sort;

  /// 컬럼 종류를 설정 합니다.
  PlutoColumnType type;

  PlutoColumn({
    @required this.title,
    @required this.field,
    @required this.type,
    this.width = PlutoDefaultSettings.columnWidth,
    this.fixed = PlutoColumnFixed.None,
    this.sort = PlutoColumnSort.None,
  }) : this._key = GlobalKey();

  /// Column key
  Key _key;
}

enum PlutoColumnFixed {
  None,
  Left,
  Right,
}

extension PlutoColumnFixedExtension on PlutoColumnFixed {
  bool get isNone {
    return this == null || this == PlutoColumnFixed.None;
  }

  bool get isLeft {
    return this == PlutoColumnFixed.Left;
  }

  bool get isRight {
    return this == PlutoColumnFixed.Right;
  }

  bool get isFixed {
    return this == PlutoColumnFixed.Left || this == PlutoColumnFixed.Right;
  }
}

enum PlutoColumnSort {
  None,
  Ascending,
  Descending,
}

class PlutoColumnType {
  /// 문자열 컬럼으로 설정 합니다.
  PlutoColumnType.text({
    this.readOnly = false,
  }) : this._name = _PlutoColumnTypeName.Text;

  /// 숫자 컬럼으로 설정 합니다.
  PlutoColumnType.number({
    this.readOnly = false,
  }) : this._name = _PlutoColumnTypeName.Number;

  /// 선택 목록을 제공하여 선택 컬럼으로 설정 합니다.
  PlutoColumnType.select(
    List<dynamic> items, {
    this.readOnly = false,
  })  : this._name = _PlutoColumnTypeName.Select,
        this.selectItems = items;

  /// 컬럼 종류의 이름 입니다.
  _PlutoColumnTypeName _name;

  bool readOnly;

  /// Select 컬럼인 경우 선택 할 목록 입니다.
  List<dynamic> selectItems;
}

enum _PlutoColumnTypeName {
  Text,
  Number,
  Select,
}
