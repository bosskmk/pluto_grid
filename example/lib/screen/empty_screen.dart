import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class EmptyScreen extends StatefulWidget {
  static const routeName = 'empty';

  @override
  _EmptyScreenState createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  List<PlutoColumn>? columns;

  List<PlutoColumnGroup>? columnGroups;

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
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        type: PlutoColumnType.select(
          <String>['One', 'Two', 'Three'],
          enableColumnFilter: true,
        ),
      ),
    ];

    columnGroups = [
      PlutoColumnGroup(
        title: 'user info',
        fields: ['column1', 'column2'],
      ),
      PlutoColumnGroup(
        title: 'user detail',
        children: [
          PlutoColumnGroup(title: 'detail a', fields: ['column3']),
          PlutoColumnGroup(
            title: 'detail b',
            children: [
              PlutoColumnGroup(title: 'detail b-1', fields: ['column4']),
              PlutoColumnGroup(title: 'detail b-2', fields: ['column5']),
            ],
          ),
        ],
      ),
    ];

    rows = DummyData.rowsByColumns(length: 10, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager!.setShowColumnFilter(true);
          },
          configuration: PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
