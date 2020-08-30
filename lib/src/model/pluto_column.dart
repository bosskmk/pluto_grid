part of '../../pluto_grid.dart';

class PlutoColumn {
  /// A title to be displayed on the screen.
  String title;

  /// Specifies the field name of the row to be connected to the column.
  String field;

  /// Set the width of the column.
  double width;

  /// Fix the column to the left and right.
  PlutoColumnFixed fixed;

  /// Set column sorting.
  PlutoColumnSort sort;

  /// Set the column type.
  PlutoColumnType type;

  bool enableDraggable;

  bool enableSorting;

  bool enableContextMenu;

  PlutoColumn({
    @required this.title,
    @required this.field,
    @required this.type,
    this.width = PlutoDefaultSettings.columnWidth,
    this.fixed = PlutoColumnFixed.None,
    this.sort = PlutoColumnSort.None,
    this.enableDraggable = true,
    this.enableSorting = true,
    this.enableContextMenu = true,
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
  /// Set as a string column.
  PlutoColumnType.text({
    this.readOnly = false,
  }) : this.name = _PlutoColumnTypeName.Text;

  /// Set to numeric column.
  ///
  /// [format]
  /// '#,###' (Comma every three digits)
  /// '#,###.###' (Allow three decimal places)
  ///
  /// [negative] Allow negative numbers
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  PlutoColumnType.number({
    this.readOnly = false,
    this.format = '#,###',
    this.negative = true,
    this.applyFormatOnInit = true,
  }) : this.name = _PlutoColumnTypeName.Number;

  /// Provides a selection list and sets it as a selection column.
  PlutoColumnType.select(
    List<dynamic> items, {
    this.readOnly = false,
  })  : this.name = _PlutoColumnTypeName.Select,
        this.selectItems = items;

  /// Set as a date column.
  ///
  /// [startDate] Range start date (If there is no value, Can select the date without limit)
  ///
  /// [endDate] Range end date
  ///
  /// [format] 'yyyy-MM-dd' (2020-01-01)
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  PlutoColumnType.datetime({
    this.startDate,
    this.endDate,
    this.readOnly = false,
    this.format = 'yyyy-MM-dd',
    this.applyFormatOnInit = true,
  }) : this.name = _PlutoColumnTypeName.Datetime;

  /// Name of the column type.
  _PlutoColumnTypeName name;

  bool readOnly;

  String format;

  bool negative;

  bool applyFormatOnInit;

  DateTime startDate;

  DateTime endDate;

  /// In case of Select column, it is a list to select.
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
