part of '../../pluto_grid.dart';

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
  }) : this._key = UniqueKey();

  /// Column key
  Key _key;

  Key get key => _key;
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

extension PlutoColumnSortExtension on PlutoColumnSort {
  bool get isNone {
    return this == null || this == PlutoColumnSort.None;
  }

  bool get isAscending {
    return this == PlutoColumnSort.Ascending;
  }

  bool get isDescending {
    return this == PlutoColumnSort.Descending;
  }

  String toShortString() {
    return this.toString().split('.').last;
  }

  PlutoColumnSort fromString(String value) {
    if (value == PlutoColumnSort.Ascending.toShortString()) {
      return PlutoColumnSort.Ascending;
    } else if (value == PlutoColumnSort.Descending.toShortString()) {
      return PlutoColumnSort.Descending;
    } else {
      return PlutoColumnSort.None;
    }
  }
}

class PlutoColumnType {
  /// 문자열 컬럼으로 설정 합니다.
  PlutoColumnType.text({
    this.readOnly = false,
  }) : this.name = _PlutoColumnTypeName.Text;

  /// 숫자 컬럼으로 설정 합니다.
  PlutoColumnType.number({
    this.readOnly = false,
    this.format = '#,###',
    this.negative = true,
    this.applyFormatOnInit = true,
  }) : this.name = _PlutoColumnTypeName.Number;

  /// 선택 목록을 제공하여 선택 컬럼으로 설정 합니다.
  PlutoColumnType.select(
    List<dynamic> items, {
    this.readOnly = false,
  })  : this.name = _PlutoColumnTypeName.Select,
        this.selectItems = items;

  PlutoColumnType.datetime({
    this.startDate,
    this.endDate,
    this.readOnly = false,
    this.format = 'yyyy-MM-dd',
    this.applyFormatOnInit = true,
  }) : this.name = _PlutoColumnTypeName.Datetime;

  /// 컬럼 종류의 이름 입니다.
  _PlutoColumnTypeName name;

  bool readOnly;

  String format;

  bool negative;

  bool applyFormatOnInit;

  DateTime startDate;

  DateTime endDate;

  /// Select 컬럼인 경우 선택 할 목록 입니다.
  List<dynamic> selectItems;

  String numberFormat(value) {
    final f = intl.NumberFormat(format);
    double num =
        double.tryParse(value.toString().replaceAll(f.symbols.GROUP_SEP, '')) ??
            0;
    return f.format(num);
  }

  int decimalRange() {
    final int dotIndex = format.indexOf('.');

    return dotIndex < 0 ? 0 : format.substring(dotIndex).length - 1;
  }
}

enum _PlutoColumnTypeName {
  Text,
  Number,
  Select,
  Datetime,
}

extension _PlutoColumnTypeNameExtension on _PlutoColumnTypeName {
//  bool get isText {
//    return this == _PlutoColumnTypeName.Text;
//  }
//
  bool get isNumber {
    return this == _PlutoColumnTypeName.Number;
  }

  bool get isSelect {
    return this == _PlutoColumnTypeName.Select;
  }

  bool get isDatetime {
    return this == _PlutoColumnTypeName.Datetime;
  }
}
