import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnHidingScreen extends StatefulWidget {
  static const routeName = 'feature/column-hiding';

  @override
  _ColumnHidingScreenState createState() => _ColumnHidingScreenState();
}

class _ColumnHidingScreenState extends State<ColumnHidingScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

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

  void handleToggleColumnA() {
    var firstColumn = stateManager!.refColumns!.originalList.first;

    stateManager!.hideColumn(firstColumn.key, !firstColumn.hide);
  }

  void handleShowPopup(BuildContext context) {
    stateManager!.showSetColumnsPopup(context);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column hiding',
      topTitle: 'Column hiding',
      topContents: [
        const Text('You can hide or un-hide the column.'),
        const Text(
            'Hide or un-hide columns with the Hide column and Set Columns items in the menu on the right of the column title.'),
        const Text(
            'You can directly change the hidden state of a column with hideColumn of stateManager or call a popup with showSetColumnsPopup.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/column_hiding_screen.dart',
        ),
      ],
      body: Container(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    child: const Text('Toggle hide Column A'),
                    onPressed: handleToggleColumnA,
                  ),
                  ElevatedButton(
                    child: const Text('Show Popup'),
                    onPressed: () {
                      handleShowPopup(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
