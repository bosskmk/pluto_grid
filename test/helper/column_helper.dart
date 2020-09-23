import 'package:pluto_grid/pluto_grid.dart';

class ColumnHelper {
  static List<PlutoColumn> textColumn(
    String title, {
    int count = 1,
    double width = PlutoDefaultSettings.columnWidth,
    PlutoColumnFixed fixed = PlutoColumnFixed.None,
    bool readOnly = false,
  }) {
    return Iterable.generate(count)
        .map((e) => PlutoColumn(
              title: '$title$e',
              field: '$title$e',
              width: width,
              fixed: fixed,
              type: PlutoColumnType.text(readOnly: readOnly),
            ))
        .toList(growable: false);
  }

  static List<PlutoColumn> dateColumn(
    String title, {
    int count = 1,
    double width = PlutoDefaultSettings.columnWidth,
    PlutoColumnFixed fixed = PlutoColumnFixed.None,
    bool readOnly = false,
    dynamic startDate,
    dynamic endDate,
    String format = 'yyyy-MM-dd',
    bool applyFormatOnInit = true,
  }) {
    return Iterable.generate(count)
        .map((e) => PlutoColumn(
              title: '$title$e',
              field: '$title$e',
              width: width,
              fixed: fixed,
              type: PlutoColumnType.date(
                readOnly: readOnly,
                startDate: startDate,
                endDate: endDate,
                format: format,
                applyFormatOnInit: applyFormatOnInit,
              ),
            ))
        .toList(growable: false);
  }
}
