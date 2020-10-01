import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class AddAndRemoveRowsScreen extends StatefulWidget {
  static const routeName = 'add-and-remove-rows';

  @override
  _AddAndRemoveRowsScreenState createState() => _AddAndRemoveRowsScreenState();
}

class _AddAndRemoveRowsScreenState extends State<AddAndRemoveRowsScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  PlutoSelectingMode gridSelectingMode = PlutoSelectingMode.Row;

  @override
  void initState() {
    super.initState();

    final dummyDate = DummyData(10, 100);

    columns = dummyDate.columns;

    rows = [];
  }

  void handleAddRowButton({int count}) {
    final List<PlutoRow> rows = count == null
        ? [DummyData.rowByColumns(columns)]
        : DummyData.rowsByColumns(length: count, columns: columns);

    stateManager.appendRows(rows);
  }

  void handleRemoveCurrentRowButton() {
    stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    stateManager.removeRows(stateManager.currentSelectingRows);
  }

  void setGridSelectingMode(PlutoSelectingMode mode) {
    if (gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      stateManager.setSelectingMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Add and Remove Rows',
      topTitle: 'Add and Remove Rows',
      topContents: [
        Text('You can add or delete rows.'),
        Text('Remove selected Rows is only deleted if there is a row selected in Row mode.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/add_and_remove_rows_screen.dart',
        ),
      ],
      body: Container(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FlatButton(
                    child: Text('Add a Row'),
                    onPressed: handleAddRowButton,
                  ),
                  FlatButton(
                    child: Text('Add 100 Rows'),
                    onPressed: () => handleAddRowButton(count: 100),
                  ),
                  FlatButton(
                    child: Text('Remove Current Row'),
                    onPressed: handleRemoveCurrentRowButton,
                  ),
                  FlatButton(
                    child: Text('Remove Selected Rows'),
                    onPressed: handleRemoveSelectedRowsButton,
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: gridSelectingMode,
                      items: PlutoStateManager.selectingModes
                          .map<DropdownMenuItem<PlutoSelectingMode>>(
                              (PlutoSelectingMode item) {
                            final color =
                            gridSelectingMode == item ? Colors.blue : null;

                            return DropdownMenuItem<PlutoSelectingMode>(
                              value: item,
                              child: Text(
                                item.toShortString(),
                                style: TextStyle(color: color),
                              ),
                            );
                          }).toList(),
                      onChanged: (PlutoSelectingMode mode) {
                        setGridSelectingMode(mode);
                      },
                    ),
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
                  stateManager = event.stateManager;
                  stateManager.setSelectingMode(gridSelectingMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
