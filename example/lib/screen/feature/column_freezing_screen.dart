import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnFreezingScreen extends StatefulWidget {
  static const routeName = 'feature/column-freezing';

  @override
  _ColumnFreezingScreenState createState() => _ColumnFreezingScreenState();
}

class _ColumnFreezingScreenState extends State<ColumnFreezingScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

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
      title: 'Column freezing',
      topTitle: 'Column freezing',
      topContents: [
        const Text(
            'You can freeze the column by tapping ToLeft, ToRight in the dropdown menu that appears when you tap the icon to the right of the column title.'),
        const Text(
            'If the width of the middle columns is narrow, the frozen column is released.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/column_freezing_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager!.setSelectingMode(PlutoGridSelectingMode.cell);
        },
      ),
    );
  }
}
