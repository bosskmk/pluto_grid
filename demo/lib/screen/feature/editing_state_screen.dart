import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class EditingStateScreen extends StatefulWidget {
  static const routeName = 'feature/editing-state';

  const EditingStateScreen({Key? key}) : super(key: key);

  @override
  _EditingStateScreenState createState() => _EditingStateScreenState();
}

class _EditingStateScreenState extends State<EditingStateScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

  bool autoEditing = false;

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 100);

    columns = dummyData.columns;

    rows = dummyData.rows;
  }

  void toggleAutoEditing(bool flag) {
    setState(() {
      autoEditing = flag;
      stateManager!.setAutoEditing(flag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Editing state',
      topTitle: 'Editing state',
      topContents: const [
        Text('Automatically change to editing state when a cell is selected.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/editing_state_screen.dart',
        ),
      ],
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Switch(
                  value: autoEditing,
                  onChanged: toggleAutoEditing,
                ),
                const Text('autoEditing'),
              ],
            ),
          ),
          Expanded(
            child: PlutoGrid(
              columns: columns,
              rows: rows,
              onChanged: (PlutoGridOnChangedEvent event) {
                print(event);
              },
              onLoaded: (PlutoGridOnLoadedEvent event) {
                event.stateManager!
                    .setSelectingMode(PlutoGridSelectingMode.cell);

                stateManager = event.stateManager;
              },
            ),
          ),
        ],
      ),
    );
  }
}
