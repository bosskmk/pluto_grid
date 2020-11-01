import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class DualModeScreen extends StatefulWidget {
  static const routeName = 'feature/dual-mode';

  @override
  _DualModeScreenState createState() => _DualModeScreenState();
}

class _DualModeScreenState extends State<DualModeScreen> {
  List<PlutoColumn> gridAColumns;

  List<PlutoRow> gridARows;

  List<PlutoColumn> gridBColumns;

  List<PlutoRow> gridBRows;

  PlutoStateManager gridAStateManager;

  PlutoStateManager gridBStateManager;

  String currentUsername;

  @override
  void initState() {
    super.initState();

    gridAColumns = [
      PlutoColumn(
        title: 'Username',
        field: 'username',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Point',
        field: 'point',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'grade',
        field: 'grade',
        type: PlutoColumnType.select(['A', 'B', 'C']),
      ),
    ];

    gridARows = DummyData.rowsByColumns(
      length: 30,
      columns: gridAColumns,
    );

    gridBColumns = [
      PlutoColumn(
        title: 'Activity',
        field: 'activity',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Date',
        field: 'date',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Time',
        field: 'time',
        type: PlutoColumnType.time(),
      ),
    ];

    gridBRows = [];
  }

  void gridAHandler() {
    if (gridAStateManager.currentRow == null) {
      return;
    }

    if (gridAStateManager.currentRow.cells['username'].value !=
        currentUsername) {
      currentUsername = gridAStateManager.currentRow.cells['username'].value;
      fetchUserActivity(currentUsername);
    }
  }

  void fetchUserActivity(String username) {
    setState(() {
      final rows = DummyData.rowsByColumns(
        length: faker.randomGenerator.integer(10, min: 1),
        columns: gridBColumns,
      );

      gridBStateManager.removeRows(gridBStateManager.rows);
      gridBStateManager.resetCurrentState();
      gridBStateManager.appendRows(rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Dual mode',
      topTitle: 'Dual mode',
      topContents: [
        Text(
            'Place the grid on the left and right and move or edit with the keyboard.'),
        Text('Refer to the display property for the width of the grid.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/dual_mode_screen.dart',
        ),
      ],
      body: PlutoDualGrid(
        gridPropsA: PlutoDualGridProps(
          columns: gridAColumns,
          rows: gridARows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoOnLoadedEvent event) {
            gridAStateManager = event.stateManager;
            event.stateManager.addListener(gridAHandler);
          },
        ),
        gridPropsB: PlutoDualGridProps(
          columns: gridBColumns,
          rows: gridBRows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoOnLoadedEvent event) {
            gridBStateManager = event.stateManager;
          },
        ),
        display: PlutoDualGridDisplayRatio(ratio: 0.5),
      ),
    );
  }
}
