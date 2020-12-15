import 'package:intl/intl.dart' as intl;

abstract class PlutoColumnType {
  bool readOnly;

  dynamic defaultValue;

  /// Set as a string column.
  factory PlutoColumnType.text({
    bool readOnly = false,
    dynamic defaultValue = '',
  }) {
    return PlutoColumnTypeText(
      readOnly: readOnly,
      defaultValue: defaultValue,
    );
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
    dynamic defaultValue = 0,
    negative = true,
    format = '#,###',
    applyFormatOnInit = true,
  }) {
    return PlutoColumnTypeNumber(
      readOnly: readOnly,
      defaultValue: defaultValue,
      format: format,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
    );
  }

  /// Provides a selection list and sets it as a selection column.
  factory PlutoColumnType.select(
    List<dynamic> items, {
    readOnly = false,
    dynamic defaultValue = '',
  }) {
    return PlutoColumnTypeSelect(
      readOnly: readOnly,
      defaultValue: defaultValue,
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
    bool readOnly = false,
    dynamic defaultValue = '',
    DateTime startDate,
    DateTime endDate,
    String format = 'yyyy-MM-dd',
    applyFormatOnInit = true,
  }) {
    return PlutoColumnTypeDate(
      readOnly: readOnly,
      defaultValue: defaultValue,
      startDate: startDate,
      endDate: endDate,
      format: format,
      applyFormatOnInit: applyFormatOnInit,
    );
  }

  factory PlutoColumnType.time({
    readOnly = false,
    dynamic defaultValue = '00:00',
  }) {
    return PlutoColumnTypeTime(
      readOnly: readOnly,
      defaultValue: defaultValue,
    );
  }

  bool isValid(dynamic value);

  int compare(dynamic a, dynamic b);
}

extension PlutoColumnTypeExtension on PlutoColumnType {
  bool get isText => this is PlutoColumnTypeText;

  bool get isNumber => this is PlutoColumnTypeNumber;

  bool get isSelect => this is PlutoColumnTypeSelect;

  bool get isDate => this is PlutoColumnTypeDate;

  bool get isTime => this is PlutoColumnTypeTime;

  PlutoColumnTypeText get text {
    return this is PlutoColumnTypeText ? this : throw TypeError();
  }

  PlutoColumnTypeNumber get number {
    return this is PlutoColumnTypeNumber ? this : throw TypeError();
  }

  PlutoColumnTypeSelect get select {
    return this is PlutoColumnTypeSelect ? this : throw TypeError();
  }

  PlutoColumnTypeDate get date {
    return this is PlutoColumnTypeDate ? this : throw TypeError();
  }

  PlutoColumnTypeTime get time {
    return this is PlutoColumnTypeTime ? this : throw TypeError();
  }

  bool get hasFormat => this is _PlutoColumnTypeHasFormat;

  bool get applyFormatOnInit =>
      hasFormat ? (this as _PlutoColumnTypeHasFormat).applyFormatOnInit : false;

  dynamic applyFormat(dynamic value) => hasFormat
      ? (this as _PlutoColumnTypeHasFormat).applyFormat(value)
      : value;
}

class PlutoColumnTypeText implements PlutoColumnType {
  bool readOnly;

  dynamic defaultValue;

  PlutoColumnTypeText({
    this.readOnly,
    this.defaultValue,
  });

  bool isValid(dynamic value) {
    return value is String || value is num;
  }

  int compare(dynamic a, dynamic b) {
    return a.toString().compareTo(b.toString());
  }
}

class PlutoColumnTypeNumber
    implements PlutoColumnType, _PlutoColumnTypeHasFormat {
  bool readOnly;

  dynamic defaultValue;

  bool negative;

  String format;

  bool applyFormatOnInit;

  PlutoColumnTypeNumber({
    this.readOnly,
    this.defaultValue,
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

  int compare(dynamic a, dynamic b) {
    return a.compareTo(b);
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

class PlutoColumnTypeSelect implements PlutoColumnType {
  bool readOnly;

  dynamic defaultValue;

  List<dynamic> items;

  PlutoColumnTypeSelect({
    this.readOnly,
    this.defaultValue,
    this.items,
  });

  bool isValid(dynamic value) => items.contains(value) == true;

  int compare(dynamic a, dynamic b) {
    final _a = items.indexOf(a);

    final _b = items.indexOf(b);

    return _a.compareTo(_b);
  }
}

class PlutoColumnTypeDate
    implements PlutoColumnType, _PlutoColumnTypeHasFormat {
  bool readOnly;

  dynamic defaultValue;

  DateTime startDate;

  DateTime endDate;

  String format;

  bool applyFormatOnInit;

  PlutoColumnTypeDate({
    this.readOnly,
    this.defaultValue,
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

    if (startDate != null && parsedDate.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && parsedDate.isAfter(endDate)) {
      return false;
    }

    return true;
  }

  int compare(dynamic a, dynamic b) {
    var emptyA = a == null || a == '';
    var emptyB = b == null || b == '';

    if (emptyA || emptyB) {
      return emptyA == emptyB
          ? 0
          : emptyA
              ? -1
              : 1;
    }

    final dateFormat = intl.DateFormat(format);

    final _a = dateFormat.parse(a);

    final _b = dateFormat.parse(b);

    return _a.compareTo(_b);
  }

  String applyFormat(value) {
    final parseValue = DateTime.tryParse(value);

    if (parseValue == null) {
      return '';
    }

    return intl.DateFormat(format).format(DateTime.parse(value));
  }
}

class PlutoColumnTypeTime implements PlutoColumnType {
  bool readOnly;

  dynamic defaultValue;

  PlutoColumnTypeTime({
    this.readOnly,
    this.defaultValue,
  });

  bool isValid(dynamic value) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value);
  }

  int compare(dynamic a, dynamic b) {
    return a.compareTo(b);
  }
}

abstract class _PlutoColumnTypeHasFormat {
  String format;

  bool applyFormatOnInit;

  dynamic applyFormat(dynamic value);
}
