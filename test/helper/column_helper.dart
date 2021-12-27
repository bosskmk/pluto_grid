import 'package:pluto_grid/pluto_grid.dart';

class ColumnHelper {
  static List<PlutoColumn> textColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
    dynamic defaultValue = '',
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return PlutoColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        type: PlutoColumnType.text(defaultValue: defaultValue),
      );
    }).toList();
  }

  static List<PlutoColumn> dateColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
    DateTime? startDate,
    DateTime? endDate,
    String format = 'yyyy-MM-dd',
    bool applyFormatOnInit = true,
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return PlutoColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        type: PlutoColumnType.date(
          startDate: startDate,
          endDate: endDate,
          format: format,
          applyFormatOnInit: applyFormatOnInit,
        ),
      );
    }).toList();
  }

  static List<PlutoColumn> timeColumn(
    String title, {
    int count = 1,
    int start = 0,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
    dynamic defaultValue = '00:00',
  }) {
    return Iterable<int>.generate(count).map((e) {
      e += start;
      return PlutoColumn(
        title: '$title$e',
        field: '$title$e',
        width: width,
        frozen: frozen,
        readOnly: readOnly,
        type: PlutoColumnType.time(
          defaultValue: defaultValue,
        ),
      );
    }).toList();
  }
}
