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
}
