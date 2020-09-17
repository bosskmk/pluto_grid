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

extension _PlutoColumnFixedExtension on PlutoColumnFixed {
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

extension _PlutoColumnSortExtension on PlutoColumnSort {
  bool get isNone {
    return this == null || this == PlutoColumnSort.None;
  }

  bool get isAscending {
    return this == PlutoColumnSort.Ascending;
  }

  // bool get isDescending {
  //   return this == PlutoColumnSort.Descending;
  // }

  // String toShortString() {
  //   return this.toString().split('.').last;
  // }

  // PlutoColumnSort fromString(String value) {
  //   if (value == PlutoColumnSort.Ascending.toShortString()) {
  //     return PlutoColumnSort.Ascending;
  //   } else if (value == PlutoColumnSort.Descending.toShortString()) {
  //     return PlutoColumnSort.Descending;
  //   } else {
  //     return PlutoColumnSort.None;
  //   }
  // }
}

abstract class PlutoColumnType {
  bool readOnly;

  /// Set as a string column.
  factory PlutoColumnType.text({
    bool readOnly = false,
  }) {
    return _PlutoColumnTypeText(readOnly: readOnly);
  }

  /// Set to numeric column.
  ///
  /// [format]
  /// '#,###' (Comma every three digits)
  /// '#,###.###' (Allow three decimal places)
  ///
  /// [negative] Allow negative numbers
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  factory PlutoColumnType.number({
    readOnly = false,
    negative = true,
    format = '#,###',
    applyFormatOnInit = true,
  }) {
    return _PlutoColumnTypeNumber(
      readOnly: readOnly,
      format: format,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
    );
  }

  /// Provides a selection list and sets it as a selection column.
  factory PlutoColumnType.select(
    List<dynamic> items, {
    readOnly = false,
  }) {
    return _PlutoColumnTypeSelect(
      readOnly: readOnly,
      items: items,
    );
  }

  /// Set as a date column.
  ///
  /// [startDate] Range start date (If there is no value, Can select the date without limit)
  ///
  /// [endDate] Range end date
  ///
  /// [format] 'yyyy-MM-dd' (2020-01-01)
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  factory PlutoColumnType.date({
    readOnly = false,
    startDate,
    endDate,
    format = 'yyyy-MM-dd',
    applyFormatOnInit = true,
  }) {
    return _PlutoColumnTypeDate(
      readOnly: readOnly,
      startDate: startDate,
      endDate: endDate,
      format: format,
      applyFormatOnInit: applyFormatOnInit,
    );
  }

  factory PlutoColumnType.time({
    readOnly = false,
  }) {
    return _PlutoColumnTypeTime(readOnly: readOnly);
  }

  bool isValid(dynamic value);
}

extension _PlutoColumnTypeExtension on PlutoColumnType {
  bool get isText => this is _PlutoColumnTypeText;

  bool get isNumber => this is _PlutoColumnTypeNumber;

  bool get isSelect => this is _PlutoColumnTypeSelect;

  bool get isDate => this is _PlutoColumnTypeDate;

  bool get isTime => this is _PlutoColumnTypeTime;

  _PlutoColumnTypeText get text {
    return this is _PlutoColumnTypeText ? this : throw TypeError();
  }

  _PlutoColumnTypeNumber get number {
    return this is _PlutoColumnTypeNumber ? this : throw TypeError();
  }

  _PlutoColumnTypeSelect get select {
    return this is _PlutoColumnTypeSelect ? this : throw TypeError();
  }

  _PlutoColumnTypeDate get date {
    return this is _PlutoColumnTypeDate ? this : throw TypeError();
  }

  _PlutoColumnTypeTime get time {
    return this is _PlutoColumnTypeTime ? this : throw TypeError();
  }

  bool get hasFormat => this is _PlutoColumnTypeHasFormat;

  bool get applyFormatOnInit =>
      hasFormat ? (this as _PlutoColumnTypeHasFormat).applyFormatOnInit : false;

  dynamic applyFormat(dynamic value) => hasFormat
      ? (this as _PlutoColumnTypeHasFormat).applyFormat(value)
      : value;
}

class _PlutoColumnTypeText implements PlutoColumnType {
  bool readOnly;

  _PlutoColumnTypeText({this.readOnly});

  bool isValid(dynamic value) {
    return value is String || value is num;
  }
}

class _PlutoColumnTypeNumber
    implements PlutoColumnType, _PlutoColumnTypeHasFormat {
  bool readOnly;

  bool negative;

  String format;

  bool applyFormatOnInit;

  _PlutoColumnTypeNumber({
    this.readOnly,
    this.negative,
    this.format,
    this.applyFormatOnInit,
  });

  bool isValid(dynamic value) {
    if (value is! num) {
      return false;
    }

    if (negative == false && value < 0) {
      return false;
    }

    return true;
  }

  String applyFormat(value) {
    final f = intl.NumberFormat(format);

    double num =
        double.tryParse(value.toString().replaceAll(f.symbols.GROUP_SEP, '')) ??
            0;

    if (negative == false && num < 0) {
      num = 0;
    }

    return f.format(num);
  }

  int decimalRange() {
    final int dotIndex = format.indexOf('.');

    return dotIndex < 0 ? 0 : format.substring(dotIndex).length - 1;
  }
}

class _PlutoColumnTypeSelect implements PlutoColumnType {
  bool readOnly;

  List<dynamic> items;

  _PlutoColumnTypeSelect({
    this.readOnly,
    this.items,
  });

  bool isValid(dynamic value) => items.contains(value) == true;
}

class _PlutoColumnTypeDate
    implements PlutoColumnType, _PlutoColumnTypeHasFormat {
  bool readOnly;

  DateTime startDate;

  DateTime endDate;

  String format;

  bool applyFormatOnInit;

  _PlutoColumnTypeDate({
    this.readOnly,
    this.startDate,
    this.endDate,
    this.format,
    this.applyFormatOnInit,
  });

  bool isValid(dynamic value) {
    final parsedDate = DateTime.tryParse(value);

    if (parsedDate == null) {
      return false;
    }

    if (startDate != null && parsedDate.isBefore(parsedDate)) {
      return false;
    }

    if (endDate != null && parsedDate.isAfter(parsedDate)) {
      return false;
    }

    return true;
  }

  String applyFormat(value) {
    final parseValue = DateTime.tryParse(value);

    if (parseValue == null) {
      return null;
    }

    return intl.DateFormat(format).format(DateTime.parse(value));
  }
}

class _PlutoColumnTypeTime implements PlutoColumnType {
  bool readOnly;

  _PlutoColumnTypeTime({
    this.readOnly,
  });

  bool isValid(dynamic value) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);
  }
}

abstract class _PlutoColumnTypeHasFormat {
  String format;

  bool applyFormatOnInit;

  dynamic applyFormat(dynamic value);
}
