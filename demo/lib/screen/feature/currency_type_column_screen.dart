import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class CurrencyTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/currency-type-column';

  const CurrencyTypeColumnScreen({Key? key}) : super(key: key);

  @override
  _CurrencyTypeColumnScreenState createState() =>
      _CurrencyTypeColumnScreenState();
}

class _CurrencyTypeColumnScreenState extends State<CurrencyTypeColumnScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  Widget currencyRenderer(PlutoColumnRendererContext ctx) {
    assert(ctx.column.type.isCurrency);

    Color color = Colors.black;

    if (ctx.cell.value > 0) {
      color = Colors.blue;
    } else if (ctx.cell.value < 0) {
      color = Colors.red;
    }

    return Text(
      ctx.column.type.applyFormat(ctx.cell.value),
      style: TextStyle(color: color),
      textAlign: TextAlign.end,
    );
  }

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        renderer: currencyRenderer,
        textAlign: PlutoColumnTextAlign.end,
        type: PlutoColumnType.currency(),
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        renderer: currencyRenderer,
        textAlign: PlutoColumnTextAlign.end,
        type: PlutoColumnType.currency(name: '(USD) '),
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        renderer: currencyRenderer,
        textAlign: PlutoColumnTextAlign.end,
        type: PlutoColumnType.currency(
          locale: 'ko',
          name: '원',
          decimalDigits: 0,
          format: '#,###.## \u00A4',
          negative: false,
        ),
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        renderer: currencyRenderer,
        textAlign: PlutoColumnTextAlign.end,
        type: PlutoColumnType.currency(
          locale: 'fr_FR',
          symbol: '€',
          format: '\u00A4 #,###.##',
        ),
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        renderer: currencyRenderer,
        textAlign: PlutoColumnTextAlign.end,
        type: PlutoColumnType.currency(locale: 'da'),
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 30, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Currency type column',
      topTitle: 'Currency type column',
      topContents: const [
        Text('A column to enter a number as currency value.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/currency_type_column_screen.dart',
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
          stateManager.setShowColumnFilter(true);
        },
      ),
    );
  }
}
