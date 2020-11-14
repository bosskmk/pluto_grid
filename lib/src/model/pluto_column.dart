part of '../../pluto_grid.dart';

typedef PlutoColumnValueFormatter = String Function(String value);

typedef PlutoColumnRenderer = Widget Function(
    PlutoColumnRendererContext rendererContext);

class PlutoColumnRendererContext {
  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoCell cell;

  final PlutoStateManager stateManager;

  PlutoColumnRendererContext({
    this.column,
    this.rowIdx,
    this.row,
    this.cell,
    this.stateManager,
  });
}

class PlutoColumn {
  /// A title to be displayed on the screen.
  String title;

  /// Specifies the field name of the row to be connected to the column.
  String field;

  /// Set the column type.
  PlutoColumnType type;

  /// Set the width of the column.
  double width;

  double minWidth;

  /// Text alignment in Cell. (Left, Right)
  PlutoColumnTextAlign textAlign;

  /// Fix the column to the left and right.
  PlutoColumnFixed fixed;

  /// Set column sorting.
  PlutoColumnSort sort;

  /// Formatter for display of cell values.
  PlutoColumnValueFormatter formatter;

  /// Apply the formatter in the editing state.
  /// However, it is applied only when the cell is readonly
  /// or the text cannot be directly modified, such as in the form of select popup.
  bool applyFormatterInEditing;

  /// Rendering for cell widget.
  PlutoColumnRenderer renderer;

  /// Change the position of the column by dragging the column title.
  bool enableColumnDrag;

  /// Change the position of the row by dragging the icon in the cell.
  bool enableRowDrag;

  /// A checkbox appears in the cell of the column.
  bool enableRowChecked;

  /// Sort rows by tapping on the column heading.
  bool enableSorting;

  /// Displays the right icon of the column title.
  bool enableContextMenu;

  PlutoColumn({
    @required this.title,
    @required this.field,
    @required this.type,
    this.width = PlutoDefaultSettings.columnWidth,
    this.minWidth = PlutoDefaultSettings.minColumnWidth,
    this.textAlign = PlutoColumnTextAlign.left,
    this.fixed = PlutoColumnFixed.none,
    this.sort = PlutoColumnSort.none,
    this.formatter,
    this.applyFormatterInEditing = false,
    this.renderer,
    this.enableColumnDrag = true,
    this.enableRowDrag = false,
    this.enableRowChecked = false,
    this.enableSorting = true,
    this.enableContextMenu = true,
  }) : _key = UniqueKey();

  /// Column key
  final Key _key;

  Key get key => _key;

  bool get hasRenderer => renderer != null;

  String formattedValueForType(dynamic value) {
    if (type.isNumber) {
      return type.number.applyFormat(value);
    }

    return value.toString();
  }

  String formattedValueForDisplay(dynamic value) {
    if (formatter != null) {
      return formatter(value.toString()).toString();
    }

    return formattedValueForType(value);
  }

  String formattedValueForDisplayInEditing(dynamic value) {
    if (formatter != null) {
      final bool allowFormatting =
          type.readOnly || type.isSelect || type.isTime || type.isDate;

      if (applyFormatterInEditing && allowFormatting) {
        return formatter(value.toString()).toString();
      }
    }

    return value.toString();
  }
}

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
    readOnly = false,
    dynamic defaultValue = '',
    startDate,
    endDate,
    format = 'yyyy-MM-dd',
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
    return a.compareTo(b);
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
    final dateFormat = intl.DateFormat(format);

    final _a = dateFormat.parse(a);

    final _b = dateFormat.parse(b);

    return _a.compareTo(_b);
  }

  String applyFormat(value) {
    final parseValue = DateTime.tryParse(value);

    if (parseValue == null) {
      return null;
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

enum PlutoColumnTextAlign {
  left,
  right,
}

extension PlutoColumnTextAlignExtension on PlutoColumnTextAlign {
  TextAlign get value {
    return this == PlutoColumnTextAlign.right
        ? TextAlign.right
        : TextAlign.left;
  }

  bool get isLeft => this == null || this == PlutoColumnTextAlign.left;

  bool get isRight => this == PlutoColumnTextAlign.right;
}

enum PlutoColumnFixed {
  none,
  left,
  right,
}

extension PlutoColumnFixedExtension on PlutoColumnFixed {
  bool get isNone {
    return this == null || this == PlutoColumnFixed.none;
  }

  bool get isLeft {
    return this == PlutoColumnFixed.left;
  }

  bool get isRight {
    return this == PlutoColumnFixed.right;
  }

  bool get isFixed {
    return this == PlutoColumnFixed.left || this == PlutoColumnFixed.right;
  }
}

enum PlutoColumnSort {
  none,
  ascending,
  descending,
}

extension PlutoColumnSortExtension on PlutoColumnSort {
  bool get isNone {
    return this == null || this == PlutoColumnSort.none;
  }

  bool get isAscending {
    return this == PlutoColumnSort.ascending;
  }

  bool get isDescending {
    return this == PlutoColumnSort.descending;
  }

  String toShortString() {
    return toString().split('.').last;
  }

  PlutoColumnSort fromString(String value) {
    if (value == PlutoColumnSort.ascending.toShortString()) {
      return PlutoColumnSort.ascending;
    } else if (value == PlutoColumnSort.descending.toShortString()) {
      return PlutoColumnSort.descending;
    } else {
      return PlutoColumnSort.none;
    }
  }
}
