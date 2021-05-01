import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnSortingScreen extends StatefulWidget {
  static const routeName = 'feature/column-sorting';

  @override
  _ColumnSortingScreenState createState() => _ColumnSortingScreenState();
}

class _ColumnSortingScreenState extends State<ColumnSortingScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Column A',
        field: 'column_a',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column B',
        field: 'column_b',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column C',
        field: 'column_c',
        type: PlutoColumnType.text(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a1'),
          'column_b': PlutoCell(value: 'b1'),
          'column_c': PlutoCell(value: 'c1'),
        },
      ),
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a2'),
          'column_b': PlutoCell(value: 'b2'),
          'column_c': PlutoCell(value: 'c2'),
        },
      ),
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a3'),
          'column_b': PlutoCell(value: 'b3'),
          'column_c': PlutoCell(value: 'c3'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column sorting',
      topTitle: 'Column sorting',
      topContents: [
        const Text(
            'Ascending or Descending by clicking on the column heading.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/column_sorting_screen.dart',
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
