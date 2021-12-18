import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class AddAndRemoveRowsScreen extends StatefulWidget {
  static const routeName = 'add-and-remove-rows';

  const AddAndRemoveRowsScreen({Key? key}) : super(key: key);

  @override
  _AddAndRemoveRowsScreenState createState() => _AddAndRemoveRowsScreenState();
}

class _AddAndRemoveRowsScreenState extends State<AddAndRemoveRowsScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

  PlutoGridSelectingMode? gridSelectingMode = PlutoGridSelectingMode.row;

  bool checkReadOnly(PlutoRow row, PlutoCell cell) {
    return row.cells['status']!.value != 'created';
  }

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
        readOnly: true,
        checkReadOnly: checkReadOnly,
        titleSpan: const TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.lock_outlined,
            size: 17,
          )),
          TextSpan(text: 'Id'),
        ]),
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.select(<String>[
          'saved',
          'edited',
          'created',
        ]),
        enableEditingMode: false,
        titleSpan: const TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.lock,
            size: 17,
          )),
          TextSpan(text: 'Status'),
        ]),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell!.value == 'saved') {
            textColor = Colors.green;
          } else if (rendererContext.cell!.value == 'edited') {
            textColor = Colors.red;
          } else if (rendererContext.cell!.value == 'created') {
            textColor = Colors.blue;
          }

          return Text(
            rendererContext.cell!.value.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    ];

    rows = [
      PlutoRow(cells: {
        'id': PlutoCell(value: 'user1'),
        'name': PlutoCell(value: 'user name 1'),
        'status': PlutoCell(value: 'saved'),
      }),
      PlutoRow(cells: {
        'id': PlutoCell(value: 'user2'),
        'name': PlutoCell(value: 'user name 2'),
        'status': PlutoCell(value: 'saved'),
      }),
      PlutoRow(cells: {
        'id': PlutoCell(value: 'user3'),
        'name': PlutoCell(value: 'user name 3'),
        'status': PlutoCell(value: 'saved'),
      }),
    ];
  }

  void handleNewRows({int? count}) {
    final newRows = stateManager!.getNewRow();
    newRows.cells['status']!.value = 'created';

    stateManager!.appendRows([newRows]);

    stateManager!.setCurrentCell(
      newRows.cells['id'],
      stateManager!.refRows!.length - 1,
      notify: false,
    );

    stateManager!.moveScrollByRow(
      PlutoMoveDirection.down,
      stateManager!.refRows!.length - 2,
    );

    stateManager!.setKeepFocus(true);
  }

  void handleSaveAll() {
    stateManager!.setShowLoading(true);

    Future.delayed(const Duration(milliseconds: 500), () {
      for (var row in stateManager!.refRows!) {
        if (row!.cells['status']!.value != 'saved') {
          row.cells['status']!.value = 'saved';
        }

        if (row.cells['id']!.value == '') {
          row.cells['id']!.value = 'guest';
        }

        if (row.cells['name']!.value == '') {
          row.cells['name']!.value = 'anonymous';
        }
      }

      stateManager!.setShowLoading(false);
    });
  }

  void handleRemoveCurrentRowButton() {
    stateManager!.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    stateManager!.removeRows(stateManager!.currentSelectingRows);
  }

  void handleFiltering() {
    stateManager!.setShowColumnFilter(!stateManager!.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      stateManager!.setSelectingMode(mode!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Add and Remove Rows',
      topTitle: 'Add and Remove Rows',
      topContents: const [
        Text('You can add or delete rows.'),
        Text(
            'Remove selected Rows is only deleted if there is a row selected in Row mode.'),
        Text(
            'If you are adding a new row, you can edit the cell regardless of the readOnly of column.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/add_and_remove_rows_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  child: const Text('Add a new row'),
                  onPressed: handleNewRows,
                ),
                ElevatedButton(
                  child: const Text('Save all'),
                  onPressed: handleSaveAll,
                ),
                ElevatedButton(
                  child: const Text('Remove Current Row'),
                  onPressed: handleRemoveCurrentRowButton,
                ),
                ElevatedButton(
                  child: const Text('Remove Selected Rows'),
                  onPressed: handleRemoveSelectedRowsButton,
                ),
                ElevatedButton(
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
                    onChanged: (PlutoGridSelectingMode? mode) {
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

                if (event.row!.cells['status']!.value == 'saved') {
                  event.row!.cells['status']!.value = 'edited';
                }

                stateManager!.notifyListeners();
              },
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager!.setSelectingMode(gridSelectingMode!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
