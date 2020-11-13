import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class CellSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/cell-selection';

  @override
  _CellSelectionScreenState createState() => _CellSelectionScreenState();
}

class _CellSelectionScreenState extends State<CellSelectionScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns = dummyData.columns;

    rows = dummyData.rows;
  }

  void handleSelected() async {
    String value = '';

    stateManager.currentSelectingPositionList.forEach((element) {
      final cellValue =
          stateManager.rows[element.rowIdx].cells[element.field].value;

      value +=
          'rowIdx: ${element.rowIdx}, field: ${element.field}, value: $cellValue\n';
    });

    if (value.isEmpty) {
      value = 'No cells are selected.';
    }

    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: const EdgeInsets.all(15),
                  width: 400,
                  height: 500,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(value),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: [
        const Text(
            'In Square selection mode, Shift + tap or long tap and then move to select cells.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/cell_selection_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FlatButton(
                  child: const Text('Show selected cells.'),
                  onPressed: handleSelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onChanged: (PlutoOnChangedEvent event) {
                print(event);
              },
              onLoaded: (PlutoOnLoadedEvent event) {
                event.stateManager.setSelectingMode(PlutoSelectingMode.Square);

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
