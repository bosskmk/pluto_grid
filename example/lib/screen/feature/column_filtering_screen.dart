import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnFilteringScreen extends StatefulWidget {
  static const routeName = 'feature/column-filtering';

  @override
  _ColumnFilteringScreenState createState() => _ColumnFilteringScreenState();
}

class _ColumnFilteringScreenState extends State<ColumnFilteringScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Column A',
        field: 'column_a',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column B',
        field: 'column_b',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column C',
        field: 'column_c',
        type: PlutoColumnType.text(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a1'),
          'column_b': PlutoCell(value: 'b1'),
          'column_c': PlutoCell(value: 'c1'),
        },
      ),
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a2'),
          'column_b': PlutoCell(value: 'b2'),
          'column_c': PlutoCell(value: 'c2'),
        },
      ),
      PlutoRow(
        cells: {
          'column_a': PlutoCell(value: 'a3'),
          'column_b': PlutoCell(value: 'b3'),
          'column_c': PlutoCell(value: 'c3'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column filtering',
      topTitle: 'Column filtering',
      topContents: [
        const Text('Filter rows by setting filters on columns.'),
        const SizedBox(
          height: 10,
        ),
        const Text(
            'Select the SetFilter menu from the menu that appears when you tap the icon on the right of the column'),
        const Text(
            'If the filter is set to all or complex conditions, TextField under the column is deactivated.'),
        const SizedBox(
          height: 10,
        ),
        const Text('Check out the source to add custom filters.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/column_filtering_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        configuration: PlutoConfiguration(
          /// If columnFilters is not set, default filters are set.
          /// The following is an example to add a custom filter.
          columnFilters: [
            PlutoFilterTypeContains(),
            PlutoFilterTypeEquals(),
            PlutoFilterTypeStartsWith(),
            PlutoFilterTypeEndsWith(),
            YourCustomFilter(),
          ],
        ),
      ),
    );
  }
}

class YourCustomFilter implements PlutoFilterType {
  @override
  get compare => (dynamic base, dynamic search) =>
      base.toString().contains(search.toString());

  @override
  String get title => 'Custom filter';
}
