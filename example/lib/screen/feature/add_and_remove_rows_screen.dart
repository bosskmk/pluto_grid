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

  PlutoGridStateManager stateManager;

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns = dummyData.columns;

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

  void handleFiltering() {
    stateManager.setShowColumnFilter(!stateManager.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode mode) {
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
        const Text('You can add or delete rows.'),
        const Text(
            'Remove selected Rows is only deleted if there is a row selected in Row mode.'),
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
                    child: const Text('Add a Row'),
                    onPressed: handleAddRowButton,
                  ),
                  FlatButton(
                    child: const Text('Add 100 Rows'),
                    onPressed: () => handleAddRowButton(count: 100),
                  ),
                  FlatButton(
                    child: const Text('Remove Current Row'),
                    onPressed: handleRemoveCurrentRowButton,
                  ),
                  FlatButton(
                    child: const Text('Remove Selected Rows'),
                    onPressed: handleRemoveSelectedRowsButton,
                  ),
                  FlatButton(
                    child: const Text('Toggle filtering'),
                    onPressed: handleFiltering,
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: gridSelectingMode,
                      items: PlutoGridStateManager.selectingModes
                          .map<DropdownMenuItem<PlutoGridSelectingMode>>(
                              (PlutoGridSelectingMode item) {
                        final color =
                            gridSelectingMode == item ? Colors.blue : null;

                        return DropdownMenuItem<PlutoGridSelectingMode>(
                          value: item,
                          child: Text(
                            item.toShortString(),
                            style: TextStyle(color: color),
                          ),
                        );
                      }).toList(),
                      onChanged: (PlutoGridSelectingMode mode) {
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
                onChanged: (PlutoGridOnChangedEvent event) {
                  print(event);
                },
                onLoaded: (PlutoGridOnLoadedEvent event) {
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
