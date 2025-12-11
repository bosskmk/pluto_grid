import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RTLScreen extends StatefulWidget {
  static const routeName = 'feature/rtl';

  const RTLScreen({super.key});

  @override
  _RTLScreenState createState() => _RTLScreenState();
}

class _RTLScreenState extends State<RTLScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 200);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Right To Left.',
      topTitle: 'Text direction.',
      topContents: const [
        Text(
            'Wrap the PlutoGrid with a Directionality widget and pass rtl to textDirection to enable RTL.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/rtl_screen.dart',
        ),
      ],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (event) {
            event.stateManager.setShowColumnFilter(true);
          },
          // configuration: const PlutoGridConfiguration(
          //   localeText: PlutoGridLocaleText.arabic(),
          // ),
          createFooter: (stateManager) {
            stateManager.setPageSize(20);
            return PlutoPagination(stateManager);
          },
        ),
      ),
    );
  }
}
