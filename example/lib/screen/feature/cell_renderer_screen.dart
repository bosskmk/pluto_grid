import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class CellRendererScreen extends StatefulWidget {
  static const routeName = 'feature/cell-renderer';

  @override
  _CellRendererScreenState createState() => _CellRendererScreenState();
}

class _CellRendererScreenState extends State<CellRendererScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

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
        width: 250,
        minWidth: 175,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  rendererContext.stateManager.insertRows(
                    rendererContext.rowIdx,
                    [rendererContext.stateManager.getNewRow()],
                  );
                },
                iconSize: 18,
                color: Colors.green,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outlined,
                ),
                onPressed: () {
                  rendererContext.stateManager
                      .removeRows([rendererContext.row]);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              Expanded(
                child: Text(
                  rendererContext.row.cells[rendererContext.column.field].value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.select(['red', 'blue', 'green']),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell.value == 'red') {
            textColor = Colors.red;
          } else if (rendererContext.cell.value == 'blue') {
            textColor = Colors.blue;
          } else if (rendererContext.cell.value == 'green') {
            textColor = Colors.green;
          }

          return Text(
            rendererContext.cell.value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
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
      title: 'Cell renderer',
      topTitle: 'Cell renderer',
      topContents: [
        const Text('You can change the widget of the cell through the renderer.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/cell_renderer_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoSelectingMode.Square);

          stateManager = event.stateManager;
        },
        // configuration: PlutoConfiguration.dark(),
      ),
    );
  }
}
