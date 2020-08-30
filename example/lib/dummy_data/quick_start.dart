import 'package:pluto_grid/pluto_grid.dart';

class DummyData {
  List<PlutoColumn> columns;
  List<PlutoRow> rows;

  DummyData(int columnLength, int rowLength) {
    columns = [
      /// Text Column definition
      PlutoColumn(
        title: 'text column',
        field: 'text_field',
        type: PlutoColumnType.text(),
      ),

      /// Number Column definition
      PlutoColumn(
        title: 'number column',
        field: 'number_field',
        type: PlutoColumnType.number(),
      ),

      /// Select Column definition
      PlutoColumn(
        title: 'select column',
        field: 'select_field',
        type: PlutoColumnType.select(['item1', 'item2', 'item3']),
      ),

      /// Datetime Column definition
      PlutoColumn(
        title: 'datetime column',
        field: 'datetime_field',
        type: PlutoColumnType.datetime(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value1'),
          'number_field': PlutoCell(value: 2020),
          'select_field': PlutoCell(value: 'item1'),
          'datetime_field': PlutoCell(value: '2020-08-06'),
        },
      ),
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value2'),
          'number_field': PlutoCell(value: 2021),
          'select_field': PlutoCell(value: 'item2'),
          'datetime_field': PlutoCell(value: '2020-08-07'),
        },
      ),
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value3'),
          'number_field': PlutoCell(value: 2022),
          'select_field': PlutoCell(value: 'item3'),
          'datetime_field': PlutoCell(value: '2020-08-08'),
        },
      ),
    ];
  }
}
