import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnGroupScreen extends StatefulWidget {
  static const routeName = 'feature/column-group';

  @override
  _ColumnGroupScreenState createState() => _ColumnGroupScreenState();
}

class _ColumnGroupScreenState extends State<ColumnGroupScreen> {
  PlutoGridStateManager? stateManager;

  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  List<PlutoColumnGroup>? columnGroups;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'ExpandedColumn1',
        field: 'column1',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column2',
        field: 'column2',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column3',
        field: 'column3',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column4',
        field: 'column4',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column5',
        field: 'column5',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column6',
        field: 'column6',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'Column7',
        field: 'column7',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
      PlutoColumn(
        title: 'ExpandedColumn8',
        field: 'column8',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
      ),
    ];

    rows = DummyData.rowsByColumns(length: 100, columns: columns);

    columnGroups = [
      PlutoColumnGroup(
        title: 'Expanded',
        fields: ['column1'],
        expandedColumn: true,
      ),
      PlutoColumnGroup(
        title: 'Group A',
        children: [
          PlutoColumnGroup(
            title: 'A - 1',
            fields: ['column2', 'column3'],
          ),
          PlutoColumnGroup(
            title: 'A - 2',
            children: [
              PlutoColumnGroup(
                title: 'A - 2 - 1',
                fields: ['column4'],
              ),
              PlutoColumnGroup(
                title: 'A - 2 - 2',
                fields: ['column5'],
              ),
            ],
          ),
        ],
      ),
      PlutoColumnGroup(
        title: 'Group B',
        children: [
          PlutoColumnGroup(
            title: 'B - 1',
            children: [
              PlutoColumnGroup(
                title: 'B - 1 - 1',
                children: [
                  PlutoColumnGroup(
                    title: 'B - 1 - 1 - 1',
                    fields: ['column6'],
                  ),
                  PlutoColumnGroup(
                    title: 'B - 1 - 1 - 2',
                    fields: ['column7'],
                  ),
                ],
              ),
              PlutoColumnGroup(
                title: 'Expanded',
                fields: ['column8'],
                expandedColumn: true,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column group',
      topTitle: 'Column group',
      topContents: [
        const Text('You can group columns by any depth you want.'),
        const Text(
            'You can also separate grouped columns by dragging and dropping columns.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/column_group_screen.dart',
        ),
      ],
      body: PlutoGrid(
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
        configuration: const PlutoGridConfiguration(
          enableColumnBorder: true,
        ),
      ),
    );
  }
}
