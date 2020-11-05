import 'dart:async';

import 'package:example/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ListingModeScreen extends StatefulWidget {
  static const routeName = 'feature/listing-mode';

  @override
  _ListingModeScreenState createState() => _ListingModeScreenState();
}

class _ListingModeScreenState extends State<ListingModeScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  StreamSubscription removeKeyboardListener;

  @override
  void dispose() {
    removeKeyboardListener.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    columns = [
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
    ];

    rows = DummyData.rowsByColumns(length: 30, columns: columns);
  }

  void handleKeyboard(KeyManagerEvent event) {
    // Specify the desired shortcut key.
    if (event.isKeyDownEvent && event.isCtrlC) {
      openNewRecord();
    }
  }

  void openNewRecord() async {
    String value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final textController = TextEditingController();
          return Dialog(
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: EdgeInsets.all(15),
                  width: 400,
                  height: 500,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Implement a screen to add a new record.'),
                        Text('Input some text, and Press Create Button.'),
                        TextField(
                          controller: textController,
                          autofocus: true,
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: Wrap(
                            children: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(ctx, null);
                                },
                                child: Text('Cancel.'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  print(textController.text);
                                  Navigator.pop(ctx, textController.text);
                                },
                                child: Text(
                                  'Create.',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });

    if (value == null || value.isEmpty) {
      return;
    }

    PlutoRow newRow = PlutoRow(
      cells: {
        'column_1': PlutoCell(value: value.toString()),
        'column_2': PlutoCell(value: value.toString()),
        'column_3': PlutoCell(value: value.toString()),
        'column_4': PlutoCell(value: value.toString()),
        'column_5': PlutoCell(value: value.toString()),
      },
    );

    stateManager.prependRows([newRow]);
    stateManager.moveScrollByRow(MoveDirection.Up, 1);
    stateManager.setCurrentCell(newRow.cells.entries.first.value, 0);
  }

  void openDetail(PlutoRow row) async {
    String value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          final textController = TextEditingController();
          return Dialog(
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  padding: EdgeInsets.all(15),
                  width: 400,
                  height: 500,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Implement a screen to update a record.'),
                        Text('Input some text, and Press Update Button.'),
                        TextField(
                          controller: textController,
                          autofocus: true,
                        ),
                        SizedBox(height: 20),
                        ...row.cells.entries
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.value.value.toString()),
                                ))
                            .toList(),
                        SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            children: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(ctx, null);
                                },
                                child: Text('Cancel.'),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(ctx, textController.text);
                                },
                                child: Text(
                                  'Update.',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });

    if (value == null || value.isEmpty) {
      return;
    }

    stateManager.changeCellValue(
      stateManager.currentRow.cells['column_1'].key,
      value,
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Listing mode',
      topTitle: 'Listing mode',
      topContents: [
        Text('Listing mode to open or navigate to the Detail page.'),
        Text('Press Enter or tap to call up the Detail popup.'),
        Text(
            'Pressing the Ctrl(Meta on MacOS) + C keys can invoke a popup to enter a new record.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/listing_mode_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoOnLoadedEvent event) {
          stateManager = event.stateManager;

          removeKeyboardListener =
              stateManager.keyManager.subject.stream.listen(handleKeyboard);

          stateManager.setSelectingMode(PlutoSelectingMode.None);
        },
        onSelected: (PlutoOnSelectedEvent event) {
          if (event.row != null) {
            openDetail(event.row);
          }
        },
        mode: PlutoMode.Select,
      ),
    );
  }
}
