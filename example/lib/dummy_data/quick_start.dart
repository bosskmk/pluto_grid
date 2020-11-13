import 'package:pluto_grid/pluto_grid.dart';

class DummyData {
  List<PlutoColumn> columns;
  List<PlutoRow> rows;

  DummyData() {
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
        title: 'date column',
        field: 'date_field',
        type: PlutoColumnType.date(),
      ),

      /// Time Column definition
      PlutoColumn(
        title: 'time column',
        field: 'time_field',
        type: PlutoColumnType.time(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value1'),
          'number_field': PlutoCell(value: 2020),
          'select_field': PlutoCell(value: 'item1'),
          'date_field': PlutoCell(value: '2020-08-06'),
          'time_field': PlutoCell(value: '12:30'),
        },
      ),
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value2'),
          'number_field': PlutoCell(value: 2021),
          'select_field': PlutoCell(value: 'item2'),
          'date_field': PlutoCell(value: '2020-08-07'),
          'time_field': PlutoCell(value: '18:45'),
        },
      ),
      PlutoRow(
        cells: {
          'text_field': PlutoCell(value: 'Text cell value3'),
          'number_field': PlutoCell(value: 2022),
          'select_field': PlutoCell(value: 'item3'),
          'date_field': PlutoCell(value: '2020-08-08'),
          'time_field': PlutoCell(value: '23:59'),
        },
      ),
    ];
  }
}
