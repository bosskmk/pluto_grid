import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowMovingScreen extends StatefulWidget {
  static const routeName = 'feature/row-moving';

  const RowMovingScreen({Key? key}) : super(key: key);

  @override
  _RowMovingScreenState createState() => _RowMovingScreenState();
}

class _RowMovingScreenState extends State<RowMovingScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowDrag: true,
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
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 15, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row moving',
      topTitle: 'Row moving',
      topContents: const [
        Text('You can move the row by dragging it.'),
        Text(
            'If enableRowDrag of the column property is set to true, an icon that can be dragged to the left of the cell value is created.'),
        Text('You can drag the icon to move the row up and down.'),
        Text('In Selecting Row mode, you can move all the selected rows.'),
        Text(
            'You can receive the moved rows passed to the onRowsMoved callback.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_moving_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.row);

          stateManager = event.stateManager;
        },
        onRowsMoved: (PlutoGridOnRowsMovedEvent event) {
          // Moved index.
          // In the state of pagination, filtering, and sorting,
          // this is the index of the currently displayed row range.
          print(event.idx);

          // Shift (Control) + Click or Shift + Move keys
          // allows you to select multiple rows and move them at the same time.
          print(event.rows.first.cells['column1']!.value);
        },
      ),
    );
  }
}
