import 'package:faker/faker.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DummyData {
  List<PlutoColumn> columns;
  List<PlutoRow> rows;

  DummyData(int columnLength, int rowLength) {
    var faker = new Faker();

    columns = List<int>.generate(columnLength, (index) => index).map((i) {
      return PlutoColumn(
        title: faker.food.cuisine(),
        field: i.toString(),
        type: (i) {
          if (i == 0)
            return PlutoColumnType.number();
          else if (i == 1)
            return PlutoColumnType.number(readOnly: true);
          else if (i == 2)
            return PlutoColumnType.text();
          else if (i == 3)
            return PlutoColumnType.text(readOnly: true);
          else if (i == 4)
            return PlutoColumnType.select(['One', 'Two', 'Three']);
          else if (i == 5)
            return PlutoColumnType.select(['One', 'Two', 'Three'],
                readOnly: true);
          else if (i == 6)
            return PlutoColumnType.date();
          else if (i == 7)
            return PlutoColumnType.time();
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

    int days = 0;

    rows =
        List<int>.generate(rowLength, (index) => ++index).map((rowIndex) {
      final cells = Map<String, PlutoCell>();

      columns.forEach((element) {
        cells[element.field] = PlutoCell(
          value: (element) {
            if (element.field == '0' || element.field == '1')
              return faker.randomGenerator.decimal(scale: 1000000000);
            else if (element.field == '4' || element.field == '5')
              return 'One';
            else if (element.field == '6')
              return DateTime.now().add(Duration(days: ++days)).toString();
            else if (element.field == '7')
              return '00:00';
            else
              return faker.food.restaurant();
          }(element),
        );
      });

      return PlutoRow(
        cells: cells,
      );
    }).toList(growable: false);
  }
}
