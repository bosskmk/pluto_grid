import 'package:faker/faker.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DummyData {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  DummyData(int columnLength, int rowLength) {
    var faker = Faker();

    columns = List<int>.generate(columnLength, (index) => index).map((i) {
      return PlutoColumn(
        title: faker.food.cuisine(),
        field: i.toString(),
        readOnly: [1, 3, 5].contains(i),
        type: (int i) {
          if (i == 0) {
            return PlutoColumnType.number();
          } else if (i == 1) {
            return PlutoColumnType.number();
          } else if (i == 2) {
            return PlutoColumnType.text();
          } else if (i == 3) {
            return PlutoColumnType.text();
          } else if (i == 4) {
            return PlutoColumnType.select(<String>['One', 'Two', 'Three']);
          } else if (i == 5) {
            return PlutoColumnType.select(<String>['One', 'Two', 'Three']);
          } else if (i == 6) {
            return PlutoColumnType.date();
          } else if (i == 7) {
            return PlutoColumnType.time();
          } else {
            return PlutoColumnType.text();
          }
        }(i),
        frozen: (int i) {
          if (i < 1) return PlutoColumnFrozen.left;
          if (i > columnLength - 2) return PlutoColumnFrozen.right;
          return PlutoColumnFrozen.none;
        }(i),
      );
    }).toList();

    rows = rowsByColumns(length: rowLength, columns: columns);
  }

  static List<PlutoRow> rowsByColumns(
      {required int length, List<PlutoColumn>? columns}) {
    return List<int>.generate(length, (index) => ++index).map((rowIndex) {
      return rowByColumns(columns!);
    }).toList();
  }

  static PlutoRow rowByColumns(List<PlutoColumn> columns) {
    final cells = <String, PlutoCell>{};

    for (var column in columns) {
      cells[column.field] = PlutoCell(
        value: (PlutoColumn element) {
          if (element.type.isNumber) {
            return faker.randomGenerator.decimal(scale: 1000000000);
          } else if (element.type.isSelect) {
            return (element.type.select!.items!.toList()..shuffle()).first;
          } else if (element.type.isDate) {
            return DateTime.now()
                .add(Duration(
                    days: faker.randomGenerator.integer(365, min: -365)))
                .toString();
          } else if (element.type.isTime) {
            return '00:00';
          } else {
            return faker.food.restaurant();
          }
        }(column),
      );
    }

    return PlutoRow(cells: cells);
  }
}
