import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class EmptyScreen extends StatefulWidget {
  static const routeName = 'empty';

  const EmptyScreen({Key? key}) : super(key: key);

  @override
  _EmptyScreenState createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.select(<String>['a', 'b', 'c']),
        enableRowGroup: true,
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.select(<String>['1', '2', '3']),
        enableRowGroup: true,
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.text(),
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
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
          },
          configuration: const PlutoGridConfiguration(),
          createHeader: (_) {
            return TextButton(
              onPressed: () => print(stateManager.rowGroups),
              child: const Text('print'),
            );
          },
        ),
      ),
    );
  }
}
