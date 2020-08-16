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
        type: PlutoColumnType.text(),
        fixed: (i) {
          if (i < 2) return PlutoColumnFixed.Left;
          if (i > columnLength - 3) return PlutoColumnFixed.Right;
          return null;
        }(i),
      );
    }).toList();

    dummyRows =
        List<int>.generate(rowLength, (index) => ++index).map((rowIndex) {
      final cells = Map<String, PlutoCell>();

      dummyColumns.forEach((element) {
        cells[element.field] = PlutoCell(
          value: faker.food.restaurant(),
        );
      });

      return PlutoRow(
        cells: cells,
      );
    }).toList(growable: false);
  }
}
