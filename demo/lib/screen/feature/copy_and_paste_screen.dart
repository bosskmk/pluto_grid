import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class CopyAndPasteScreen extends StatefulWidget {
  static const routeName = 'feature/copy-and-paste';

  const CopyAndPasteScreen({Key? key}) : super(key: key);

  @override
  _CopyAndPasteScreenState createState() => _CopyAndPasteScreenState();
}

class _CopyAndPasteScreenState extends State<CopyAndPasteScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'column 1',
        field: 'column_1',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column 2',
        field: 'column_2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column 3',
        field: 'column_3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column 4',
        field: 'column_4',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column 5',
        field: 'column_5',
        type: PlutoColumnType.text(),
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 5, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Copy and Paste',
      topTitle: 'Copy and Paste',
      topContents: const [
        Text(
            'Copy and paste are operated depending on the cell and row selection status.'),
        Text('Tap and hold a cell and move it to select a row or cell.'),
        Text('Ctrl + a : Select an entire row or cell.'),
        Text(
            'Ctrl + c : Copies the currently selected row or cell to the clipboard.'),
        Text('Ctrl + v : Paste the copied text array into the cell.'),
        Text(
            'Ctrl + Shift + v : If the copied text array is larger than the line at the currently selected position, a new line is added.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/copy_and_paste_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        createHeader: (stateManager) {
          return _Header(stateManager: stateManager);
        },
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  const _Header({
    required this.stateManager,
    Key? key,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    widget.stateManager.setSelectingMode(gridSelectingMode);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode || mode == null) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  void handleAddDummyRow() {
    widget.stateManager.appendRows(
      [DummyData.rowByColumns(widget.stateManager.refColumns)],
    );
  }

  void handleRemoveSelectedRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
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
                value: gridSelectingMode,
                items: PlutoGridStateManager.selectingModes
                    .map<DropdownMenuItem<PlutoGridSelectingMode>>(
                        (PlutoGridSelectingMode item) {
                  final color = gridSelectingMode == item ? Colors.blue : null;

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
            ElevatedButton(
              child: const Text('Add dummy row'),
              onPressed: handleAddDummyRow,
            ),
            ElevatedButton(
              child: const Text('Remove Selected Rows'),
              onPressed: handleRemoveSelectedRowsButton,
            ),
          ],
        ),
      ),
    );
  }
}
