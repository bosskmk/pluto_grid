import 'package:intl/intl.dart' as intl;

abstract class PlutoColumnType {
  dynamic defaultValue;

  /// Set as a string column.
  factory PlutoColumnType.text({
    dynamic defaultValue = '',
  }) {
    return PlutoColumnTypeText(
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
  ///
  /// [allowFirstDot] When accepting negative numbers, a dot is allowed at the beginning.
  /// This option is required on devices where the .- symbol works with one button.
  ///
  /// [locale] Specifies the numeric locale of the column.
  /// If not specified, the default locale is used.
  factory PlutoColumnType.number({
    dynamic defaultValue = 0,
    bool negative = true,
    String format = '#,###',
    bool applyFormatOnInit = true,
    bool allowFirstDot = false,
    String? locale,
  }) {
    return PlutoColumnTypeNumber(
      defaultValue: defaultValue,
      format: format,
      negative: negative,
      applyFormatOnInit: applyFormatOnInit,
      allowFirstDot: allowFirstDot,
      locale: locale,
    );
  }

  /// Provides a selection list and sets it as a selection column.
  factory PlutoColumnType.select(
    List<dynamic> items, {
    dynamic defaultValue = '',
    bool enableColumnFilter = false,
  }) {
    return PlutoColumnTypeSelect(
      defaultValue: defaultValue,
      items: items,
      enableColumnFilter: enableColumnFilter,
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
  /// [headerFormat] 'yyyy-MM' (2020-01)
  /// Display year and month in header in date picker popup.
  ///
  /// [applyFormatOnInit] When the editor loads, it resets the value to [format].
  factory PlutoColumnType.date({
    dynamic defaultValue = '',
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd',
    String headerFormat = 'yyyy-MM',
    bool applyFormatOnInit = true,
  }) {
    return PlutoColumnTypeDate(
      defaultValue: defaultValue,
      startDate: startDate,
      endDate: endDate,
      format: format,
      headerFormat: headerFormat,
      applyFormatOnInit: applyFormatOnInit,
    );
  }

  factory PlutoColumnType.time({
    dynamic defaultValue = '00:00',
  }) {
    return PlutoColumnTypeTime(
      defaultValue: defaultValue,
    );
  }

  bool isValid(dynamic value);

  int compare(dynamic a, dynamic b);

  dynamic makeCompareValue(dynamic v);
}

extension PlutoColumnTypeExtension on PlutoColumnType? {
  bool get isText => this is PlutoColumnTypeText;

  bool get isNumber => this is PlutoColumnTypeNumber;

  bool get isSelect => this is PlutoColumnTypeSelect;

  bool get isDate => this is PlutoColumnTypeDate;

  bool get isTime => this is PlutoColumnTypeTime;

  PlutoColumnTypeText? get text {
    return this is PlutoColumnTypeText
        ? this as PlutoColumnTypeText?
        : throw TypeError();
  }

  PlutoColumnTypeNumber? get number {
    return this is PlutoColumnTypeNumber
        ? this as PlutoColumnTypeNumber?
        : throw TypeError();
  }

  PlutoColumnTypeSelect? get select {
    return this is PlutoColumnTypeSelect
        ? this as PlutoColumnTypeSelect?
        : throw TypeError();
  }

  PlutoColumnTypeDate? get date {
    return this is PlutoColumnTypeDate
        ? this as PlutoColumnTypeDate?
        : throw TypeError();
  }

  PlutoColumnTypeTime? get time {
    return this is PlutoColumnTypeTime
        ? this as PlutoColumnTypeTime?
        : throw TypeError();
  }

  bool get hasFormat => this is _PlutoColumnTypeHasFormat;

  bool? get applyFormatOnInit =>
      hasFormat ? (this as _PlutoColumnTypeHasFormat).applyFormatOnInit : false;

  dynamic applyFormat(dynamic value) => hasFormat
      ? (this as _PlutoColumnTypeHasFormat).applyFormat(value)
      : value;

  int compareWithNull(
    dynamic a,
    dynamic b,
    int Function() resolve,
  ) {
    if (a == null || b == null) {
      return a == b
          ? 0
          : a == null
              ? -1
              : 1;
    }

    return resolve();
  }
}

class PlutoColumnTypeText implements PlutoColumnType {
  @override
  dynamic defaultValue;

  PlutoColumnTypeText({
    this.defaultValue,
  });

  @override
  bool isValid(dynamic value) {
    return value is String || value is num;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return compareWithNull(a, b, () => a.toString().compareTo(b.toString()));
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v.toString();
  }
}

class PlutoColumnTypeNumber
    implements
        PlutoColumnType,
        _PlutoColumnTypeHasFormat,
        _PlutoColumnTypeHasNumberFormat {
  @override
  dynamic defaultValue;

  bool negative;

  @override
  String format;

  @override
  bool applyFormatOnInit;

  bool allowFirstDot;

  String? locale;

  PlutoColumnTypeNumber({
    this.defaultValue,
    required this.negative,
    required this.format,
    required this.applyFormatOnInit,
    required this.allowFirstDot,
    required this.locale,
  })  : numberFormat = intl.NumberFormat(format, locale),
        decimalPoint = getDecimalPoint(format);

  @override
  late final intl.NumberFormat numberFormat;

  final int decimalPoint;

  static int getDecimalPoint(String format) {
    final int dotIndex = format.indexOf('.');

    return dotIndex < 0 ? 0 : format.substring(dotIndex).length - 1;
  }

  @override
  bool isValid(dynamic value) {
    if (!_isNumeric(value)) {
      return false;
    }

    if (negative == false && num.parse(value.toString()) < 0) {
      return false;
    }

    return true;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return compareWithNull(
        a, b, () => num.parse(a.toString()).compareTo(num.parse(b.toString())));
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v.runtimeType != num ? num.tryParse(v.toString()) ?? 0 : v;
  }

  @override
  String applyFormat(dynamic value) {
    num number = num.tryParse(value
            .toString()
            .replaceAll(numberFormat.symbols.DECIMAL_SEP, '.')) ??
        0;

    if (negative == false && number < 0) {
      number = 0;
    }

    return numberFormat.format(number);
  }

  /// Convert [String] converted to [applyFormat] to [number].
  dynamic toNumber(String formatted) {
    return num.tryParse(formatted
            .toString()
            .replaceAll(numberFormat.symbols.GROUP_SEP, '')
            .replaceAll(numberFormat.symbols.DECIMAL_SEP, '.')) ??
        0;
  }

  bool _isNumeric(dynamic s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s.toString()) != null;
  }
}

class PlutoColumnTypeSelect implements PlutoColumnType {
  @override
  dynamic defaultValue;

  List<dynamic> items;

  bool enableColumnFilter;

  PlutoColumnTypeSelect({
    this.defaultValue,
    required this.items,
    required this.enableColumnFilter,
  });

  @override
  bool isValid(dynamic value) => items.contains(value) == true;

  @override
  int compare(dynamic a, dynamic b) {
    return compareWithNull(a, b, () {
      return items.indexOf(a).compareTo(items.indexOf(b));
    });
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v;
  }
}

class PlutoColumnTypeDate
    implements
        PlutoColumnType,
        _PlutoColumnTypeHasFormat,
        _PlutoColumnTypeHasDateFormat {
  @override
  dynamic defaultValue;

  DateTime? startDate;

  DateTime? endDate;

  @override
  String format;

  @override
  String headerFormat;

  @override
  bool applyFormatOnInit;

  PlutoColumnTypeDate({
    this.defaultValue,
    this.startDate,
    this.endDate,
    required this.format,
    required this.headerFormat,
    required this.applyFormatOnInit,
  })  : dateFormat = intl.DateFormat(format),
        headerDateFormat = intl.DateFormat(headerFormat);

  @override
  late final intl.DateFormat dateFormat;

  @override
  late final intl.DateFormat headerDateFormat;

  @override
  bool isValid(dynamic value) {
    final parsedDate = DateTime.tryParse(value.toString());

    if (parsedDate == null) {
      return false;
    }

    if (startDate != null && parsedDate.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && parsedDate.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  @override
  int compare(dynamic a, dynamic b) {
    return compareWithNull(a, b, () => a.toString().compareTo(b.toString()));
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    DateTime? dateFormatValue;

    try {
      dateFormatValue = dateFormat.parse(v.toString());
    } catch (e) {
      dateFormatValue = null;
    }

    return dateFormatValue;
  }

  @override
  String applyFormat(dynamic value) {
    final parseValue = DateTime.tryParse(value.toString());

    if (parseValue == null) {
      return '';
    }

    return dateFormat.format(DateTime.parse(value.toString()));
  }
}

class PlutoColumnTypeTime implements PlutoColumnType {
  @override
  dynamic defaultValue;

  PlutoColumnTypeTime({
    this.defaultValue,
  });

  @override
  bool isValid(dynamic value) {
    return RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d$').hasMatch(value.toString());
  }

  @override
  int compare(dynamic a, dynamic b) {
    return compareWithNull(a, b, () => a.toString().compareTo(b.toString()));
  }

  @override
  dynamic makeCompareValue(dynamic v) {
    return v;
  }
}

abstract class _PlutoColumnTypeHasFormat {
  late String format;

  late bool applyFormatOnInit;

  dynamic applyFormat(dynamic value);
}

abstract class _PlutoColumnTypeHasNumberFormat {
  late final intl.NumberFormat numberFormat;
}

abstract class _PlutoColumnTypeHasDateFormat {
  late final intl.DateFormat dateFormat;

  late String headerFormat;

  late final intl.DateFormat headerDateFormat;
}
