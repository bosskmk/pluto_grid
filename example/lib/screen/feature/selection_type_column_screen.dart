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
          'Mercury',
          'Venus',
          'Earth',
          'Mars',
          'Jupiter',
          'Saturn',
          'Uranus',
          'Neptune',
          'Pluto',
        ]),
      ),
      PlutoColumn(
        title: 'Select C',
        field: 'select_c',
        type: PlutoColumnType.select([
          '9.01',
          '30.02',
          '100.001',
        ]),
      ),
      PlutoColumn(
        title: 'Select D',
        field: 'select_d',
        type: PlutoColumnType.select([
          '一',
          '二',
          '三',
          '四',
          '五',
          '六',
          '七',
          '八',
          '九',
        ]),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'One'),
          'select_b': PlutoCell(value: 'Saturn'),
          'select_c': PlutoCell(value: '100.001'),
          'select_d': PlutoCell(value: '五'),
        },
      ),
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'Two'),
          'select_b': PlutoCell(value: 'Pluto'),
          'select_c': PlutoCell(value: '9.01'),
          'select_d': PlutoCell(value: '八'),
        },
      ),
      PlutoRow(
        cells: {
          'select_a': PlutoCell(value: 'Three'),
          'select_b': PlutoCell(value: 'Mars'),
          'select_c': PlutoCell(value: '30.02'),
          'select_d': PlutoCell(value: '三'),
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
        Text(
            'The sorting of the Selection column is based on the order of the Select items.'),
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
        configuration: PlutoConfiguration(
          // If you don't want to move to the next line after selecting the pop-up item, uncomment it.
          // enableMoveDownAfterSelecting: false,
        ),
      ),
    );
  }
}
