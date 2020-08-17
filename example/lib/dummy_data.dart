import 'package:faker/faker.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DummyData {
  List<PlutoColumn> dummyColumns;
  List<PlutoRow> dummyRows;

  DummyData(int columnLength, int rowLength) {
    var faker = new Faker();

    dummyColumns = List<int>.generate(columnLength, (index) => index).map((i) {
      return PlutoColumn(
        title: faker.food.cuisine(),
        field: i.toString(),
        type: (i) {
          if (i == 0)
            return PlutoColumnType.text(readOnly: true);
          else if (i == 1)
            return PlutoColumnType.text();
          else if (i == 2)
            return PlutoColumnType.select(['One', 'Two', 'Three'],
                readOnly: true);
          else if (i == 3)
            return PlutoColumnType.select(['One', 'Two', 'Three']);
          else
            return PlutoColumnType.text();
        }(i),
        fixed: (i) {
          if (i < 1) return PlutoColumnFixed.Left;
          if (i > columnLength - 2) return PlutoColumnFixed.Right;
          return null;
        }(i),
      );
    }).toList();

    dummyRows =
        List<int>.generate(rowLength, (index) => ++index).map((rowIndex) {
      final cells = Map<String, PlutoCell>();

      dummyColumns.forEach((element) {
        cells[element.field] = PlutoCell(
          value: element.field == '2' || element.field == '3'
              ? 'One'
              : faker.food.restaurant(),
        );
      });

      return PlutoRow(
        cells: cells,
      );
    }).toList(growable: false);
  }
}
