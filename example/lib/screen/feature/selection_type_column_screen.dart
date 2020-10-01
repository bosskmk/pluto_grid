import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class SelectionTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/selection-type-column';

  @override
  _SelectionTypeColumnScreenState createState() =>
      _SelectionTypeColumnScreenState();
}

class _SelectionTypeColumnScreenState extends State<SelectionTypeColumnScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Select A',
        field: 'select_a',
        type: PlutoColumnType.select([
          'One',
          'Two',
          'Three',
        ]),
      ),
      PlutoColumn(
        title: 'Select B',
        field: 'select_b',
        type: PlutoColumnType.select([
          'Apple',
          'Orange',
          'Banana',
        ]),
      ),
      PlutoColumn(
        title: 'Select C',
        field: 'select_c',
        type: PlutoColumnType.select([
          '1',
          '10',
          '100',
        ]),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'One'),
          'select_b': PlutoCell(value: 'Apple'),
          'select_c': PlutoCell(value: '1'),
        },
      ),
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'Two'),
          'select_b': PlutoCell(value: 'Orange'),
          'select_c': PlutoCell(value: '10'),
        },
      ),
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'Three'),
          'select_b': PlutoCell(value: 'Banana'),
          'select_c': PlutoCell(value: '100'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Selection type column',
      topTitle: 'Selection type column',
      topContents: [
        Text('A column to enter a selection value.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/selection_type_column_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
