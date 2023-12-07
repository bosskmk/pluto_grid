import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class DateTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/date-type-column';

  const DateTypeColumnScreen({super.key});

  @override
  _DateTypeColumnScreenState createState() => _DateTypeColumnScreenState();
}

class _DateTypeColumnScreenState extends State<DateTypeColumnScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'yyyy-MM-dd',
        field: 'yyyy_mm_dd',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'MM/dd/yyyy',
        field: 'mm_dd_yyyy',
        type: PlutoColumnType.date(
          format: 'MM/dd/yyyy',
        ),
      ),
      PlutoColumn(
        title: 'with StartDate',
        field: 'with_start_date',
        type: PlutoColumnType.date(
          startDate: DateTime.parse('2020-01-01'),
        ),
      ),
      PlutoColumn(
        title: 'with EndDate',
        field: 'with_end_date',
        type: PlutoColumnType.date(
          endDate: DateTime.parse('2020-01-01'),
        ),
      ),
      PlutoColumn(
        title: 'with Both',
        field: 'with_both',
        type: PlutoColumnType.date(
          startDate: DateTime.parse('2020-01-01'),
          endDate: DateTime.parse('2020-01-31'),
        ),
      ),
      PlutoColumn(
        title: 'custom',
        field: 'custom',
        type: PlutoColumnType.date(format: 'yyyy年 MM月 dd日'),
      ),
    ]);

    rows.addAll([
      PlutoRow(
        cells: {
          'yyyy_mm_dd': PlutoCell(value: '2020-06-30'),
          'mm_dd_yyyy': PlutoCell(value: '2020-06-30'),
          'with_start_date': PlutoCell(value: '2020-01-01'),
          'with_end_date': PlutoCell(value: '2020-01-01'),
          'with_both': PlutoCell(value: '2020-01-01'),
          'custom': PlutoCell(value: '2020-01-01'),
        },
      ),
      PlutoRow(
        cells: {
          'yyyy_mm_dd': PlutoCell(value: '2020-07-01'),
          'mm_dd_yyyy': PlutoCell(value: '2019-07-01'),
          'with_start_date': PlutoCell(value: '2020-01-01'),
          'with_end_date': PlutoCell(value: '2020-01-01'),
          'with_both': PlutoCell(value: '2020-01-01'),
          'custom': PlutoCell(value: '2020-01-01'),
        },
      ),
      PlutoRow(
        cells: {
          'yyyy_mm_dd': PlutoCell(value: '2020-07-02'),
          'mm_dd_yyyy': PlutoCell(value: '2020-07-02'),
          'with_start_date': PlutoCell(value: '2020-01-01'),
          'with_end_date': PlutoCell(value: '2020-01-01'),
          'with_both': PlutoCell(value: '2020-01-01'),
          'custom': PlutoCell(value: '2020-01-01'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Date type column',
      topTitle: 'Date type column',
      topContents: const [
        Text('A column to enter a date value.'),
        Text('The arrow keys at the left and right end change the year.'),
        Text('The arrow keys at the upper and lower ends change the month.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/date_type_column_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
