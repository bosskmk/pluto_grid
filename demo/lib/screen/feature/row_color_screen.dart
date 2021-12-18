import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowColorScreen extends StatefulWidget {
  static const routeName = 'feature/row-color';

  const RowColorScreen({Key? key}) : super(key: key);

  @override
  _RowColorScreenState createState() => _RowColorScreenState();
}

class _RowColorScreenState extends State<RowColorScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns = dummyData.columns;

    rows = dummyData.rows;
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row color',
      topTitle: 'Row color',
      topContents: const [
        Text(
            'You can dynamically change the row color of row by implementing rowColorCallback.'),
        Text(
            'If you change the value of the 5th column, the background color is dynamically changed according to the value.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_color_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager!.setSelectingMode(PlutoGridSelectingMode.row);

          stateManager = event.stateManager;
        },
        rowColorCallback: (rowColorContext) {
          if (rowColorContext.row.cells.entries.elementAt(4).value.value ==
              'One') {
            return Colors.blueAccent;
          } else if (rowColorContext.row.cells.entries
                  .elementAt(4)
                  .value
                  .value ==
              'Two') {
            return Colors.cyanAccent;
          }

          return Colors.deepOrange;
        },
      ),
    );
  }
}
