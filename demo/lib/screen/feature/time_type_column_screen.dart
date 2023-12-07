import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class TimeTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/time-type-column';

  const TimeTypeColumnScreen({super.key});

  @override
  _TimeTypeColumnScreenState createState() => _TimeTypeColumnScreenState();
}

class _TimeTypeColumnScreenState extends State<TimeTypeColumnScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'Time',
        field: 'time',
        type: PlutoColumnType.time(),
      ),
    ]);

    rows.addAll([
      PlutoRow(
        cells: {
          'time': PlutoCell(value: '00:00'),
        },
      ),
      PlutoRow(
        cells: {
          'time': PlutoCell(value: '23:59'),
        },
      ),
      PlutoRow(
        cells: {
          'time': PlutoCell(value: '12:30'),
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Time type column',
      topTitle: 'Time type column',
      topContents: const [
        Text('A column to enter a time value.'),
        Text('Move the hour and minute with the left and right arrow keys.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/time_type_column_screen.dart',
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
