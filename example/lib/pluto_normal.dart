import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'dummy_data/development.dart';

class PlutoNormal extends StatefulWidget {
  @override
  _PlutoNormalState createState() => _PlutoNormalState();
}

class _PlutoNormalState extends State<PlutoNormal> {
  final dummyData = DummyData(10, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: dummyData.columns,
          rows: dummyData.rows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
        ),
      ),
    );
  }
}
