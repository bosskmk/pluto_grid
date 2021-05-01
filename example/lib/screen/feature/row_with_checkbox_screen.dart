import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowWithCheckboxScreen extends StatefulWidget {
  static const routeName = 'feature/row-with-checkbox';

  @override
  _RowWithCheckboxScreenState createState() => _RowWithCheckboxScreenState();
}

class _RowWithCheckboxScreenState extends State<RowWithCheckboxScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        type: PlutoColumnType.text(),
      ),
    ];

    rows = DummyData.rowsByColumns(length: 15, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row with checkbox',
      topTitle: 'Row with checkbox',
      topContents: [
        const Text('You can select rows with checkbox.'),
        const Text(
            'If you set the enableRowChecked property of a column to true, a checkbox appears in the cell of that column.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/row_with_checkbox_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager!.setSelectingMode(PlutoGridSelectingMode.row);

          stateManager = event.stateManager;
        },
        // configuration: PlutoConfiguration.dark(),
      ),
    );
  }
}
