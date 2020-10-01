import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class CellSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/cell-selection';

  @override
  _CellSelectionScreenState createState() => _CellSelectionScreenState();
}

class _CellSelectionScreenState extends State<CellSelectionScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  @override
  void initState() {
    super.initState();

    final dummyDate = DummyData(10, 100);

    columns = dummyDate.columns;

    rows = dummyDate.rows;
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Cell selection',
      topTitle: 'Cell selection',
      topContents: [
        Text(
            'In Square selection mode, Shift + tap or long tap and then move to select cells.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/cell_selection_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoSelectingMode.Square);
        },
      ),
    );
  }
}
