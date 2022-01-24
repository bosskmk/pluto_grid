import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowPaginationScreen extends StatefulWidget {
  static const routeName = 'feature/row-pagination';

  const RowPaginationScreen({Key? key}) : super(key: key);

  @override
  _RowPaginationScreenState createState() => _RowPaginationScreenState();
}

class _RowPaginationScreenState extends State<RowPaginationScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 5000);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row pagination',
      topTitle: 'Row pagination',
      topContents: const [
        Text(
            'If you pass the built-in PlutoPagination widget as the return value of the createFooter callback when creating a grid, pagination is processed.'),
        Text(
            'Also, referring to PlutoPagination, you can create a UI in the desired shape and set it as the response value of the createFooter callback.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_pagination_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setShowColumnFilter(true);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        configuration: const PlutoGridConfiguration(),
        createFooter: (stateManager) {
          stateManager.setPageSize(100, notify: false); // default 40
          return PlutoPagination(stateManager);
        },
      ),
    );
  }
}
