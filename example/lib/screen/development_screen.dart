import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class DevelopmentScreen extends StatefulWidget {
  static const routeName = 'development';

  @override
  _DevelopmentScreenState createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  PlutoSelectingMode gridSelectingMode = PlutoSelectingMode.Row;

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
    return Scaffold(
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setSelectingMode(gridSelectingMode);
        },
        createHeader: (PlutoStateManager stateManager) {
          return SingleChildScrollView(
            child: Container(
              height: stateManager.headerHeight,
              child: Row(
                children: [
                  FlatButton(
                    child: Text('Add 10'),
                    onPressed: () {
                      handleAddRowButton(count: 10);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        configuration: PlutoConfiguration(
          scrollbarConfig: PlutoScrollbarConfig(
            isAlwaysShown: true,
          ),
        ),
      ),
    );
  }
}
