import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class ConfigurationScreen extends StatelessWidget {
  static const routeName = 'configuration';

  final dummyData = DummyData(10, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PlutoGrid - Configuration'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: dummyData.columns,
          rows: dummyData.rows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
          configuration: PlutoConfiguration(
            enableColumnBorder: true,
          ),
        ),
      ),
    );
  }
}
