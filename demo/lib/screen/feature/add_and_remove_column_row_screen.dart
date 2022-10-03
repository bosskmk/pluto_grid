import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class AddAndRemoveColumnRowScreen extends StatefulWidget {
  static const routeName = 'add-and-remove-column-row';

  const AddAndRemoveColumnRowScreen({Key? key}) : super(key: key);

  @override
  _AddAndRemoveColumnRowScreenState createState() =>
      _AddAndRemoveColumnRowScreenState();
}

class _AddAndRemoveColumnRowScreenState
    extends State<AddAndRemoveColumnRowScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoColumnGroup> columnGroups = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  bool checkReadOnly(PlutoRow row, PlutoCell cell) {
    return row.cells['status']!.value != 'created';
  }

  @override
  void initState() {
    super.initState();

    columns.addAll([
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
        frozen: PlutoColumnFrozen.end,
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

          if (rendererContext.cell.value == 'saved') {
            textColor = Colors.green;
          } else if (rendererContext.cell.value == 'edited') {
            textColor = Colors.red;
          } else if (rendererContext.cell.value == 'created') {
            textColor = Colors.blue;
          }

          return Text(
            rendererContext.cell.value.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    ]);

    columnGroups.addAll([
      PlutoColumnGroup(title: 'User', fields: ['id', 'name']),
      PlutoColumnGroup(
        title: 'Status',
        fields: ['status'],
        expandedColumn: true,
      ),
    ]);

    rows.addAll([
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
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Add and remove column, row',
      topTitle: 'Add and remove column, row',
      topContents: const [
        Text('You can add or delete columns, rows.'),
        Text(
            'Remove selected Rows is only deleted if there is a row selected in Row mode.'),
        Text(
            'If you are adding a new row, you can edit the cell regardless of the readOnly of column.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/add_and_remove_column_row_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        columnGroups: columnGroups,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);

          if (event.row!.cells['status']!.value == 'saved') {
            event.row!.cells['status']!.value = 'edited';
          }

          stateManager.notifyListeners();
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(stateManager: stateManager),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
    required this.stateManager,
    Key? key,
  }) : super(key: key);

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  final faker = Faker();

  int addCount = 1;

  int addedCount = 0;

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.stateManager.setSelectingMode(gridSelectingMode);
    });
  }

  void handleAddColumns() {
    final List<PlutoColumn> addedColumns = [];

    for (var i = 0; i < addCount; i += 1) {
      addedColumns.add(
        PlutoColumn(
          title: faker.food.cuisine(),
          field: 'column${++addedCount}',
          type: PlutoColumnType.text(),
        ),
      );
    }

    widget.stateManager.insertColumns(
      widget.stateManager.bodyColumns.length,
      addedColumns,
    );
  }

  void handleAddRows() {
    final newRows = widget.stateManager.getNewRows(count: addCount);

    for (var e in newRows) {
      e.cells['status']!.value = 'created';
    }

    widget.stateManager.appendRows(newRows);

    widget.stateManager.setCurrentCell(
      newRows.first.cells.entries.first.value,
      widget.stateManager.refRows.length - 1,
    );

    widget.stateManager.moveScrollByRow(
      PlutoMoveDirection.down,
      widget.stateManager.refRows.length - 2,
    );

    widget.stateManager.setKeepFocus(true);
  }

  void handleSaveAll() {
    widget.stateManager.setShowLoading(true);

    Future.delayed(const Duration(milliseconds: 500), () {
      for (var row in widget.stateManager.refRows) {
        if (row.cells['status']!.value != 'saved') {
          row.cells['status']!.value = 'saved';
        }

        if (row.cells['id']!.value == '') {
          row.cells['id']!.value = 'guest';
        }

        if (row.cells['name']!.value == '') {
          row.cells['name']!.value = 'anonymous';
        }
      }

      widget.stateManager.setShowLoading(false);
    });
  }

  void handleRemoveCurrentColumnButton() {
    final currentColumn = widget.stateManager.currentColumn;

    if (currentColumn == null) {
      return;
    }

    widget.stateManager.removeColumns([currentColumn]);
  }

  void handleRemoveCurrentRowButton() {
    widget.stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
  }

  void handleFiltering() {
    widget.stateManager
        .setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (mode == null || gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: addCount,
                items:
                    [1, 5, 10, 50, 100].map<DropdownMenuItem<int>>((int count) {
                  final color = addCount == count ? Colors.blue : null;

                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text(
                      count.toString(),
                      style: TextStyle(color: color),
                    ),
                  );
                }).toList(),
                onChanged: (int? count) {
                  setState(() {
                    addCount = count ?? 1;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: handleAddColumns,
              child: const Text('Add columns'),
            ),
            ElevatedButton(
              onPressed: handleAddRows,
              child: const Text('Add rows'),
            ),
            ElevatedButton(
              onPressed: handleSaveAll,
              child: const Text('Save all'),
            ),
            ElevatedButton(
              onPressed: handleRemoveCurrentColumnButton,
              child: const Text('Remove Current Column'),
            ),
            ElevatedButton(
              onPressed: handleRemoveCurrentRowButton,
              child: const Text('Remove Current Row'),
            ),
            ElevatedButton(
              onPressed: handleRemoveSelectedRowsButton,
              child: const Text('Remove Selected Rows'),
            ),
            ElevatedButton(
              onPressed: handleFiltering,
              child: const Text('Toggle filtering'),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: gridSelectingMode,
                items: PlutoGridSelectingMode.values
                    .map<DropdownMenuItem<PlutoGridSelectingMode>>(
                        (PlutoGridSelectingMode item) {
                  final color = gridSelectingMode == item ? Colors.blue : null;

                  return DropdownMenuItem<PlutoGridSelectingMode>(
                    value: item,
                    child: Text(
                      item.name,
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
    );
  }
}
