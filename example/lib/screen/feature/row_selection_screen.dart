import 'package:example/dummy_data/development.dart';
import 'package:example/widget/pluto_example_button.dart';
import 'package:example/widget/pluto_example_screen.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class RowSelectionScreen extends StatefulWidget {
  static const routeName = 'feature/row-selection';

  @override
  _RowSelectionScreenState createState() => _RowSelectionScreenState();
}

class _RowSelectionScreenState extends State<RowSelectionScreen> {
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
      title: 'Row selection',
      topTitle: 'Row selection',
      topContents: [
        Text(
            'In Row selection mode, Shift + tap or long tap and then move or Control + tap to select a row.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/home_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoSelectingMode.Row);
        },
      ),
    );
  }
}
