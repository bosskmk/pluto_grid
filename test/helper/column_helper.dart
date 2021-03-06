import 'package:pluto_grid/pluto_grid.dart';

class ColumnHelper {
  static List<PlutoColumn> textColumn(
    String title, {
    int count = 1,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
  }) {
    return Iterable<int>.generate(count)
        .map((e) => PlutoColumn(
              title: '$title$e',
              field: '$title$e',
              width: width,
              frozen: frozen,
              type: PlutoColumnType.text(readOnly: readOnly),
            ))
        .toList();
  }

  static List<PlutoColumn> dateColumn(
    String title, {
    int count = 1,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
    DateTime startDate,
    DateTime endDate,
    String format = 'yyyy-MM-dd',
    bool applyFormatOnInit = true,
  }) {
    return Iterable<int>.generate(count)
        .map((e) => PlutoColumn(
              title: '$title$e',
              field: '$title$e',
              width: width,
              frozen: frozen,
              type: PlutoColumnType.date(
                readOnly: readOnly,
                startDate: startDate,
                endDate: endDate,
                format: format,
                applyFormatOnInit: applyFormatOnInit,
              ),
            ))
        .toList();
  }

  static List<PlutoColumn> timeColumn(
    String title, {
    int count = 1,
    double width = PlutoGridSettings.columnWidth,
    PlutoColumnFrozen frozen = PlutoColumnFrozen.none,
    bool readOnly = false,
    dynamic defaultValue = '00:00',
  }) {
    return Iterable<int>.generate(count)
        .map((e) => PlutoColumn(
              title: '$title$e',
              field: '$title$e',
              width: width,
              frozen: frozen,
              type: PlutoColumnType.time(
                readOnly: readOnly,
                defaultValue: defaultValue,
              ),
            ))
        .toList();
  }
}
