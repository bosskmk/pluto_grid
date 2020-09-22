import 'package:example/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class AddAndRemoveScreen extends StatelessWidget {
  static const routeName = 'add-and-remove';

  final _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('PlutoGrid - Add and Remove'),
      ),
      body: _CrudGrid(scaffoldKey: _scaffoldKey),
    );
  }
}

class _CrudGrid extends StatefulWidget {
  final scaffoldKey;

  _CrudGrid({
    this.scaffoldKey,
  });

  @override
  __CrudGridState createState() => __CrudGridState();
}

class __CrudGridState extends State<_CrudGrid> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  PlutoStateManager stateManager;

  PlutoSelectingMode gridSelectingMode = PlutoSelectingMode.Row;

  @override
  void initState() {
    final dummyRows = DummyData(10, 20);

    columns = dummyRows.columns;

    rows = dummyRows.rows;

    super.initState();
  }

  void message(context, String text) {
    widget.scaffoldKey.currentState.removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(text),
    );

    Scaffold.of(context).showSnackBar(snackBar);
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
    return Container(
      padding: const EdgeInsets.all(30),
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
                message(context, event.toString());
              },
              onLoaded: (PlutoOnLoadedEvent event) {
                stateManager = event.stateManager;
                stateManager.setSelectingMode(gridSelectingMode);
              },
            ),
          ),
        ],
      ),
    );
  }
}
