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

  @override
  void initState() {
    columns = [
      PlutoColumn(
        title: 'text',
        field: 'text',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'number',
        field: 'number',
        type: PlutoColumnType.number(),
      ),
    ];

    rows = [];

    super.initState();
  }

  void message(context, String text) {
    widget.scaffoldKey.currentState.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(text),
    );

    Scaffold.of(context).showSnackBar(snackBar);
  }

  void handleAddButton() {
    stateManager.appendRows([
      PlutoRow(cells: {
        'text': PlutoCell(value: ''),
        'number': PlutoCell(value: 0),
      }),
    ]);
  }

  void handleRemoveButton() {
    stateManager.removeCurrentRow();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Row(
            children: [
              FlatButton(
                child: Text('Add Row'),
                onPressed: handleAddButton,
              ),
              FlatButton(
                child: Text('Remove Current Row'),
                onPressed: handleRemoveButton,
              ),
            ],
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
