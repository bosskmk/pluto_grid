import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnFooterScreen extends StatefulWidget {
  static const routeName = 'feature/column-footer';

  const ColumnFooterScreen({Key? key}) : super(key: key);

  @override
  _ColumnFooterScreenState createState() => _ColumnFooterScreenState();
}

class _ColumnFooterScreenState extends State<ColumnFooterScreen> {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            format: 'Checked : #,###.###',
            filter: (cell) => cell.row.checked == true,
            alignment: Alignment.center,
          );
        },
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.end,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.sum,
            format: '#,###',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.number(format: '#,###.###'),
        textAlign: PlutoColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.average,
            format: 'Average : #,###.###',
            alignment: Alignment.center,
          );
        },
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.min,
            format: 'Min : #,###',
            alignment: Alignment.center,
          );
        },
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        type: PlutoColumnType.number(),
        textAlign: PlutoColumnTextAlign.right,
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.max,
            format: 'Max : #,###',
            alignment: Alignment.center,
          );
        },
      ),
      PlutoColumn(
        title: 'column6',
        field: 'column6',
        type: PlutoColumnType.select(['Android', 'iOS', 'Windows', 'Linux']),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            type: PlutoAggregateColumnType.count,
            filter: (cell) => cell.value == 'Android',
            format: 'Android : #,###',
            alignment: Alignment.center,
          );
        },
      ),
    ];

    rows = DummyData.rowsByColumns(length: 100, columns: columns);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column footer',
      topTitle: 'Column footer',
      topContents: const [
        Text(
            'Implement PlutoColumn \'s footerRenderer callback to display information such as sum, average, min, max, etc.'),
        Text(
            'You can easily implement it with the built-in PlutoAggregateColumnFooter plugin widget, or return the widget you want as a callback return value.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/column_footer_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setSelectingMode(PlutoGridSelectingMode.cell);
          stateManager.setShowColumnFilter(true);
        },
        configuration: const PlutoGridConfiguration(),
      ),
    );
  }
}
